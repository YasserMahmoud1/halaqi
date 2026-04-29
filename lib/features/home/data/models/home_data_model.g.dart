// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HomeDataModel _$HomeDataModelFromJson(Map<String, dynamic> json) =>
    HomeDataModel(
      recommended: (json['recommended'] as List<dynamic>)
          .map((e) => ShopItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      nearest: (json['nearest'] as List<dynamic>)
          .map((e) => ShopItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$HomeDataModelToJson(HomeDataModel instance) =>
    <String, dynamic>{
      'recommended': instance.recommended,
      'nearest': instance.nearest,
    };

ShopItemModel _$ShopItemModelFromJson(Map<String, dynamic> json) =>
    ShopItemModel(
      shopId: json['shop_id'] as String,
      name: json['name'] as String,
      coverImage: json['cover_image'] as String?,
      avgRating: (json['avg_rating'] as num?)?.toDouble(),
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ShopItemModelToJson(ShopItemModel instance) =>
    <String, dynamic>{
      'shop_id': instance.shopId,
      'name': instance.name,
      'cover_image': instance.coverImage,
      'avg_rating': instance.avgRating,
      'distance_km': instance.distanceKm,
    };
