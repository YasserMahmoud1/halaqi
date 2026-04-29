// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'barber_details_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BarberDetailsResponse _$BarberDetailsResponseFromJson(
  Map<String, dynamic> json,
) => BarberDetailsResponse(
  shop: BarberDetails.fromJson(json['shop'] as Map<String, dynamic>),
);

Map<String, dynamic> _$BarberDetailsResponseToJson(
  BarberDetailsResponse instance,
) => <String, dynamic>{'shop': instance.shop};

BarberDetails _$BarberDetailsFromJson(Map<String, dynamic> json) =>
    BarberDetails(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      address: json['address'] as String,
      lat: (json['lat'] as num?)?.toDouble(),
      long: (json['long'] as num?)?.toDouble(),
      avgRating: (json['avg_rating'] as num?)?.toDouble(),
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      photos: (json['photos'] as List<dynamic>)
          .map((e) => ShopPhoto.fromJson(e as Map<String, dynamic>))
          .toList(),
      services: (json['services'] as List<dynamic>)
          .map((e) => ShopService.fromJson(e as Map<String, dynamic>))
          .toList(),
      reviews: (json['reviews'] as List<dynamic>)
          .map((e) => ShopReview.fromJson(e as Map<String, dynamic>))
          .toList(),
      workingDays: (json['working_days'] as List<dynamic>)
          .map((e) => WorkingDay.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$BarberDetailsToJson(BarberDetails instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'address': instance.address,
      'lat': instance.lat,
      'long': instance.long,
      'avg_rating': instance.avgRating,
      'distance_km': instance.distanceKm,
      'photos': instance.photos,
      'services': instance.services,
      'reviews': instance.reviews,
      'working_days': instance.workingDays,
    };

ShopPhoto _$ShopPhotoFromJson(Map<String, dynamic> json) => ShopPhoto(
  id: json['id'] as String,
  url: json['url'] as String,
  order: (json['order'] as num).toInt(),
);

Map<String, dynamic> _$ShopPhotoToJson(ShopPhoto instance) => <String, dynamic>{
  'id': instance.id,
  'url': instance.url,
  'order': instance.order,
};

ShopService _$ShopServiceFromJson(Map<String, dynamic> json) => ShopService(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  price: (json['price'] as num?)?.toDouble(),
  durationMinutes: (json['duration_minutes'] as num?)?.toInt(),
);

Map<String, dynamic> _$ShopServiceToJson(ShopService instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'duration_minutes': instance.durationMinutes,
    };

ShopReview _$ShopReviewFromJson(Map<String, dynamic> json) => ShopReview(
  reviewerName: json['reviewer_name'] as String,
  rating: (json['rating'] as num).toDouble(),
  comment: json['comment'] as String?,
);

Map<String, dynamic> _$ShopReviewToJson(ShopReview instance) =>
    <String, dynamic>{
      'reviewer_name': instance.reviewerName,
      'rating': instance.rating,
      'comment': instance.comment,
    };

WorkingDay _$WorkingDayFromJson(Map<String, dynamic> json) => WorkingDay(
  dayOfWeek: (json['day_of_week'] as num).toInt(),
  opensAt: json['opens_at'] as String?,
  closesAt: json['closes_at'] as String?,
);

Map<String, dynamic> _$WorkingDayToJson(WorkingDay instance) =>
    <String, dynamic>{
      'day_of_week': instance.dayOfWeek,
      'opens_at': instance.opensAt,
      'closes_at': instance.closesAt,
    };
