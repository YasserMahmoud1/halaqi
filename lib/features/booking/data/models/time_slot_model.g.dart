// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time_slot_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AvailableSlotsResponse _$AvailableSlotsResponseFromJson(
  Map<String, dynamic> json,
) => AvailableSlotsResponse(
  slots: (json['slots'] as List<dynamic>)
      .map((e) => TimeSlot.fromJson(e as Map<String, dynamic>))
      .toList(),
  slotDuration: (json['slot_duration'] as num).toInt(),
);

Map<String, dynamic> _$AvailableSlotsResponseToJson(
  AvailableSlotsResponse instance,
) => <String, dynamic>{
  'slots': instance.slots,
  'slot_duration': instance.slotDuration,
};

TimeSlot _$TimeSlotFromJson(Map<String, dynamic> json) => TimeSlot(
  startTime: json['start_time'] as String,
  endTime: json['end_time'] as String,
);

Map<String, dynamic> _$TimeSlotToJson(TimeSlot instance) => <String, dynamic>{
  'start_time': instance.startTime,
  'end_time': instance.endTime,
};
