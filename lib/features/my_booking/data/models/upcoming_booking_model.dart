class UpcomingBooking {
  final String bookingId;
  final String shopName;
  final String shopId;
  final double shopRating;
  final String shopAddress;
  final String? shopCover;
  final double longitude;
  final double latitude;
  final String status;
  final DateTime dateAndTime;
  final List<BookingServiceSnapshot> services;

  UpcomingBooking({
    required this.bookingId,
    required this.shopName,
    required this.shopId,
    required this.shopRating,
    required this.shopAddress,
    this.shopCover,
    required this.longitude,
    required this.latitude,
    required this.dateAndTime,
    required this.services,
    required this.status,
  });

  factory UpcomingBooking.fromJson(Map<String, dynamic> json) {
    final rawServices = json['services'];
    return UpcomingBooking(
      status: _readString(json, 'status'),
      bookingId: _readString(json, 'booking_id'),
      shopName: _readString(json, 'shop_name'),
      shopId: _readString(json, 'shop_id'),
      shopRating: _readDouble(json, const ['shop_rating']),
      shopAddress: _readString(json, 'shop_address'),
      shopCover: json['shop_cover'] as String?,
      longitude: _readDouble(json, const ['long', 'longitude', 'lon']),
      latitude: _readDouble(json, const ['lat', 'lad', 'latitude']),
      dateAndTime: _readDateTime(json, 'date_and_time'),
      services: (rawServices is List ? rawServices : const <dynamic>[])
          .whereType<Map>()
          .map(
            (e) =>
                BookingServiceSnapshot.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList(),
    );
  }

  static String _readString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is String) return value;
    return '';
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

class BookingServiceSnapshot {
  final String serviceName;
  final int serviceDuration;
  final double servicePrice;

  BookingServiceSnapshot({
    required this.servicePrice,
    required this.serviceName,
    required this.serviceDuration,
  });

  factory BookingServiceSnapshot.fromJson(Map<String, dynamic> json) {
    return BookingServiceSnapshot(
      servicePrice: _readDouble(json, 'service_price'),
      serviceName: _readString(json, 'service_name'),
      serviceDuration: _readInt(json, 'service_duration'),
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
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
}
