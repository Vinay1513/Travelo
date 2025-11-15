import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../models/travel_info.dart';
import '../config/api_config.dart';

final dioProvider = Provider<Dio>((ref) {
  // Don't set baseUrl in Dio - let Retrofit handle it
  return Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  );
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = ref.watch(dioProvider);
  final baseUrl = ApiConfig.baseUrl;
  print('🔧 Creating ApiClient with baseUrl: $baseUrl');
  return ApiClient(dio, baseUrl: baseUrl);
});

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
      print('✅ Response received for: ${response.place}');
      return response;
    } catch (e, stackTrace) {
      print('❌ Error fetching travel info: $e');
      print('📚 Stack trace: $stackTrace');
      throw Exception('Failed to fetch travel info: $e');
    }
  },
);

class TravelInfoRequest {
  final String place;
  final String? userLocation;

  TravelInfoRequest({required this.place, this.userLocation});
}
