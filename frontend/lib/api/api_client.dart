import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/travel_info.dart';

part 'api_client.g.dart';

@RestApi(baseUrl: "")
abstract class ApiClient {
  factory ApiClient(Dio dio, {String? baseUrl}) = _ApiClient;

  @POST('/travel/info/')
  Future<TravelInfo> getTravelInfo(@Body() Map<String, dynamic> body);

  @GET('/restaurants/')
  Future<Map<String, dynamic>> getRestaurants(
    @Query('lat') double latitude,
    @Query('lon') double longitude,
    @Query('limit') int limit,
    @Query('radius') int radius,
  );

  @GET('/hotels/')
  Future<Map<String, dynamic>> getHotels(
    @Query('place') String? place,
    @Query('lat') double? latitude,
    @Query('lon') double? longitude,
    @Query('limit') int limit,
  );
}

// Dio interceptor for logging
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('🚀 REQUEST[${options.method}] => PATH: ${options.path}');
    print('📤 Data: ${options.data}');
    print('🔑 Headers: ${options.headers}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print(
        '✅ RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    print('📥 Data: ${response.data}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print(
        '❌ ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
    print('💥 Message: ${err.message}');
    print('📛 Response: ${err.response?.data}');
    super.onError(err, handler);
  }
}
