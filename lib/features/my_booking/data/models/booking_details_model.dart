class BookingDetailsModel {
  final String bookingId;
  final String shopId;
  final String shopName;
  final double? shopRating;
  final String? shopAddress;
  final double? distanceKm;
  final String? shopCover;
  final List<BookingDetailService> services;
  final int totalDuration;
  final double totalCost;
  final DateTime datetime;
  final bool canReview;
  BookingDetailsModel({
    required this.canReview,
    required this.bookingId,
    required this.shopId,
    required this.shopName,
    this.shopRating,
    this.shopAddress,
    this.distanceKm,
    this.shopCover,
    required this.services,
    required this.totalDuration,
    required this.totalCost,
    required this.datetime,
  });

  factory BookingDetailsModel.fromJson(Map<String, dynamic> json) {
    final rawServices = json['services'];
    return BookingDetailsModel(
      canReview: json['can_review'] == true || json['can_review'] == 'true',
      bookingId: _readString(json, 'booking_id'),
      shopId: _readString(json, 'shop_id'),
      shopName: _readString(json, 'shop_name'),
      shopRating: _readNullableDouble(json, 'shop_rating'),
      shopAddress: _readNullableString(json, 'shop_address'),
      distanceKm: _readNullableDouble(json, 'distance_km'),
      shopCover: json['shop_cover'] as String?,
      services: (rawServices is List ? rawServices : const <dynamic>[])
          .whereType<Map>()
          .map(
            (e) => BookingDetailService.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList(),
      totalDuration: _readInt(json, 'total_duration'),
      totalCost: _readDouble(json, 'total_cost'),
      datetime: _readDateTime(json, 'datetime'),
    );
  }

  static String _readString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is String) return value;
    return '';
  }

  static int _readInt(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static String? _readNullableString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is String && value.trim().isNotEmpty) return value;
    return null;
  }

  static double _readDouble(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static double? _readNullableDouble(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static DateTime _readDateTime(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return parsed;
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}

class BookingDetailService {
  final String name;
  final int duration;
  final double cost;

  BookingDetailService({
    required this.name,
    required this.duration,
    required this.cost,
  });

  factory BookingDetailService.fromJson(Map<String, dynamic> json) {
    return BookingDetailService(
      name: _readString(json, 'name'),
      duration: _readInt(json, 'duration'),
      cost: _readDouble(json, 'cost'),
    );
  }

  static String _readString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is String) return value;
    return '';
  }

  static int _readInt(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _readDouble(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
