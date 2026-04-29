import 'package:flutter/foundation.dart';

class ShopModel {
  final String id;
  final String name;
  final String address; // Derived from city or specific address field
  final String? imageUrl;
  final double rating;
  final double? distance;
  final double? lat;
  final double? long;

  ShopModel({
    required this.id,
    required this.name,
    required this.address,
    this.imageUrl,
    required this.rating,
    this.distance,
    this.lat,
    this.long,
  });

  ShopModel copyWith({double? distance}) {
    return ShopModel(
      id: id,
      name: name,
      address: address,
      imageUrl: imageUrl,
      rating: rating,
      distance: distance ?? this.distance,
      lat: lat,
      long: long,
    );
  }

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Unknown Shop',
      address: _parseAddress(json),
      imageUrl: _parseImage(json),
      rating: _parseRating(json),
      distance: (json['dist_meters'] as num?)?.toDouble() != null
          ? (json['dist_meters'] as num).toDouble() / 1000.0
          : null,
      lat: _parseLatitude(json),
      long: _parseLongitude(json),
    );
  }

  static String _parseAddress(Map<String, dynamic> json) {
    if (json['address_text'] != null &&
        json['address_text'].toString().isNotEmpty) {
      return json['address_text'].toString();
    }
    if (json['cities'] != null &&
        json['cities'] is List &&
        (json['cities'] as List).isNotEmpty) {
      return (json['cities'] as List).join(', ');
    }
    return json['city'] as String? ?? '';
  }

  static String? _parseImage(Map<String, dynamic> json) {
    if (json['shop_images'] != null &&
        (json['shop_images'] as List).isNotEmpty) {
      return (json['shop_images'] as List)[0]['image_url'];
    }
    return null;
  }

  static double _parseRating(Map<String, dynamic> json) {
    // 1. Try direct field
    if (json['average_rating'] != null) {
      return (json['average_rating'] as num).toDouble();
    }

    // 2. Calculate from direct reviews relationship (Preferred)
    if (json['reviews'] != null && (json['reviews'] as List).isNotEmpty) {
      final reviews = json['reviews'] as List;
      double total = 0;
      int count = 0;
      for (var r in reviews) {
        if (r['rating'] != null) {
          total += (r['rating'] as num).toDouble();
          count++;
        }
      }
      if (count > 0) {
        return double.parse((total / count).toStringAsFixed(1));
      }
    }

    // 3. Calculate from nested bookings -> reviews (Fallback)
    if (json['bookings'] != null && (json['bookings'] as List).isNotEmpty) {
      final bookings = json['bookings'] as List;
      double total = 0;
      int count = 0;
      for (var booking in bookings) {
        final reviews = booking['reviews'];
        if (reviews != null) {
          if (reviews is List) {
            for (var r in reviews) {
              if (r['rating'] != null) {
                total += (r['rating'] as num).toDouble();
                count++;
              }
            }
          } else if (reviews is Map) {
            if (reviews['rating'] != null) {
              total += (reviews['rating'] as num).toDouble();
              count++;
            }
          }
        }
      }
      if (count > 0) {
        return double.parse((total / count).toStringAsFixed(1));
      }
    }
    return 0.0;
  }

  static double? _parseLatitude(Map<String, dynamic> json) {
    // Try explicit lat field
    if (json['lat'] != null) return (json['lat'] as num).toDouble();
    if (json['latitude'] != null) return (json['latitude'] as num).toDouble();

    // Parse from Geometry
    return _parseGeometry(json, isLat: true);
  }

  static double? _parseLongitude(Map<String, dynamic> json) {
    // Try explicit long field
    if (json['long'] != null) return (json['long'] as num).toDouble();
    if (json['longitude'] != null) return (json['longitude'] as num).toDouble();

    // Parse from Geometry
    return _parseGeometry(json, isLat: false);
  }

  static double? _parseGeometry(
    Map<String, dynamic> json, {
    required bool isLat,
  }) {
    // Check multiple keys
    final geo = json['location_geo'] ?? json['location'];

    if (geo == null) return null;

    if (geo is String) {
      // Handle WKT: POINT(long lat)
      if (geo.trim().toUpperCase().startsWith('POINT')) {
        try {
          final clean = geo.replaceAll(RegExp(r'[^\d\.\s\-]'), '').trim();
          final parts = clean.split(RegExp(r'\s+'));
          if (parts.length >= 2) {
            final long = double.parse(parts[0]);
            final lat = double.parse(parts[1]);
            return isLat ? lat : long;
          }
        } catch (e) {
          debugPrint('Error parsing POINT: $e');
        }
      }
    } else if (geo is Map) {
      // Handle GeoJSON: { "type": "Point", "coordinates": [long, lat] }
      try {
        if (geo['coordinates'] is List) {
          final coords = geo['coordinates'] as List;
          if (coords.length >= 2) {
            final long = (coords[0] as num).toDouble();
            final lat = (coords[1] as num).toDouble();
            return isLat ? lat : long;
          }
        }
      } catch (e) {
        debugPrint('Error parsing GeoJSON: $e');
      }
    }
    return null;
  }
}
