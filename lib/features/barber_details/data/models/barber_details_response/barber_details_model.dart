import 'package:json_annotation/json_annotation.dart';

part 'barber_details_model.g.dart';

@JsonSerializable()
class BarberDetailsResponse {
  final BarberDetails shop;

  BarberDetailsResponse({required this.shop});

  factory BarberDetailsResponse.fromJson(Map<String, dynamic> json) =>
      _$BarberDetailsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BarberDetailsResponseToJson(this);
}

@JsonSerializable()
class BarberDetails {
  final String id;
  final String name;
  final String? description;
  final String address;
  final double? lat;
  final double? long;

  @JsonKey(name: 'avg_rating')
  final double? avgRating;

  @JsonKey(name: 'distance_km')
  final double? distanceKm;

  final List<ShopPhoto> photos;
  final List<ShopService> services;
  final List<ShopReview> reviews;

  @JsonKey(name: 'working_days')
  final List<WorkingDay> workingDays;

  BarberDetails({
    required this.id,
    required this.name,
    this.description,
    required this.address,
    this.lat,
    this.long,
    this.avgRating,
    this.distanceKm,
    required this.photos,
    required this.services,
    required this.reviews,
    required this.workingDays,
  });

  factory BarberDetails.fromJson(Map<String, dynamic> json) =>
      _$BarberDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$BarberDetailsToJson(this);
}

@JsonSerializable()
class ShopPhoto {
  final String id;
  final String url;
  final int order;

  ShopPhoto({required this.id, required this.url, required this.order});

  factory ShopPhoto.fromJson(Map<String, dynamic> json) =>
      _$ShopPhotoFromJson(json);

  Map<String, dynamic> toJson() => _$ShopPhotoToJson(this);
}

@JsonSerializable()
class ShopService {
  final String id;
  final String name;
  final String? description;
  final double? price;

  @JsonKey(name: 'duration_minutes')
  final int? durationMinutes;

  ShopService({
    required this.id,
    required this.name,
    this.description,
    this.price,
    this.durationMinutes,
  });

  factory ShopService.fromJson(Map<String, dynamic> json) =>
      _$ShopServiceFromJson(json);

  Map<String, dynamic> toJson() => _$ShopServiceToJson(this);
}

@JsonSerializable()
class ShopReview {
  @JsonKey(name: 'reviewer_name')
  final String reviewerName;

  final double rating;
  final String? comment;

  ShopReview({required this.reviewerName, required this.rating, this.comment});

  factory ShopReview.fromJson(Map<String, dynamic> json) =>
      _$ShopReviewFromJson(json);

  Map<String, dynamic> toJson() => _$ShopReviewToJson(this);
}

@JsonSerializable()
class WorkingDay {
  @JsonKey(name: 'day_of_week')
  final int dayOfWeek;

  @JsonKey(name: 'opens_at')
  final String? opensAt;

  @JsonKey(name: 'closes_at')
  final String? closesAt;

  WorkingDay({required this.dayOfWeek, this.opensAt, this.closesAt});

  factory WorkingDay.fromJson(Map<String, dynamic> json) =>
      _$WorkingDayFromJson(json);

  Map<String, dynamic> toJson() => _$WorkingDayToJson(this);
}
