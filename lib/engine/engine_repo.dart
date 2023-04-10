import 'dart:async';
import 'dart:convert';

import 'package:buttplug/buttplug.dart';
import 'package:pleasurepal/engine/engine_messages.dart';
import 'package:pleasurepal/engine/engine_provider.dart';

class EngineOutput {
  final EngineMessage? engineMessage;
  final ButtplugServerMessage? buttplugMessage;

  EngineOutput(this.engineMessage, this.buttplugMessage);
}

class EngineRepository {
  final EngineProvider _provider;
  StreamController<EngineOutput> _engineStream = StreamController.broadcast();

  EngineRepository(this._provider);

  Future<void> start() async {
    _engineStream.close();
    _engineStream = StreamController.broadcast();
    _provider.cycleStream();
    _provider.engineRawMessageStream.forEach((element) {
      dynamic json;
      try {
        json = jsonDecode(element);
      } catch (e) {
        print("Error decoding JSON (invalid): $e");
      }
      try {
        var msg = EngineMessage.fromJson(json);
        _engineStream.add(EngineOutput(msg, null));
      } catch (e) {
        //No engine message check if it's a server message
        try {
          var buttplugMsg = ButtplugServerMessage.fromJson(json[0]);
          _engineStream.add(EngineOutput(null, buttplugMsg));
        } catch (e) {
          print("Error decoding JSON (buttplug server msg): $e $json");
        }
      }
    });
    await _provider.start();
  }

  Future<void> stop() async {
    _provider.stop();
  }

  void send(String msg) {
    _provider.send(msg);
  }

  void sendBackdoorMessage(String msg) {
    _provider.sendBackdoorMessage(msg);
  }

  Stream<EngineOutput> get engineStream => _engineStream.stream;
}
