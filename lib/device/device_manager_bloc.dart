import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:buttplug/client/client.dart';
import 'package:buttplug/client/client_device.dart';
import 'package:buttplug/messages/enums.dart';
import 'package:pleasurepal/pleasurepal/socket_bloc.dart';

import '../engine/engine_control_bloc.dart';
import '../pleasurepal/pleasurepal_events.dart';
import 'backdoor_connector.dart';
import 'device_cubit.dart';

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

class DeviceManagerDeviceActiveEvent extends DeviceManagerEvent {
  final DeviceCubit device;

  DeviceManagerDeviceActiveEvent(this.device);
}

class DeviceManagerCommandEvent extends DeviceManagerEvent {
  final dynamic command;

  DeviceManagerCommandEvent(this.command);
}

class DeviceManagerState {}

class DeviceManagerInitialState extends DeviceManagerState {}

class DeviceManagerDeviceOnlineState extends DeviceManagerState {
  final DeviceCubit device;

  DeviceManagerDeviceOnlineState(this.device);
}

class DeviceManagerDeviceActiveState extends DeviceManagerState {
  final DeviceCubit device;

  DeviceManagerDeviceActiveState(this.device);
}

class DeviceManagerDeviceInactiveState extends DeviceManagerState {
  final DeviceCubit device;

  DeviceManagerDeviceInactiveState(this.device);
}

class DeviceManagerDeviceOfflineState extends DeviceManagerState {
  final DeviceCubit device;

  DeviceManagerDeviceOfflineState(this.device);
}

class DeviceManagerStartScanningState extends DeviceManagerState {}

class DeviceManagerStopScanningState extends DeviceManagerState {}

class DeviceCubitState extends DeviceCubit {
  DeviceCubitState(ButtplugClientDevice? device) : super(device);
  bool active = false;
}

class DeviceManagerBloc extends Bloc<DeviceManagerEvent, DeviceManagerState> {
  ButtplugClient? _internalClient;
  bool _scanning = false;
  final List<DeviceCubitState> _devices = [];
  Stream<List<DeviceCubitState>> get deviceStream =>
      Stream.fromIterable([_devices]);
  final Stream<EngineControlState> _outputStream;
  final SendFunc _sendFunc;

  DeviceManagerBloc(this._outputStream, this._sendFunc)
      : super(DeviceManagerInitialState()) {
    on<DeviceManagerEngineStartedEvent>((event, emit) async {
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
          add(DeviceManagerDeviceAddedEvent(event.device));
        }
        if (event is DeviceRemovedEvent) {
          print("Device disconnected: ${event.device.name}");
          add(DeviceManagerDeviceRemovedEvent(event.device));
        }
      });
      _internalClient = client;
    });

    on<DeviceManagerDeviceActiveEvent>((event, emit) {
      // Move the active device to active.
      var deviceBloc = _devices
          .firstWhere((deviceBloc) => deviceBloc.device == event.device.device);
      if (deviceBloc.active) {
        deviceBloc.active = false;
        emit(DeviceManagerDeviceInactiveState(deviceBloc));
      } else {
        deviceBloc.active = true;
        emit(DeviceManagerDeviceActiveState(deviceBloc));
      }
    });

    on<DeviceManagerDeviceAddedEvent>((event, emit) {
      var deviceBloc = DeviceCubit(event.device);
      _devices.add(DeviceCubitState(event.device));
      /*event.device
          .rotate(ButtplugDeviceCommand.setAll(RotateComponent(0, true)));
      event.device.linear(ButtplugDeviceCommand.setAll(LinearComponent(0, 0)));
      event.device.scalar(ButtplugDeviceCommand.setAll(
          ScalarComponent(0, ActuatorType.Vibrate)));
      event.device.vibrate(ButtplugDeviceCommand.setAll(VibrateComponent(0)));
      */
      _internalClient?.stopAllDevices();
      emit(DeviceManagerDeviceOnlineState(deviceBloc));
    });

    on<DeviceManagerDeviceRemovedEvent>(((event, emit) {
      try {
        // This will throw if it doesn't find anything.
        var deviceBloc = _devices.firstWhere(
            (deviceBloc) => deviceBloc.device?.index == event.device.index);
        _devices.remove(deviceBloc);
        emit(DeviceManagerDeviceOfflineState(deviceBloc));
      } catch (e) {
        print("Got device removal event for a device we don't have.");
      }
    }));

    on<DeviceManagerEngineStoppedEvent>((event, emit) {
      // Stop our internal buttplug client.
      if (_internalClient != null) {
        _internalClient!.disconnect();
        _internalClient = null;
      }
      _scanning = false;
      // Move all devices to offline.
      _devices.clear();
    });

    on<DeviceManagerStartScanningEvent>(((event, emit) async {
      if (_internalClient == null) {
        return;
      }
      _scanning = true;
      await _internalClient!.startScanning();
      emit(DeviceManagerStartScanningState());
    }));

    on<DeviceManagerStopScanningEvent>(((event, emit) async {
      if (_internalClient == null) {
        return;
      }
      _scanning = false;
      await _internalClient!.stopScanning();
      emit(DeviceManagerStopScanningState());
    }));

    on<DeviceManagerCommandEvent>(((event, emit) async {
      if (_internalClient == null) {
        return;
      }
      _devices.forEach((element) async {
        await _internalClient?.stopAllDevices();
        if (element.active) {
          if (event.command is PleasurepalDeviceCommandVibrate) {
            var cmd = event.command as PleasurepalDeviceCommandVibrate;
            await element.device?.vibrate(
                ButtplugDeviceCommand.setAll(VibrateComponent(cmd.intensity)));
            Future.delayed(Duration(seconds: cmd.duration.round()), () async {
              await _internalClient?.stopAllDevices();
            });
          }
          if (event.command is PleasurepalDeviceCommandRotate) {
            var cmd = event.command as PleasurepalDeviceCommandRotate;
            await element.device?.rotate(ButtplugDeviceCommand.setAll(
                RotateComponent(cmd.speed, cmd.clockwise ?? true)));
            Future.delayed(Duration(seconds: cmd.duration.round()), () async {
              await _internalClient?.stopAllDevices();
            });
          }
          if (event.command is PleasurepalDeviceCommandLinear) {
            var cmd = event.command as PleasurepalDeviceCommandLinear;
            await element.device?.linear(ButtplugDeviceCommand.setAll(
                LinearComponent(cmd.position, cmd.duration.round())));
          }
          if (event.command is PleasurepalDeviceCommandScalar) {
            var cmd = event.command as PleasurepalDeviceCommandScalar;
            await element.device?.scalar(ButtplugDeviceCommand.setAll(
                ScalarComponent(cmd.scalar, cmd.actuatorType)));
          }
          if (event.command is PleasurepalDeviceCommandStop) {
            await _internalClient?.stopAllDevices();
          }
        }
      });
    }));
  }
  List<DeviceCubitState> get devices => _devices;
  bool get scanning => _scanning;
}
