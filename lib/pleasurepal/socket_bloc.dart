import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:buttplug/buttplug.dart';
import 'package:pleasurepal/device/device_cubit.dart';
import 'package:pleasurepal/device/device_manager_bloc.dart';
import 'package:openid_client/openid_client.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

Future<io.Socket> connectSocket(Credential cred) async {
  var tokenRes = await cred.getTokenResponse();
  var token = tokenRes.accessToken;
  io.Socket socket = io.io(
      //'https://ws.pleasurepal.de',
      'http://localhost:80',
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
  final dynamic command;

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
        socket.on('command', (data) {
          add(SocketEventPleasurepalCommand(data));
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
