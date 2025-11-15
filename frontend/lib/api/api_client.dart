import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/travel_info.dart';
import '../config/api_config.dart';

part 'api_client.g.dart';

@RestApi(baseUrl: "")
abstract class ApiClient {
  factory ApiClient(Dio dio, {String? baseUrl}) = _ApiClient;

  @POST('/travel/info/')
  Future<TravelInfo> getTravelInfo(@Body() Map<String, dynamic> body);
}
