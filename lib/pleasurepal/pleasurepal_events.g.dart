// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pleasurepal_events.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PleasurepalDeviceCommand _$PleasurepalDeviceCommandFromJson(
        Map<String, dynamic> json) =>
    PleasurepalDeviceCommand()
      ..intensity = (json['intensity'] as num).toDouble()
      ..duration = (json['duration'] as num).toDouble()
      ..args = json['args'] as Map<String, dynamic>?;

Map<String, dynamic> _$PleasurepalDeviceCommandToJson(
        PleasurepalDeviceCommand instance) =>
    <String, dynamic>{
      'intensity': instance.intensity,
      'duration': instance.duration,
      'args': instance.args,
    };

PleasurepalDeviceCommandVibrate _$PleasurepalDeviceCommandVibrateFromJson(
        Map<String, dynamic> json) =>
    PleasurepalDeviceCommandVibrate()
      ..intensity = (json['intensity'] as num).toDouble()
      ..duration = (json['duration'] as num).toDouble()
      ..args = json['args'] as Map<String, dynamic>?;

Map<String, dynamic> _$PleasurepalDeviceCommandVibrateToJson(
        PleasurepalDeviceCommandVibrate instance) =>
    <String, dynamic>{
      'intensity': instance.intensity,
      'duration': instance.duration,
      'args': instance.args,
    };

PleasurepalDeviceCommandRotate _$PleasurepalDeviceCommandRotateFromJson(
        Map<String, dynamic> json) =>
    PleasurepalDeviceCommandRotate()
      ..speed = (json['speed'] as num).toDouble()
      ..duration = (json['duration'] as num).toDouble()
      ..clockwise = json['clockwise'] as bool?
      ..args = json['args'] as Map<String, dynamic>?;

Map<String, dynamic> _$PleasurepalDeviceCommandRotateToJson(
        PleasurepalDeviceCommandRotate instance) =>
    <String, dynamic>{
      'speed': instance.speed,
      'duration': instance.duration,
      'clockwise': instance.clockwise,
      'args': instance.args,
    };

PleasurepalDeviceCommandLinear _$PleasurepalDeviceCommandLinearFromJson(
        Map<String, dynamic> json) =>
    PleasurepalDeviceCommandLinear()
      ..duration = (json['duration'] as num).toDouble()
      ..position = (json['position'] as num).toDouble()
      ..args = json['args'] as Map<String, dynamic>?;

Map<String, dynamic> _$PleasurepalDeviceCommandLinearToJson(
        PleasurepalDeviceCommandLinear instance) =>
    <String, dynamic>{
      'duration': instance.duration,
      'position': instance.position,
      'args': instance.args,
    };

PleasurepalDeviceCommandScalar _$PleasurepalDeviceCommandScalarFromJson(
        Map<String, dynamic> json) =>
    PleasurepalDeviceCommandScalar()
      ..scalar = (json['scalar'] as num).toDouble()
      ..actuatorType = $enumDecode(_$ActuatorTypeEnumMap, json['actuatorType'])
      ..args = json['args'] as Map<String, dynamic>?;

Map<String, dynamic> _$PleasurepalDeviceCommandScalarToJson(
        PleasurepalDeviceCommandScalar instance) =>
    <String, dynamic>{
      'scalar': instance.scalar,
      'actuatorType': _$ActuatorTypeEnumMap[instance.actuatorType]!,
      'args': instance.args,
    };

const _$ActuatorTypeEnumMap = {
  ActuatorType.Vibrate: 'Vibrate',
  ActuatorType.Rotate: 'Rotate',
  ActuatorType.Oscillate: 'Oscillate',
  ActuatorType.Constrict: 'Constrict',
  ActuatorType.Inflate: 'Inflate',
  ActuatorType.Position: 'Position',
};

PleasurepalDeviceCommandStop _$PleasurepalDeviceCommandStopFromJson(
        Map<String, dynamic> json) =>
    PleasurepalDeviceCommandStop()
      ..intensity = (json['intensity'] as num).toDouble()
      ..duration = (json['duration'] as num).toDouble()
      ..args = json['args'] as Map<String, dynamic>?;

Map<String, dynamic> _$PleasurepalDeviceCommandStopToJson(
        PleasurepalDeviceCommandStop instance) =>
    <String, dynamic>{
      'intensity': instance.intensity,
      'duration': instance.duration,
      'args': instance.args,
    };
