import 'dart:async';

import 'package:flutter_rust_bridge_template/ffi.dart';

import 'engine_provider.dart';

class DesktopEngineProvider implements EngineProvider {
  Stream<String>? _stream;
  StreamController<String> _processMsgStream = StreamController.broadcast();

  @override
  void cycleStream() {
    _processMsgStream.close();
    _processMsgStream = StreamController.broadcast();
  }

  @override
  Stream<String> get engineRawMessageStream => _processMsgStream.stream;

  @override
  void onEngineStart() {}

  @override
  void onEngineStop() {}

  @override
  void send(String msg) {
    api.send(msgJson: msg);
  }

  @override
  void sendBackdoorMessage(String msg) {
    api.sendBackendServerMessage(msg: msg);
  }

  @override
  Future<void> start() async {
    _stream = api.runEngine(
        args: const EngineOptionsExternal(
            serverName: "server",
            crashReporting: false,
            websocketUseAllInterfaces: true,
            frontendInProcessChannel: true,
            maxPingTime: 5000,
            allowRawMessages: false,
            websocketPort: 12345,
            useBluetoothLe: true,
            useSerialPort: false,
            useHid: false,
            useLovenseDongleSerial: false,
            useLovenseDongleHid: false,
            useXinput: false,
            useLovenseConnect: false,
            useDeviceWebsocketServer: true,
            crashMainThread: false,
            crashTaskThread: false));
    print("Engine started");
    _stream!.forEach((element) {
      try {
        _processMsgStream.add(element);
      } catch (e) {
        print("Error decoding JSON: $e");
        return;
      }
    });
  }

  @override
  Future<void> stop() async {
    api.stopEngine();
  }
}
