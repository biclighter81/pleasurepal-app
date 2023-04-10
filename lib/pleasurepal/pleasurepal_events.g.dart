// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pleasurepal_events.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************
PleasurepalDeviceCommand _$PleasurepalDeviceCommandFromJson(
        Map<String, dynamic> json) =>
    PleasurepalDeviceCommand()
      ..intensity = (json['intensity'] as num?)?.toDouble()
      ..duration = (json['duration'] as num?)?.toDouble()
      ..args = json['args'] as Map<String, dynamic>?;

Map<String, dynamic> _$PleasurepalDeviceCommandToJson(
        PleasurepalDeviceCommand instance) =>
    <String, dynamic>{
      'intensity': instance.intensity,
      'duration': instance.duration,
      'args': instance.args,
    };
