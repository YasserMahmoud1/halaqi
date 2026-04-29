// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'barber_details_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BarberDetailsRequest _$BarberDetailsRequestFromJson(
  Map<String, dynamic> json,
) => BarberDetailsRequest(
  shopId: json['p_shop_id'] as String,
  lat: (json['p_lat'] as num).toDouble(),
  long: (json['p_long'] as num).toDouble(),
);

Map<String, dynamic> _$BarberDetailsRequestToJson(
  BarberDetailsRequest instance,
) => <String, dynamic>{
  'p_shop_id': instance.shopId,
  'p_lat': instance.lat,
  'p_long': instance.long,
};
