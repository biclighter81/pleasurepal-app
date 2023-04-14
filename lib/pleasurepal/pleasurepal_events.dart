import 'package:buttplug/messages/enums.dart';
import 'package:json_annotation/json_annotation.dart';
part 'pleasurepal_events.g.dart';

@JsonSerializable()
class PleasurepalDeviceCommand {
  double intensity = 0.0;
  double duration = 0.0;
  Map<String, dynamic>? args;

  PleasurepalDeviceCommand();

  factory PleasurepalDeviceCommand.fromJson(Map<String, dynamic> json) =>
      _$PleasurepalDeviceCommandFromJson(json);

  Map<String, dynamic> toJson() => _$PleasurepalDeviceCommandToJson(this);
}

@JsonSerializable()
class PleasurepalDeviceCommandVibrate {
  double intensity = 0.0;
  double duration = 0.0;
  Map<String, dynamic>? args;
  PleasurepalDeviceCommandVibrate();

  factory PleasurepalDeviceCommandVibrate.fromJson(Map<String, dynamic> json) =>
      _$PleasurepalDeviceCommandVibrateFromJson(json);

  Map<String, dynamic> toJson() =>
      _$PleasurepalDeviceCommandVibrateToJson(this);
}

@JsonSerializable()
class PleasurepalDeviceCommandRotate {
  double speed = 0.0;
  double duration = 0.0;
  bool? clockwise;
  Map<String, dynamic>? args;
  PleasurepalDeviceCommandRotate();

  factory PleasurepalDeviceCommandRotate.fromJson(Map<String, dynamic> json) =>
      _$PleasurepalDeviceCommandRotateFromJson(json);

  Map<String, dynamic> toJson() => _$PleasurepalDeviceCommandRotateToJson(this);
}

@JsonSerializable()
class PleasurepalDeviceCommandLinear {
  double duration = 0.0;
  double position = 0.0;
  Map<String, dynamic>? args;
  PleasurepalDeviceCommandLinear();

  factory PleasurepalDeviceCommandLinear.fromJson(Map<String, dynamic> json) =>
      _$PleasurepalDeviceCommandLinearFromJson(json);

  Map<String, dynamic> toJson() => _$PleasurepalDeviceCommandLinearToJson(this);
}

@JsonSerializable()
class PleasurepalDeviceCommandScalar {
  double scalar = 0.0;
  ActuatorType actuatorType = ActuatorType.Vibrate;
  Map<String, dynamic>? args;
  PleasurepalDeviceCommandScalar();

  factory PleasurepalDeviceCommandScalar.fromJson(Map<String, dynamic> json) =>
      _$PleasurepalDeviceCommandScalarFromJson(json);

  Map<String, dynamic> toJson() => _$PleasurepalDeviceCommandScalarToJson(this);
}

@JsonSerializable()
class PleasurepalDeviceCommandStop extends PleasurepalDeviceCommand {
  Map<String, dynamic>? args;
  PleasurepalDeviceCommandStop();

  factory PleasurepalDeviceCommandStop.fromJson(Map<String, dynamic> json) =>
      _$PleasurepalDeviceCommandStopFromJson(json);

  Map<String, dynamic> toJson() => _$PleasurepalDeviceCommandStopToJson(this);
}
