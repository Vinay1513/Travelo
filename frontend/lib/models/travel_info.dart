import 'package:json_annotation/json_annotation.dart';

part 'travel_info.g.dart';

// --------------------
// GLOBAL STRING CONVERTER
// --------------------
class StringOrNullConverter implements JsonConverter<String?, dynamic> {
  const StringOrNullConverter();

  @override
  String? fromJson(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }

  @override
  dynamic toJson(String? value) => value;
}

// ---------------------------------------------------
// TRAVEL INFO MODEL
// ---------------------------------------------------

@JsonSerializable()
class TravelInfo {
  final Place place;

  @StringOrNullConverter()
  final String? description;

  final List<TravelImage> images;
  final List<TopSpot> topSpots;
  final Weather? weather;
  final TravelRoute? route;
  final List<Hotel> hotels;

  final List<Attraction> attractions;

  final double? timestamp;

  @StringOrNullConverter()
  final String? itinerary;

  final List<String> facts;

  TravelInfo({
    required this.place,
    this.description,
    this.images = const [],
    this.topSpots = const [],
    this.weather,
    this.route,
    this.hotels = const [],
    this.attractions = const [],
    this.timestamp,
    this.itinerary,
    this.facts = const [],
  });

  factory TravelInfo.fromJson(Map<String, dynamic> json) =>
      _$TravelInfoFromJson(json);

  Map<String, dynamic> toJson() => _$TravelInfoToJson(this);
}

// ---------------------------------------------------
// PLACE
// ---------------------------------------------------

@JsonSerializable()
class Place {
  final String name;

  @JsonKey(name: "formatted_address")
  @StringOrNullConverter()
  final String? formattedAddress;

  final Coordinates? coordinates;
  final PlaceDetails? details;

  Place({
    required this.name,
    this.formattedAddress,
    this.coordinates,
    this.details,
  });

  factory Place.fromJson(Map<String, dynamic> json) => _$PlaceFromJson(json);

  Map<String, dynamic> toJson() => _$PlaceToJson(this);
}

// ---------------------------------------------------
// COORDINATES
// ---------------------------------------------------

@JsonSerializable()
class Coordinates {
  final double latitude;
  final double longitude;

  Coordinates({
    required this.latitude,
    required this.longitude,
  });

  factory Coordinates.fromJson(Map<String, dynamic> json) =>
      _$CoordinatesFromJson(json);

  Map<String, dynamic> toJson() => _$CoordinatesToJson(this);
}

// ---------------------------------------------------
// PLACE DETAILS
// ---------------------------------------------------

@JsonSerializable()
class PlaceDetails {
  final int? totalPlaces;
  final List<String>? categories;

  PlaceDetails({
    this.totalPlaces,
    this.categories,
  });

  factory PlaceDetails.fromJson(Map<String, dynamic> json) =>
      _$PlaceDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$PlaceDetailsToJson(this);
}

// ---------------------------------------------------
// IMAGE
// ---------------------------------------------------

@JsonSerializable()
class TravelImage {
  final String id;
  final String url;
  final String thumb;
  final String full;

  @StringOrNullConverter()
  final String? photographer;

  @JsonKey(name: 'photographer_url')
  @StringOrNullConverter()
  final String? photographerUrl;

  TravelImage({
    required this.id,
    required this.url,
    required this.thumb,
    required this.full,
    this.photographer,
    this.photographerUrl,
  });

  factory TravelImage.fromJson(Map<String, dynamic> json) =>
      _$TravelImageFromJson(json);

  Map<String, dynamic> toJson() => _$TravelImageToJson(this);
}

// ---------------------------------------------------
// ATTRACTION
// ---------------------------------------------------

@JsonSerializable()
class Attraction {
  final String name;

  final List<String>? category;

  final String? address;

  final Coordinates? coordinates;

  @JsonKey(name: 'distance')
  final double? distance;

  @JsonKey(name: 'place_id')
  final String? placeId;

  Attraction({
    required this.name,
    this.category,
    this.address,
    this.coordinates,
    this.distance,
    this.placeId,
  });

  factory Attraction.fromJson(Map<String, dynamic> json) =>
      _$AttractionFromJson(json);

  Map<String, dynamic> toJson() => _$AttractionToJson(this);
}

// ---------------------------------------------------
// TOP SPOT
// ---------------------------------------------------

@JsonSerializable()
class TopSpot {
  final String name;

  @StringOrNullConverter()
  final String? info;

  @JsonKey(name: "image_url")
  @StringOrNullConverter()
  final String? imageUrl;

  TopSpot({
    required this.name,
    this.info,
    this.imageUrl,
  });

  factory TopSpot.fromJson(Map<String, dynamic> json) =>
      _$TopSpotFromJson(json);

  Map<String, dynamic> toJson() => _$TopSpotToJson(this);
}

// ---------------------------------------------------
// WEATHER
// ---------------------------------------------------
class DoubleOrNullConverter implements JsonConverter<double?, dynamic> {
  const DoubleOrNullConverter();

  @override
  double? fromJson(dynamic value) {
    if (value == null) return null;

    if (value is num) return value.toDouble();

    return double.tryParse(value.toString());
  }

  @override
  dynamic toJson(double? value) => value;
}

@JsonSerializable()
class Weather {
  @JsonKey(name: 'temperature')
  @DoubleOrNullConverter()
  final double? temperature;

  @JsonKey(name: 'feels_like')
  @DoubleOrNullConverter()
  final double? feelsLike;

  final int? humidity;

  @JsonKey(name: 'description')
  final String? description;

  final String? icon;

  @JsonKey(name: 'wind_speed')
  @DoubleOrNullConverter()
  final double? windSpeed;

  final int? pressure;

  Weather({
    this.temperature,
    this.feelsLike,
    this.humidity,
    this.description,
    this.icon,
    this.windSpeed,
    this.pressure,
  });

  factory Weather.fromJson(Map<String, dynamic> json) =>
      _$WeatherFromJson(json);

  Map<String, dynamic> toJson() => _$WeatherToJson(this);
}

// ---------------------------------------------------
// TRAVEL ROUTE
// ---------------------------------------------------

@JsonSerializable()
class TravelRoute {
  @StringOrNullConverter()
  final String? distance;

  @StringOrNullConverter()
  final String? duration;

  @StringOrNullConverter()
  final String? mode;

  TravelRoute({
    this.distance,
    this.duration,
    this.mode,
  });

  factory TravelRoute.fromJson(Map<String, dynamic> json) =>
      _$TravelRouteFromJson(json);

  Map<String, dynamic> toJson() => _$TravelRouteToJson(this);
}

// ---------------------------------------------------
// HOTEL
// ---------------------------------------------------

@JsonSerializable()
class Hotel {
  final String name;

  @StringOrNullConverter()
  final String? price;

  @StringOrNullConverter()
  final String? rating;

  @StringOrNullConverter()
  final String? address;

  final Coordinates? coordinates;

  final List<String>? categories;

  @JsonKey(name: 'place_id')
  final String? placeId;

  @StringOrNullConverter()
  final String? website;

  final String? image;

  Hotel({
    required this.name,
    this.price,
    this.rating,
    this.address,
    this.coordinates,
    this.categories,
    this.placeId,
    this.website,
    this.image,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) => _$HotelFromJson(json);

  Map<String, dynamic> toJson() => _$HotelToJson(this);
}
