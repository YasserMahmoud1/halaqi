class BookingHistoryModel {
  final String shopId;
  final String shopName;
  final String? shopCover;
  final double? shopRating;
  final String bookingId;
  final DateTime datetime;
  final String status;
  final double longitude;
  final double latitude;

  BookingHistoryModel({
    required this.status,
    required this.shopId,
    required this.shopName,
    this.shopCover,
    this.shopRating,
    required this.bookingId,
    required this.datetime,
    required this.longitude,
    required this.latitude,
  });

  factory BookingHistoryModel.fromJson(Map<String, dynamic> json) {
    return BookingHistoryModel(
      status: _readString(json, 'status'),
      shopId: _readString(json, 'shop_id'),
      shopName: _readString(json, 'shop_name'),
      shopCover: json['shop_cover'] as String?,
      shopRating: _readNullableDouble(json, 'shop_rating'),
      bookingId: _readString(json, 'booking_id'),
      datetime: _readDateTime(json, 'datetime'),
      longitude: _readDouble(json, const ['long', 'longitude', 'lon']),
      latitude: _readDouble(json, const ['lat', 'lad', 'latitude']),
    );
  }

  static String _readString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is String) return value;
    return '';
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

  static double _readDouble(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is num) return value.toDouble();
      if (value is String) {
        final parsed = double.tryParse(value);
        if (parsed != null) return parsed;
      }
    }
    return 0.0;
  }
}
