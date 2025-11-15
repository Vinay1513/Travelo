// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'travel_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TravelInfo _$TravelInfoFromJson(Map<String, dynamic> json) => TravelInfo(
      place: json['place'] as String,
      description: json['description'] as String,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      topSpots: (json['top_spots'] as List<dynamic>?)
              ?.map((e) => TopSpot.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      weather: Weather.fromJson(json['weather'] as Map<String, dynamic>),
      route: json['route'] == null
          ? null
          : TravelRoute.fromJson(json['route'] as Map<String, dynamic>),
      hotels: (json['hotels'] as List<dynamic>?)
              ?.map((e) => Hotel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      itinerary: json['itinerary'] as String,
      facts:
          (json['facts'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              [],
    );

Map<String, dynamic> _$TravelInfoToJson(TravelInfo instance) =>
    <String, dynamic>{
      'place': instance.place,
      'description': instance.description,
      'images': instance.images,
      'top_spots': instance.topSpots,
      'weather': instance.weather,
      if (instance.route case final value?) 'route': value,
      'hotels': instance.hotels,
      'itinerary': instance.itinerary,
      'facts': instance.facts,
    };

TopSpot _$TopSpotFromJson(Map<String, dynamic> json) => TopSpot(
      name: json['name'] as String,
      info: json['info'] as String,
      imageUrl: json['image_url'] as String,
    );

Map<String, dynamic> _$TopSpotToJson(TopSpot instance) => <String, dynamic>{
      'name': instance.name,
      'info': instance.info,
      'image_url': instance.imageUrl,
    };

Weather _$WeatherFromJson(Map<String, dynamic> json) => Weather(
      temp: json['temp'] as String,
      condition: json['condition'] as String,
      humidity: json['humidity'] as String?,
      windSpeed: json['wind_speed'] as String?,
      icon: json['icon'] as String?,
    );

Map<String, dynamic> _$WeatherToJson(Weather instance) => <String, dynamic>{
      'temp': instance.temp,
      'condition': instance.condition,
      'humidity': instance.humidity,
      'wind_speed': instance.windSpeed,
      'icon': instance.icon,
    };

TravelRoute _$TravelRouteFromJson(Map<String, dynamic> json) => TravelRoute(
      distance: json['distance'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
      mode: json['mode'] as String? ?? '',
    );

Map<String, dynamic> _$TravelRouteToJson(TravelRoute instance) =>
    <String, dynamic>{
      'distance': instance.distance,
      'duration': instance.duration,
      'mode': instance.mode,
    };

Hotel _$HotelFromJson(Map<String, dynamic> json) => Hotel(
      name: json['name'] as String,
      price: json['price'] as String,
      rating: json['rating'] as String,
      image: json['image'] as String,
    );

Map<String, dynamic> _$HotelToJson(Hotel instance) => <String, dynamic>{
      'name': instance.name,
      'price': instance.price,
      'rating': instance.rating,
      'image': instance.image,
    };
