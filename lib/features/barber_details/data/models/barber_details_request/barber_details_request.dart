import 'package:json_annotation/json_annotation.dart';

part 'barber_details_request.g.dart';
@JsonSerializable()
class BarberDetailsRequest {

  @JsonKey(name: 'p_shop_id')
  final String shopId;

  @JsonKey(name: 'p_lat')
  final double lat;

  @JsonKey(name: 'p_long')
  final double long;

  BarberDetailsRequest({required this.shopId, required this.lat, required this.long});

  factory BarberDetailsRequest.fromJson(Map<String, dynamic> json) => _$BarberDetailsRequestFromJson(json);

  Map<String, dynamic> toJson() => _$BarberDetailsRequestToJson(this);
}