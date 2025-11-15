import requests
import logging
from django.conf import settings
from django.core.cache import cache
from typing import Dict, List, Optional
import time

logger = logging.getLogger(__name__)


class TravelService:
    """
    Professional service for handling travel information using multiple free APIs:
    - Geoapify for geocoding and places
    - Unsplash for high-quality images
    - OpenWeatherMap for weather data
    - OpenRouteService for distances and directions
    """

    def __init__(self):
        self.geoapify_key = settings.GEOPI_API_KEY
        self.unsplash_key = settings.UNSPLASH_ACCESS_KEY
        self.weather_key = settings.OPENWEATHER_API_KEY
        self.routing_key = settings.OPENROUTESERVICE_API_KEY
        self.session = requests.Session()
        self.session.headers.update({'User-Agent': 'TravelAI/1.0'})

    def get_travel_info(self, place: str, user_location: Optional[str] = None) -> Dict:
        """
        Get comprehensive travel information for a place.
        
        Args:
            place: Destination place name
            user_location: User's current location (optional)
            
        Returns:
            Dict containing all travel information
        """
        try:
            # 1. Get place coordinates and details
            place_data = self._geocode_place(place)
            if not place_data:
                return {'error': 'Place not found'}

            lat, lon = place_data['lat'], place_data['lon']
            
            # 2. Get place images
            images = self._get_place_images(place, limit=10)
            
            # 3. Get weather information
            weather = self._get_weather(lat, lon)
            
            # 4. Get nearby attractions
            attractions = self._get_nearby_attractions(lat, lon, limit=15)
            
            # 5. Calculate distance if user location provided
            distance_info = None
            if user_location:
                distance_info = self._calculate_distance(user_location, place)
            
            # 6. Get place categories and details
            place_details = self._get_place_details(place, lat, lon)

            return {
                'place': {
                    'name': place_data.get('name', place),
                    'formatted_address': place_data.get('formatted', place),
                    'coordinates': {
                        'latitude': lat,
                        'longitude': lon
                    },
                    'details': place_details
                },
                'images': images,
                'weather': weather,
                'attractions': attractions,
                'distance': distance_info,
                'timestamp': time.time()
            }

        except Exception as e:
            logger.error(f"Error in get_travel_info: {str(e)}", exc_info=True)
            raise

    def _geocode_place(self, place: str) -> Optional[Dict]:
        """Geocode place name to coordinates using Geoapify"""
        cache_key = f"geocode_{place.lower().replace(' ', '_')}"
        cached = cache.get(cache_key)
        if cached:
            return cached

        try:
            url = "https://api.geoapify.com/v1/geocode/search"
            params = {
                'text': place,
                'apiKey': self.geoapify_key,
                'limit': 1
            }
            
            response = self.session.get(url, params=params, timeout=10)
            response.raise_for_status()
            data = response.json()

            if data.get('features'):
                feature = data['features'][0]
                properties = feature['properties']
                coords = feature['geometry']['coordinates']
                
                result = {
                    'lat': coords[1],
                    'lon': coords[0],
                    'name': properties.get('name', place),
                    'formatted': properties.get('formatted', place),
                    'country': properties.get('country'),
                    'city': properties.get('city'),
                    'state': properties.get('state')
                }
                
                cache.set(cache_key, result, 60 * 60 * 24)  # Cache for 24 hours
                return result

        except Exception as e:
            logger.error(f"Geocoding error: {str(e)}")
            
        return None

    def _get_place_images(self, place: str, limit: int = 10) -> List[Dict]:
        """Get high-quality images from Unsplash"""
        cache_key = f"images_{place.lower().replace(' ', '_')}_{limit}"
        cached = cache.get(cache_key)
        if cached:
            return cached

        try:
            url = "https://api.unsplash.com/search/photos"
            params = {
                'query': place,
                'per_page': limit,
                'client_id': self.unsplash_key,
                'orientation': 'landscape'
            }
            
            response = self.session.get(url, params=params, timeout=10)
            response.raise_for_status()
            data = response.json()

            images = []
            for photo in data.get('results', []):
                images.append({
                    'id': photo['id'],
                    'url': photo['urls']['regular'],
                    'thumb': photo['urls']['thumb'],
                    'full': photo['urls']['full'],
                    'photographer': photo['user']['name'],
                    'photographer_url': photo['user']['links']['html'],
                    'description': photo.get('description', photo.get('alt_description')),
                    'width': photo['width'],
                    'height': photo['height']
                })

            cache.set(cache_key, images, 60 * 60 * 12)  # Cache for 12 hours
            return images

        except Exception as e:
            logger.error(f"Error fetching images: {str(e)}")
            return []

    def _get_weather(self, lat: float, lon: float) -> Optional[Dict]:
        """Get current weather from OpenWeatherMap"""
        if not self.weather_key:
            return None

        cache_key = f"weather_{lat}_{lon}"
        cached = cache.get(cache_key)
        if cached:
            return cached

        try:
            url = "https://api.openweathermap.org/data/2.5/weather"
            params = {
                'lat': lat,
                'lon': lon,
                'appid': self.weather_key,
                'units': 'metric'
            }
            
            response = self.session.get(url, params=params, timeout=10)
            response.raise_for_status()
            data = response.json()

            weather = {
                'temperature': data['main']['temp'],
                'feels_like': data['main']['feels_like'],
                'humidity': data['main']['humidity'],
                'description': data['weather'][0]['description'],
                'icon': data['weather'][0]['icon'],
                'wind_speed': data['wind']['speed'],
                'pressure': data['main']['pressure']
            }

            cache.set(cache_key, weather, 60 * 30)  # Cache for 30 minutes
            return weather

        except Exception as e:
            logger.error(f"Error fetching weather: {str(e)}")
            return None

    def _get_nearby_attractions(self, lat: float, lon: float, limit: int = 15) -> List[Dict]:
        """Get nearby tourist attractions using Geoapify"""
        cache_key = f"attractions_{lat}_{lon}_{limit}"
        cached = cache.get(cache_key)
        if cached:
            return cached

        try:
            url = "https://api.geoapify.com/v2/places"
            params = {
                'categories': 'tourism.attraction,tourism.sights,entertainment,leisure',
                'filter': f'circle:{lon},{lat},10000',  # 10km radius
                'limit': limit,
                'apiKey': self.geoapify_key
            }
            
            response = self.session.get(url, params=params, timeout=10)
            response.raise_for_status()
            data = response.json()

            attractions = []
            for feature in data.get('features', []):
                props = feature['properties']
                coords = feature['geometry']['coordinates']
                
                attractions.append({
                    'name': props.get('name', 'Unnamed'),
                    'category': props.get('categories', []),
                    'address': props.get('formatted'),
                    'coordinates': {
                        'latitude': coords[1],
                        'longitude': coords[0]
                    },
                    'distance': props.get('distance'),
                    'place_id': props.get('place_id')
                })

            cache.set(cache_key, attractions, 60 * 60 * 6)  # Cache for 6 hours
            return attractions

        except Exception as e:
            logger.error(f"Error fetching attractions: {str(e)}")
            return []

    def _calculate_distance(self, origin: str, destination: str) -> Optional[Dict]:
        """Calculate distance and route using OpenRouteService"""
        if not self.routing_key:
            return None

        cache_key = f"distance_{origin}_{destination}".replace(' ', '_').lower()
        cached = cache.get(cache_key)
        if cached:
            return cached

        try:
            # First geocode both locations
            origin_coords = self._geocode_place(origin)
            dest_coords = self._geocode_place(destination)
            
            if not origin_coords or not dest_coords:
                return None

            url = "https://api.openrouteservice.org/v2/directions/driving-car"
            headers = {'Authorization': self.routing_key}
            body = {
                'coordinates': [
                    [origin_coords['lon'], origin_coords['lat']],
                    [dest_coords['lon'], dest_coords['lat']]
                ]
            }
            
            response = self.session.post(url, json=body, headers=headers, timeout=15)
            response.raise_for_status()
            data = response.json()

            route = data['routes'][0]
            summary = route['summary']

            distance_info = {
                'distance_km': round(summary['distance'] / 1000, 2),
                'duration_hours': round(summary['duration'] / 3600, 2),
                'origin': origin,
                'destination': destination
            }

            cache.set(cache_key, distance_info, 60 * 60 * 24)  # Cache for 24 hours
            return distance_info

        except Exception as e:
            logger.error(f"Error calculating distance: {str(e)}")
            return None

    def _get_place_details(self, place: str, lat: float, lon: float) -> Dict:
        """Get additional place details from Geoapify"""
        cache_key = f"place_details_{place.lower().replace(' ', '_')}"
        cached = cache.get(cache_key)
        if cached:
            return cached

        try:
            url = "https://api.geoapify.com/v2/places"
            params = {
                'categories': 'tourism,commercial,entertainment',
                'filter': f'circle:{lon},{lat},1000',
                'limit': 5,
                'apiKey': self.geoapify_key
            }
            
            response = self.session.get(url, params=params, timeout=10)
            response.raise_for_status()
            data = response.json()

            details = {
                'total_places': len(data.get('features', [])),
                'categories': []
            }

            for feature in data.get('features', []):
                props = feature['properties']
                if 'categories' in props:
                    details['categories'].extend(props['categories'])

            details['categories'] = list(set(details['categories']))[:10]
            
            cache.set(cache_key, details, 60 * 60 * 12)  # Cache for 12 hours
            return details

        except Exception as e:
            logger.error(f"Error fetching place details: {str(e)}")
            return {'total_places': 0, 'categories': []}