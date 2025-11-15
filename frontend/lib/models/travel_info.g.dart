// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'travel_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TravelInfo _$TravelInfoFromJson(Map<String, dynamic> json) => TravelInfo(
      place: Place.fromJson(json['place'] as Map<String, dynamic>),
      description: const StringOrNullConverter().fromJson(json['description']),
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => TravelImage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      topSpots: (json['top_spots'] as List<dynamic>?)
              ?.map((e) => TopSpot.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      weather: json['weather'] == null
          ? null
          : Weather.fromJson(json['weather'] as Map<String, dynamic>),
      route: json['route'] == null
          ? null
          : TravelRoute.fromJson(json['route'] as Map<String, dynamic>),
      hotels: (json['hotels'] as List<dynamic>?)
              ?.map((e) => Hotel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      itinerary: const StringOrNullConverter().fromJson(json['itinerary']),
      facts: (json['facts'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );

Map<String, dynamic> _$TravelInfoToJson(TravelInfo instance) =>
    <String, dynamic>{
      'place': instance.place,
      'description': const StringOrNullConverter().toJson(instance.description),
      'images': instance.images,
      'top_spots': instance.topSpots,
      if (instance.weather case final value?) 'weather': value,
      if (instance.route case final value?) 'route': value,
      'hotels': instance.hotels,
      'itinerary': const StringOrNullConverter().toJson(instance.itinerary),
      'facts': instance.facts,
    };

// ------------------------------ PLACE ------------------------------------

Place _$PlaceFromJson(Map<String, dynamic> json) => Place(
      name: json['name'] as String,
      formattedAddress:
          const StringOrNullConverter().fromJson(json['formatted_address']),
      coordinates: json['coordinates'] == null
          ? null
          : Coordinates.fromJson(json['coordinates'] as Map<String, dynamic>),
      details: json['details'] == null
          ? null
          : PlaceDetails.fromJson(json['details'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PlaceToJson(Place instance) => <String, dynamic>{
      'name': instance.name,
      'formatted_address':
          const StringOrNullConverter().toJson(instance.formattedAddress),
      'coordinates': instance.coordinates,
      'details': instance.details,
    };

// ------------------------------ COORDINATES ------------------------------

Coordinates _$CoordinatesFromJson(Map<String, dynamic> json) => Coordinates(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );

Map<String, dynamic> _$CoordinatesToJson(Coordinates instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };

// ------------------------------ DETAILS ----------------------------------

PlaceDetails _$PlaceDetailsFromJson(Map<String, dynamic> json) => PlaceDetails(
      totalPlaces: (json['total_places'] as num?)?.toInt(),
      categories: (json['categories'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
    );

Map<String, dynamic> _$PlaceDetailsToJson(PlaceDetails instance) =>
    <String, dynamic>{
      'total_places': instance.totalPlaces,
      'categories': instance.categories,
    };

// ------------------------------ IMAGE ------------------------------------

TravelImage _$TravelImageFromJson(Map<String, dynamic> json) => TravelImage(
      id: json['id'].toString(),
      url: json['url'].toString(),
      thumb: json['thumb'].toString(),
      full: json['full'].toString(),
      photographer:
          const StringOrNullConverter().fromJson(json['photographer']),
      photographerUrl:
          const StringOrNullConverter().fromJson(json['photographer_url']),
    );

Map<String, dynamic> _$TravelImageToJson(TravelImage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'thumb': instance.thumb,
      'full': instance.full,
      'photographer':
          const StringOrNullConverter().toJson(instance.photographer),
      'photographer_url':
          const StringOrNullConverter().toJson(instance.photographerUrl),
    };

// ------------------------------ TOP SPOT ---------------------------------

TopSpot _$TopSpotFromJson(Map<String, dynamic> json) => TopSpot(
      name: json['name'] as String,
      info: const StringOrNullConverter().fromJson(json['info']),
      imageUrl: const StringOrNullConverter().fromJson(json['image_url']),
    );

Map<String, dynamic> _$TopSpotToJson(TopSpot instance) => <String, dynamic>{
      'name': instance.name,
      'info': const StringOrNullConverter().toJson(instance.info),
      'image_url': const StringOrNullConverter().toJson(instance.imageUrl),
    };

// ------------------------------ WEATHER ----------------------------------

// ------------------------------ WEATHER ----------------------------------
Weather _$WeatherFromJson(Map<String, dynamic> json) => Weather(
      temperature: (json['temperature'] is num)
          ? (json['temperature'] as num).toDouble()
          : double.tryParse(json['temperature'].toString()),
      feelsLike: (json['feels_like'] is num)
          ? (json['feels_like'] as num).toDouble()
          : double.tryParse(json['feels_like'].toString()),
      humidity: json['humidity'] is num
          ? (json['humidity'] as num).toInt()
          : int.tryParse(json['humidity'].toString()),
      description: json['description']?.toString(),
      icon: json['icon']?.toString(),
      windSpeed: (json['wind_speed'] is num)
          ? (json['wind_speed'] as num).toDouble()
          : double.tryParse(json['wind_speed'].toString()),
      pressure: json['pressure'] is num
          ? (json['pressure'] as num).toInt()
          : int.tryParse(json['pressure'].toString()),
    );

Map<String, dynamic> _$WeatherToJson(Weather instance) => <String, dynamic>{
      'temperature': instance.temperature,
      'feels_like': instance.feelsLike,
      'humidity': instance.humidity,
      'description': instance.description,
      'icon': instance.icon,
      'wind_speed': instance.windSpeed,
      'pressure': instance.pressure,
    };

// ------------------------------ ROUTE ------------------------------------

TravelRoute _$TravelRouteFromJson(Map<String, dynamic> json) => TravelRoute(
      distance: const StringOrNullConverter().fromJson(json['distance']),
      duration: const StringOrNullConverter().fromJson(json['duration']),
      mode: const StringOrNullConverter().fromJson(json['mode']),
    );

Map<String, dynamic> _$TravelRouteToJson(TravelRoute instance) =>
    <String, dynamic>{
      'distance': const StringOrNullConverter().toJson(instance.distance),
      'duration': const StringOrNullConverter().toJson(instance.duration),
      'mode': const StringOrNullConverter().toJson(instance.mode),
    };

// ------------------------------ HOTEL ------------------------------------

Hotel _$HotelFromJson(Map<String, dynamic> json) => Hotel(
      name: json['name'].toString(),
      price: const StringOrNullConverter().fromJson(json['price']),
      rating: const StringOrNullConverter().fromJson(json['rating']),
      image: json['image'].toString(),
    );

Map<String, dynamic> _$HotelToJson(Hotel instance) => <String, dynamic>{
      'name': instance.name,
      'price': const StringOrNullConverter().toJson(instance.price),
      'rating': const StringOrNullConverter().toJson(instance.rating),
      'image': instance.image,
    };
Attraction _$AttractionFromJson(Map<String, dynamic> json) => Attraction(
      name: json['name'] as String,
      category: (json['category'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      address: json['address']?.toString(),
      coordinates: json['coordinates'] == null
          ? null
          : Coordinates.fromJson(json['coordinates'] as Map<String, dynamic>),
      distance: json['distance'] == null
          ? null
          : (json['distance'] is num
              ? (json['distance'] as num).toDouble()
              : double.tryParse(json['distance'].toString())),
      placeId: json['place_id']?.toString(),
    );

Map<String, dynamic> _$AttractionToJson(Attraction instance) =>
    <String, dynamic>{
      'name': instance.name,
      'category': instance.category,
      'address': instance.address,
      'coordinates': instance.coordinates?.toJson(),
      'distance': instance.distance,
      'place_id': instance.placeId,
    };
