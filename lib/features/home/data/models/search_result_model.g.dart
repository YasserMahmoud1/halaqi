// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_result_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchResultsModel _$SearchResultsModelFromJson(Map<String, dynamic> json) =>
    SearchResultsModel(
      results: (json['results'] as List<dynamic>)
          .map((e) => SearchShopItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SearchResultsModelToJson(SearchResultsModel instance) =>
    <String, dynamic>{'results': instance.results};

SearchShopItemModel _$SearchShopItemModelFromJson(Map<String, dynamic> json) =>
    SearchShopItemModel(
      shopId: json['shop_id'] as String,
      name: json['name'] as String,
      coverImage: json['cover_image'] as String?,
      avgRating: (json['avg_rating'] as num?)?.toDouble(),
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$SearchShopItemModelToJson(
  SearchShopItemModel instance,
) => <String, dynamic>{
  'shop_id': instance.shopId,
  'name': instance.name,
  'cover_image': instance.coverImage,
  'avg_rating': instance.avgRating,
  'distance_km': instance.distanceKm,
};
