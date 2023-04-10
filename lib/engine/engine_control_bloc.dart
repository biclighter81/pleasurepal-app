import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:buttplug/messages/messages.dart';
import 'package:pleasurepal/engine/engine_repo.dart';

import 'engine_messages.dart';

//States for the engine control
abstract class EngineControlState {}

class EngineStartingState extends EngineControlState {}

class EngineStartedState extends EngineControlState {}

class EngineServerCreatedState extends EngineControlState {}

class EngineStoppedState extends EngineControlState {}

class ClientConnectedState extends EngineControlState {
  final String clientName;
  ClientConnectedState(this.clientName);
}

class ClientDisconnectedState extends EngineControlState {}

class DeviceConnectedState extends EngineControlState {
  final String name;
  final String? displayName;
  final String address;
  final String protocol;
  final int index;

  DeviceConnectedState(
      this.name, this.displayName, this.index, this.address, this.protocol);
}

class DeviceDisconnectedState extends EngineControlState {
  final int index;
  DeviceDisconnectedState(this.index);
}

class ButtplugServerMessageState extends EngineControlState {
  final ButtplugServerMessage message;
  ButtplugServerMessageState(this.message);
}

class ServerLogMessageState extends EngineControlState {
  final EngineLog message;
  ServerLogMessageState(this.message);
}

class ProviderLogMessageState extends EngineControlState {
  final EngineProviderLog message;
  ProviderLogMessageState(this.message);
}

class EngineError extends EngineControlState {}

class EngineControlEvent {}

class EngineControlEventStart extends EngineControlEvent {}

class EngineControlEventStop extends EngineControlEvent {}

class EngineControlEventBackdoorMessage extends EngineControlEvent {
  final String message;
  EngineControlEventBackdoorMessage(this.message);
}

class EngineDevice {
  final int index;
  final String name;
  final String address;

  const EngineDevice(this.index, this.name, this.address);
}

class EngineControlBloc extends Bloc<EngineControlEvent, EngineControlState> {
  final EngineRepository _repo;
  EngineControlBloc(this._repo) : super(EngineStoppedState()) {
    //initial state

    on<EngineControlEventStart>((event, emit) async {
      print("Starting engine");
      await _repo.start();
      emit(EngineStartingState());
      return emit.forEach(_repo.engineStream, onData: (EngineOutput msg) {
        print(msg.buttplugMessage?.toJson());
        if (msg.engineMessage != null) {
          var engineMessage = msg.engineMessage!;
          if (engineMessage.engineStarted != null) {
            // Query for message version.
            print("Got engine started, sending message version request");
            emit(EngineStartedState());
            emit(ClientDisconnectedState());
            var msg = IntifaceMessage();
            msg.requestEngineVersion = RequestEngineVersion();
            _repo.send(jsonEncode(msg));
            return state;
          }
          if (engineMessage.engineServerCreated != null) {
            return EngineServerCreatedState();
          }
          if (engineMessage.engineLog != null) {
            return ServerLogMessageState(engineMessage.engineLog!);
          }
          if (engineMessage.engineProviderLog != null) {
            return ProviderLogMessageState(engineMessage.engineProviderLog!);
          }
          if (engineMessage.messageVersion != null) {
            print("Got message version return");
            return state;
          }
          if (engineMessage.clientConnected != null) {
            return ClientConnectedState(
                engineMessage.clientConnected!.clientName);
          }
          if (engineMessage.clientDisconnected != null) {
            return ClientDisconnectedState();
          }
          if (engineMessage.deviceConnected != null) {
            var deviceInfo = engineMessage.deviceConnected!;
            //_devices[deviceInfo.index] = EngineDevice(deviceInfo.index, deviceInfo.name, deviceInfo.address);
            return DeviceConnectedState(deviceInfo.name, deviceInfo.displayName,
                deviceInfo.index, deviceInfo.address, "lovense");
          }
          if (engineMessage.deviceDisconnected != null) {
            //_devices.remove(engineMessage.deviceDisconnected!.index);
            return DeviceDisconnectedState(
                engineMessage.deviceDisconnected!.index);
          }
          if (engineMessage.engineStopped != null) {
            print("Received EngineStopped message");
            //_isRunning = false;
            return EngineStoppedState();
          }
        } else if (msg.buttplugMessage != null) {
          return ButtplugServerMessageState(msg.buttplugMessage!);
        }
        return state;
      });
    });
    on<EngineControlEventBackdoorMessage>((event, emit) async {
      _repo.sendBackdoorMessage(event.message);
    });
    on<EngineControlEventStop>((event, emit) async {
      await _repo.stop();
    });
  }
}
