abstract class EngineProcessMessage {}

abstract class EngineProvider {
  Future<void> start();
  Future<void> stop();
  void cycleStream();

  void onEngineStart();
  void onEngineStop();

  void send(String msg);
  void sendBackdoorMessage(String msg);
  Stream<String> get engineRawMessageStream;
}
