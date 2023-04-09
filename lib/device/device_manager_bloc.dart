import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:buttplug/client/client.dart';
import 'package:buttplug/client/client_device.dart';

import '../engine/engine_control_bloc.dart';
import 'backdoor_connector.dart';

class DeviceManagerEvent {}

class DeviceManagerEngineStartedEvent extends DeviceManagerEvent {}

class DeviceManagerEngineStoppedEvent extends DeviceManagerEvent {}

class DeviceManagerDeviceAddedEvent extends DeviceManagerEvent {
  final ButtplugClientDevice device;

  DeviceManagerDeviceAddedEvent(this.device);
}

class DeviceManagerDeviceRemovedEvent extends DeviceManagerEvent {
  final ButtplugClientDevice device;

  DeviceManagerDeviceRemovedEvent(this.device);
}

class DeviceManagerStartScanningEvent extends DeviceManagerEvent {}

class DeviceManagerStopScanningEvent extends DeviceManagerEvent {}

class DeviceManagerState {}

class DeviceManagerInitialState extends DeviceManagerState {}

class DeviceManagerDeviceOnlineState extends DeviceManagerState {
  //final DeviceCubit device;

  //DeviceManagerDeviceOnlineState(this.device);
}

class DeviceManagerDeviceOfflineState extends DeviceManagerState {
  //final DeviceCubit device;

  //DeviceManagerDeviceOfflineState(this.device);
}

class DeviceManagerStartScanningState extends DeviceManagerState {}

class DeviceManagerStopScanningState extends DeviceManagerState {}

class DeviceManagerBloc extends Bloc<DeviceManagerEvent, DeviceManagerState> {
  ButtplugClient? _internalClient;
  bool _scanning = false;
  //final List<DeviceCubit> _devices = [];
  final Stream<EngineControlState> _outputStream;
  final SendFunc _sendFunc;

  DeviceManagerBloc(this._outputStream, this._sendFunc)
      : super(DeviceManagerInitialState()) {
    on<DeviceManagerEngineStartedEvent>((event, emit) async {
      print("Engine started, starting device manager");
      // Start our internal buttplug client.
      var connector = ButtplugBackdoorClientConnector(_outputStream, _sendFunc);
      var client = ButtplugClient("Backdoor Client");
      // This is infallible due to our connector.
      await client.connect(connector);
      // Hook up our event listeners so we register new online devices as we get device added messages.
      client.eventStream.listen((event) {
        print(event.toString());
        if (event is DeviceAddedEvent) {
          print("Device connected: ${event.device.name}");
          //add(DeviceManagerDeviceAddedEvent(event.device));
          var cmd = ButtplugDeviceCommand.setVec([VibrateComponent(20)]);
          event.device.vibrate(cmd);
        }
        if (event is DeviceRemovedEvent) {
          print("Device disconnected: ${event.device.name}");
          add(DeviceManagerDeviceRemovedEvent(event.device));
        }
      });
      _internalClient = client;
      print("Starting scanning");
      await _internalClient?.startScanning();
    });

    on<DeviceManagerStartScanningEvent>(((event, emit) async {
      if (_internalClient == null) {
        return;
      }
      print("Starting scanning");
      _scanning = true;
      await _internalClient!.startScanning();
      emit(DeviceManagerStartScanningState());
    }));
  }
}
