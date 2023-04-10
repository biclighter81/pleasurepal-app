import 'package:json_annotation/json_annotation.dart';
part 'pleasurepal_events.g.dart';

@JsonSerializable()
class PleasurepalDeviceCommand {
  double? intensity;
  double? duration;
  Map<String, dynamic>? args;

  PleasurepalDeviceCommand();

  factory PleasurepalDeviceCommand.fromJson(Map<String, dynamic> json) =>
      _$PleasurepalDeviceCommandFromJson(json);

  Map<String, dynamic> toJson() => _$PleasurepalDeviceCommandToJson(this);
}
