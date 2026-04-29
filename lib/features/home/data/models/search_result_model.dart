import 'package:json_annotation/json_annotation.dart';

part 'search_result_model.g.dart';

@JsonSerializable()
class SearchResultsModel {
  final List<SearchShopItemModel> results;

  SearchResultsModel({required this.results});

  factory SearchResultsModel.fromJson(Map<String, dynamic> json) =>
      _$SearchResultsModelFromJson(json);

  Map<String, dynamic> toJson() => _$SearchResultsModelToJson(this);
}

@JsonSerializable()
class SearchShopItemModel {
  @JsonKey(name: 'shop_id')
  final String shopId;

  final String name;

  @JsonKey(name: 'cover_image')
  final String? coverImage;

  @JsonKey(name: 'avg_rating')
  final double? avgRating;

  @JsonKey(name: 'distance_km', defaultValue: 0.0)
  final double distanceKm;

  SearchShopItemModel({
    required this.shopId,
    required this.name,
    this.coverImage,
    this.avgRating,
    required this.distanceKm,
  });

  factory SearchShopItemModel.fromJson(Map<String, dynamic> json) =>
      _$SearchShopItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$SearchShopItemModelToJson(this);
}
