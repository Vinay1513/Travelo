import 'package:json_annotation/json_annotation.dart';

part 'travel_info.g.dart';

@JsonSerializable()
class TravelInfo {
  final String place;
  final String description;
  @JsonKey(defaultValue: <String>[])
  final List<String> images;
  @JsonKey(name: 'top_spots', defaultValue: <TopSpot>[])
  final List<TopSpot> topSpots;
  final Weather weather;
  @JsonKey(includeIfNull: false)
  final TravelRoute? route;
  @JsonKey(defaultValue: <Hotel>[])
  final List<Hotel> hotels;
  final String itinerary;
  @JsonKey(defaultValue: <String>[])
  final List<String> facts;

  TravelInfo({
    required this.place,
    required this.description,
    required this.images,
    required this.topSpots,
    required this.weather,
    this.route,
    required this.hotels,
    required this.itinerary,
    required this.facts,
  });

  factory TravelInfo.fromJson(Map<String, dynamic> json) =>
      _$TravelInfoFromJson(json);

  Map<String, dynamic> toJson() => _$TravelInfoToJson(this);
}

@JsonSerializable()
class TopSpot {
  final String name;
  final String info;
  @JsonKey(name: 'image_url')
  final String imageUrl;

  TopSpot({
    required this.name,
    required this.info,
    required this.imageUrl,
  });

  factory TopSpot.fromJson(Map<String, dynamic> json) =>
      _$TopSpotFromJson(json);

  Map<String, dynamic> toJson() => _$TopSpotToJson(this);
}

@JsonSerializable()
class Weather {
  final String temp;
  final String condition;
  @JsonKey(name: 'humidity')
  final String? humidity;
  @JsonKey(name: 'wind_speed')
  final String? windSpeed;
  final String? icon;

  Weather({
    required this.temp,
    required this.condition,
    this.humidity,
    this.windSpeed,
    this.icon,
  });

  factory Weather.fromJson(Map<String, dynamic> json) =>
      _$WeatherFromJson(json);

  Map<String, dynamic> toJson() => _$WeatherToJson(this);
}

@JsonSerializable()
class TravelRoute {
  @JsonKey(defaultValue: '')
  final String distance;
  @JsonKey(defaultValue: '')
  final String duration;
  @JsonKey(defaultValue: '')
  final String mode;

  TravelRoute({
    required this.distance,
    required this.duration,
    required this.mode,
  });

  factory TravelRoute.fromJson(Map<String, dynamic> json) =>
      _$TravelRouteFromJson(json);

  Map<String, dynamic> toJson() => _$TravelRouteToJson(this);
}

@JsonSerializable()
class Hotel {
  final String name;
  final String price;
  final String rating;
  final String image;

  Hotel({
    required this.name,
    required this.price,
    required this.rating,
    required this.image,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) => _$HotelFromJson(json);

  Map<String, dynamic> toJson() => _$HotelToJson(this);
}
