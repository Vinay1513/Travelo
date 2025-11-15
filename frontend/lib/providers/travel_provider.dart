import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../models/travel_info.dart';
import '../config/api_config.dart';

// Dio Provider with logging
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Add logging interceptor
  dio.interceptors.add(LoggingInterceptor());

  return dio;
});

// API Client Provider
final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = ref.watch(dioProvider);
  final baseUrl = ApiConfig.baseUrl;
  print('🔧 Creating ApiClient with baseUrl: $baseUrl');
  return ApiClient(dio, baseUrl: baseUrl);
});

// Travel Info Provider
final travelInfoProvider = FutureProvider.family<TravelInfo, TravelInfoRequest>(
  (ref, request) async {
    final apiClient = ref.watch(apiClientProvider);
    try {
      print('🌍 Fetching travel info for: ${request.place}');
      print('📡 API Base URL: ${ApiConfig.baseUrl}');

      final requestBody = {
        'place': request.place,
        if (request.userLocation != null) 'user_location': request.userLocation,
      };
      print('📤 Request body: $requestBody');

      final response = await apiClient.getTravelInfo(requestBody);
      return response;
    } on DioException catch (e) {
      print('❌ DioException: ${e.message}');
      print('📛 Response data: ${e.response?.data}');
      print('📛 Status code: ${e.response?.statusCode}');

      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception(
            'Connection timeout. Please check your internet connection.');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Server is taking too long to respond.');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Place not found. Try a different search.');
      } else if (e.response?.statusCode == 500) {
        throw Exception('Server error. Please try again later.');
      } else {
        throw Exception('Failed to fetch travel info: ${e.message}');
      }
    } catch (e, stackTrace) {
      print('❌ Unexpected error: $e');
      print('📚 Stack trace: $stackTrace');
      throw Exception('An unexpected error occurred: $e');
    }
  },
);

// Restaurants Provider
final restaurantsProvider =
    FutureProvider.family<Map<String, dynamic>, RestaurantRequest>(
  (ref, request) async {
    final apiClient = ref.watch(apiClientProvider);
    try {
      print(
          '🍽️ Fetching restaurants near: (${request.latitude}, ${request.longitude})');

      final response = await apiClient.getRestaurants(
        request.latitude,
        request.longitude,
        request.limit,
        request.radius,
      );

      print('✅ Found ${response['total']} restaurants');
      return response;
    } catch (e) {
      print('❌ Error fetching restaurants: $e');
      throw Exception('Failed to fetch restaurants: $e');
    }
  },
);

// Hotels Provider
final hotelsProvider =
    FutureProvider.family<Map<String, dynamic>, HotelRequest>(
  (ref, request) async {
    final apiClient = ref.watch(apiClientProvider);
    try {
      print(
          '🏨 Fetching hotels for: ${request.place ?? '(${request.latitude}, ${request.longitude})'}');

      final response = await apiClient.getHotels(
        request.place,
        request.latitude,
        request.longitude,
        request.limit,
      );

      print('✅ Found ${response['total']} hotels');
      return response;
    } catch (e) {
      print('❌ Error fetching hotels: $e');
      throw Exception('Failed to fetch hotels: $e');
    }
  },
);

// Request Models
class TravelInfoRequest {
  final String place;
  final String? userLocation;

  TravelInfoRequest({
    required this.place,
    this.userLocation,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TravelInfoRequest &&
          runtimeType == other.runtimeType &&
          place == other.place &&
          userLocation == other.userLocation;

  @override
  int get hashCode => place.hashCode ^ userLocation.hashCode;
}

class RestaurantRequest {
  final double latitude;
  final double longitude;
  final int limit;
  final int radius;

  RestaurantRequest({
    required this.latitude,
    required this.longitude,
    this.limit = 20,
    this.radius = 5000,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RestaurantRequest &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          limit == other.limit &&
          radius == other.radius;

  @override
  int get hashCode =>
      latitude.hashCode ^ longitude.hashCode ^ limit.hashCode ^ radius.hashCode;
}

class HotelRequest {
  final String? place;
  final double? latitude;
  final double? longitude;
  final int limit;

  HotelRequest({
    this.place,
    this.latitude,
    this.longitude,
    this.limit = 10,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HotelRequest &&
          runtimeType == other.runtimeType &&
          place == other.place &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          limit == other.limit;

  @override
  int get hashCode =>
      place.hashCode ^ latitude.hashCode ^ longitude.hashCode ^ limit.hashCode;
}
