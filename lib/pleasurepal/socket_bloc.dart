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
      kDebugMode ? 'http://localhost:80' : 'https://pleasurepal.com',
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
        socket.on('device-command', (data) {
          var command = PleasurepalDeviceCommand.fromJson(data);
          add(SocketEventPleasurepalCommand(command));
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
  }
}
