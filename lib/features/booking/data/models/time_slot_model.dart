import 'package:json_annotation/json_annotation.dart';

part 'time_slot_model.g.dart';

@JsonSerializable()
class AvailableSlotsResponse {
  final List<TimeSlot> slots;

  @JsonKey(name: 'slot_duration')
  final int slotDuration;

  AvailableSlotsResponse({required this.slots, required this.slotDuration});

  factory AvailableSlotsResponse.fromJson(Map<String, dynamic> json) =>
      _$AvailableSlotsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AvailableSlotsResponseToJson(this);
}

@JsonSerializable()
class TimeSlot {
  @JsonKey(name: 'start_time')
  final String startTime;

  @JsonKey(name: 'end_time')
  final String endTime;

  TimeSlot({required this.startTime, required this.endTime});

  factory TimeSlot.fromJson(Map<String, dynamic> json) =>
      _$TimeSlotFromJson(json);

  Map<String, dynamic> toJson() => _$TimeSlotToJson(this);

  // Helper to display the time slot
  String get displayTime => '$startTime - $endTime';
}
