import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:buttplug/buttplug.dart';
import 'package:flutter/foundation.dart';
import 'package:openid_client/openid_client.dart';
import 'package:pleasurepal/device/device_manager_bloc.dart';
import 'package:pleasurepal/pleasurepal/pleasurepal_events.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

Future<io.Socket> connectSocket(Credential cred) async {
  var tokenRes = await cred.getTokenResponse();
  var token = tokenRes.accessToken;
  io.Socket socket = io.io(
      kDebugMode ? 'http://localhost:80' : 'https://ws.pleasurepal.de',
      io.OptionBuilder()
          .disableAutoConnect()
          .setTransports(['websocket']).setAuth({
        'token': token,
      }).build());
  socket.connect();
  return socket;
}

abstract class SocketState {}

class SocketInitial extends SocketState {}

class SocketConnecting extends SocketState {}

class SocketReady extends SocketState {}

class SocketError extends SocketState {}

class SocketEvent {}

class SocketEventConnect extends SocketEvent {
  final Credential credential;

  SocketEventConnect(this.credential);
}

class SocketEventDisconnect extends SocketEvent {}

class SocketEventError extends SocketEvent {}

class SocketBloc extends Bloc<SocketEvent, SocketState> {
  final DeviceManagerBloc deviceBloc;
  Map<String, Timer> deviceTimers = {};

  SocketBloc(this.deviceBloc) : super(SocketInitial()) {
    on<SocketEventConnect>((event, emit) async {
      emit(SocketConnecting());
      try {
        var socket = await connectSocket(event.credential);
        socket.on('connect', (_) {
          print('Connected to socket!');
        });
        socket.on('disconnect', (_) {
          print('Disconnected from socket!');
        });
        socket.on('device-vibrate', (data) {
          var cmd = PleasurepalDeviceCommandVibrate.fromJson(data);
          deviceBloc.devices
              .where((element) => element.active)
              .forEach((element) {
            if (deviceTimers[element.device!.name] != null) {
              deviceTimers[element.device!.name]!.cancel();
            }
            element.device?.vibrate(
                ButtplugDeviceCommand.setAll(VibrateComponent(cmd.intensity)));
            deviceTimers[element.device!.name] =
                Timer(Duration(seconds: cmd.duration.round()), () {
              element.device
                  ?.vibrate(ButtplugDeviceCommand.setAll(VibrateComponent(0)));
            });
          });
        });
        socket.on('device-stop', (data) {
          deviceBloc.client.stopAllDevices();
        });
        socket.on('device-rotate', (data) {
          var cmd = PleasurepalDeviceCommandRotate.fromJson(data);
          deviceBloc.devices
              .where((element) => element.active)
              .forEach((element) {
            if (deviceTimers[element.device!.name] != null) {
              deviceTimers[element.device!.name]!.cancel();
            }
            element.device?.rotate(ButtplugDeviceCommand.setAll(
                RotateComponent(cmd.speed, cmd.clockwise ?? true)));
            deviceTimers[element.device!.name] =
                Timer(Duration(seconds: cmd.duration.round()), () {
              element.device?.rotate(
                  ButtplugDeviceCommand.setAll(RotateComponent(0, true)));
            });
          });
        });
        socket.on('device-linear', (data) {
          var cmd = PleasurepalDeviceCommandLinear.fromJson(data);
          deviceBloc.devices
              .where((element) => element.active)
              .forEach((element) {
            if (deviceTimers[element.device!.name] != null) {
              deviceTimers[element.device!.name]!.cancel();
            }
            element.device?.linear(ButtplugDeviceCommand.setAll(
                LinearComponent(cmd.position, cmd.duration.round())));
          });
        });
        socket.on('device-scalar', (data) {
          var cmd = PleasurepalDeviceCommandScalar.fromJson(data);
          deviceBloc.devices
              .where((element) => element.active)
              .forEach((element) {
            if (deviceTimers[element.device!.name] != null) {
              deviceTimers[element.device!.name]!.cancel();
            }
            element.device?.scalar(ButtplugDeviceCommand.setAll(
                ScalarComponent(cmd.scalar, cmd.actuatorType)));
            deviceTimers[element.device!.name] =
                Timer(Duration(seconds: cmd.duration.round()), () {
              element.device?.rotate(
                  ButtplugDeviceCommand.setAll(RotateComponent(0, true)));
            });
          });
        });
        emit(SocketReady());
      } catch (e) {
        print(e);
        emit(SocketError());
      }
    });
  }
}
