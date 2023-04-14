import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:openid_client/openid_client.dart';
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

class SocketCommand extends SocketState {
  final dynamic command;

  SocketCommand(this.command);
}

class SocketEvent {}

class SocketEventPleasurepalCommand extends SocketEvent {
  final PleasurepalDeviceCommand command;

  SocketEventPleasurepalCommand(this.command);
}

class SocketEventPleasurepalCommandVibrate extends SocketEvent {
  final PleasurepalDeviceCommandVibrate command;

  SocketEventPleasurepalCommandVibrate(this.command);
}

class SocketEventPleasurepalCommandStop extends SocketEvent {
  final PleasurepalDeviceCommandStop command;

  SocketEventPleasurepalCommandStop(this.command);
}

class SocketEventPleasurepalCommandRotate extends SocketEvent {
  final PleasurepalDeviceCommandRotate command;

  SocketEventPleasurepalCommandRotate(this.command);
}

class SocketEventPleasurepalCommandLinear extends SocketEvent {
  final PleasurepalDeviceCommandLinear command;

  SocketEventPleasurepalCommandLinear(this.command);
}

class SocketEventPleasurepalCommandScalar extends SocketEvent {
  final PleasurepalDeviceCommandScalar command;

  SocketEventPleasurepalCommandScalar(this.command);
}

class SocketEventConnect extends SocketEvent {
  final Credential credential;

  SocketEventConnect(this.credential);
}

class SocketEventDisconnect extends SocketEvent {}

class SocketEventError extends SocketEvent {}

class SocketBloc extends Bloc<SocketEvent, SocketState> {
  SocketBloc() : super(SocketInitial()) {
    on<SocketEventConnect>((event, emit) async {
      emit(SocketConnecting());
      try {
        var socket = await connectSocket(event.credential);
        socket.on('connect', (_) {
          print('connected');
        });
        socket.on('device-command', (data) {
          var command = PleasurepalDeviceCommand.fromJson(data);
          add(SocketEventPleasurepalCommand(command));
        });
        socket.on('device-vibrate', (data) {
          var command = PleasurepalDeviceCommandVibrate.fromJson(data);
          add(SocketEventPleasurepalCommandVibrate(command));
        });
        socket.on('device-stop', (data) {
          var command = PleasurepalDeviceCommandStop.fromJson(data);
          add(SocketEventPleasurepalCommandStop(command));
        });
        socket.on('device-rotate', (data) {
          var command = PleasurepalDeviceCommandRotate.fromJson(data);
          add(SocketEventPleasurepalCommandRotate(command));
        });
        socket.on('device-linear', (data) {
          var command = PleasurepalDeviceCommandLinear.fromJson(data);
          add(SocketEventPleasurepalCommandLinear(command));
        });
        socket.on('device-scalar', (data) {
          var command = PleasurepalDeviceCommandScalar.fromJson(data);
          add(SocketEventPleasurepalCommandScalar(command));
        });
        emit(SocketReady());
      } catch (e) {
        print(e);
        emit(SocketError());
      }
    });
    on<SocketEventPleasurepalCommand>((event, emit) async {
      emit(SocketCommand(event.command));
    });
    on<SocketEventPleasurepalCommandVibrate>((event, emit) async {
      emit(SocketCommand(event.command));
    });
    on<SocketEventPleasurepalCommandStop>((event, emit) async {
      emit(SocketCommand(event.command));
    });
    on<SocketEventPleasurepalCommandRotate>((event, emit) async {
      emit(SocketCommand(event.command));
    });
    on<SocketEventPleasurepalCommandLinear>((event, emit) async {
      emit(SocketCommand(event.command));
    });
    on<SocketEventPleasurepalCommandScalar>((event, emit) async {
      emit(SocketCommand(event.command));
    });
  }
}
