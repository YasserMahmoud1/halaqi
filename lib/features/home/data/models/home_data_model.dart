import 'package:json_annotation/json_annotation.dart';

part 'home_data_model.g.dart';

@JsonSerializable()
class HomeDataModel {
  final List<ShopItemModel> recommended;
  final List<ShopItemModel> nearest;

  HomeDataModel({required this.recommended, required this.nearest});

  factory HomeDataModel.fromJson(Map<String, dynamic> json) =>
      _$HomeDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$HomeDataModelToJson(this);
}

@JsonSerializable()
class ShopItemModel {
  @JsonKey(name: 'shop_id')
  final String shopId;

  final String name;

  @JsonKey(name: 'cover_image')
  final String? coverImage;

  @JsonKey(name: 'avg_rating')
  final double? avgRating;

  @JsonKey(name: 'distance_km')
  final double? distanceKm;

  ShopItemModel({
    required this.shopId,
    required this.name,
    this.coverImage,
    required this.avgRating,
    this.distanceKm,
  });

  factory ShopItemModel.fromJson(Map<String, dynamic> json) =>
      _$ShopItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$ShopItemModelToJson(this);
}
