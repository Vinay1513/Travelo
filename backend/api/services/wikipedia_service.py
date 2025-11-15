"""
Wikipedia API service for place information with Geoapify and Weather integration.
"""
import requests
import logging
import datetime
from typing import Optional, Dict, List, Tuple, Any
import urllib.parse
from django.conf import settings

logger = logging.getLogger(__name__)


class WikipediaService:
    """
    Service to fetch comprehensive place information by integrating:
    - Wikipedia for place descriptions and general info
    - Geoapify for nearby places and points of interest
    - WeatherService for current weather conditions
    """

    WIKI_BASE_URL = "https://en.wikipedia.org/api/rest_v1/page/summary"
    GEOPI_BASE_URL = "https://api.geoapify.com/v2/places"
    GEOPI_PLACE_DETAILS_URL = "https://api.geoapify.com/v2/place-details"
    GEOPI_GEOCODE_URL = "https://api.geoapify.com/v1/geocode/search"

    def __init__(self):
        self.geopi_api_key = getattr(settings, 'GEOPI_API_KEY', None)
        self.weather_service = None  # Will be set when needed

    def get_place_description(self, place: str) -> Optional[Dict]:
        """
        Get comprehensive description of a place with Wikipedia data, weather, and nearby points of interest.
        """
        try:
            wiki_data = self._get_wiki_summary(place)
            if not wiki_data:
                return None

            coordinates = self._get_place_coordinates(place)

            weather = {}
            if coordinates:
                weather = self._get_weather(coordinates)

            nearby = {}
            if coordinates:
                nearby = self._get_nearby_places(coordinates)

            description_parts = []
            extract = wiki_data.get('extract', '')
            if extract:
                description_parts.append(extract)

            if coordinates:
                lat, lon = coordinates
                description_parts.append(f"\n\nLocation: Coordinates {lat:.4f}°N, {lon:.4f}°E")

            desc = wiki_data.get('description', '')
            if desc and desc not in extract:
                description_parts.append(f"\n\n{desc}")

            return {
                'description': '\n'.join(description_parts) if description_parts else None,
                'weather': weather,
                'nearby': nearby,
                'coordinates': coordinates,
                'wikipedia_url': wiki_data.get('content_urls', {}).get('desktop', {}).get('page', '')
            }

        except Exception as e:
            logger.warning(f"Error in get_place_description for {place}: {str(e)}")
            return None

    def get_place_info(self, place: str) -> Optional[Dict]:
        """
        Get comprehensive place information including Wikipedia data, weather, and nearby points of interest.
        """
        try:
            place_data = self.get_place_description(place)
            if not place_data:
                return None

            wiki_data = self._get_wiki_summary(place)
            if not wiki_data:
                return None

            info = {
                'title': wiki_data.get('title', place),
                'description': place_data['description'],
                'summary': wiki_data.get('extract', ''),
                'thumbnail': wiki_data.get('thumbnail', {}).get('source', '') if wiki_data.get('thumbnail') else '',
                'wikipedia_url': wiki_data.get('content_urls', {}).get('desktop', {}).get('page', ''),
                'weather': place_data.get('weather', {}),
                'nearby_places': place_data.get('nearby', {})
            }

            if place_data.get('coordinates'):
                lat, lon = place_data['coordinates']
                info['location'] = {
                    'latitude': lat,
                    'longitude': lon,
                    'coordinates': f"{lat:.4f}°N, {lon:.4f}°E"
                }

                address = self._get_address_from_coords(lat, lon)
                if address:
                    info['address'] = address

            return info

        except Exception as e:
            logger.warning(f"Error in get_place_info for {place}: {str(e)}")
            return None

    def get_top_attractions(self, place: str, limit: int = 5) -> List[Dict]:
        """
        Get top attractions for a place using Geoapify Places API.
        """
        try:
            coordinates = self._get_place_coordinates(place)
            if coordinates:
                attractions = self._get_places_by_category(
                    coordinates,
                    categories=['building.tourism', 'building.historic', 'activity'],
                    limit=limit
                )
                if attractions:
                    return attractions
            return []
        except Exception as e:
            logger.warning(f"Error in get_top_attractions for {place}: {str(e)}")
            return []

    def _get_place_coordinates(self, place: str) -> Optional[Tuple[float, float]]:
        """
        Get coordinates for a place using Geoapify Geocoding API.
        """
        if not self.geopi_api_key:
            return None
        try:
            params = {
                'text': place,
                'apiKey': self.geopi_api_key,
                'limit': 1
            }
            response = requests.get(self.GEOPI_GEOCODE_URL, params=params, timeout=10)
            response.raise_for_status()
            data = response.json()
            features = data.get('features', [])
            if features:
                geometry = features[0].get('geometry', {})
                coordinates = geometry.get('coordinates', [])
                if coordinates and len(coordinates) >= 2:
                    return coordinates[1], coordinates[0]  # lat, lon
            return None
        except Exception as e:
            logger.warning(f"Geocoding error for {place}: {str(e)}")
            return None

    def _get_weather(self, coordinates: Tuple[float, float]) -> Dict[str, Any]:
        """
        Get weather information for given coordinates.
        """
        try:
            if self.weather_service is None:
                from .weather_service import WeatherService
                self.weather_service = WeatherService()
            lat, lon = coordinates
            weather_data = self.weather_service.get_weather(f"{lat},{lon}")
            if not weather_data:
                return {}
            return {
                'temperature': weather_data.get('temp', 'N/A'),
                'condition': weather_data.get('condition', 'N/A'),
                'humidity': weather_data.get('humidity', 'N/A'),
                'wind_speed': weather_data.get('wind_speed', 'N/A'),
                'icon': weather_data.get('icon', '')
            }
        except Exception as e:
            logger.warning(f"Error getting weather data: {str(e)}")
            return {}

    def _get_nearby_places(self, coordinates: Tuple[float, float]) -> Dict[str, List[Dict]]:
        """
        Get nearby places of different categories.
        """
        if not self.geopi_api_key:
            return {}

        lat, lon = coordinates
        categories = {
            'attractions': ['building.tourism', 'building.historic', 'activity'],
            'restaurants': [
                'catering.restaurant.pizza',
                'catering.restaurant.indian',
                'catering.restaurant.chinese'
            ],
            'hotels': ['accommodation.hotel', 'accommodation.guest_house'],
            'shopping': ['building.commercial']
        }

        nearby = {}
        for category, cat_list in categories.items():
            places = self._get_places_by_category(coordinates, cat_list, limit=5)
            if places:
                nearby[category] = places

        return nearby

    def _get_places_by_category(self, coordinates: Tuple[float, float],
                                categories: List[str], limit: int = 5) -> List[Dict]:
        """
        Get places of specific categories near given coordinates.
        """
        if not self.geopi_api_key or not coordinates:
            return []
        lat, lon = coordinates
        try:
            params = {
                'categories': ','.join(categories),
                'filter': f'circle:{lon},{lat},5000',  # Geoapify expects lon,lat,radius
                'limit': limit,
                'apiKey': self.geopi_api_key
            }
            response = requests.get(self.GEOPI_BASE_URL, params=params, timeout=10)
            response.raise_for_status()
            data = response.json()
            places = []
            for feature in data.get('features', [])[:limit]:
                properties = feature.get('properties', {})
                name = properties.get('name', 'Place')
                description = properties.get('description') or properties.get('formatted', '')
                place_type = 'place'
                for category in categories:
                    if category in properties.get('categories', []):
                        place_type = category.split('.')[-1]
                        break
                places.append({
                    'name': name,
                    'description': description[:150] + '...' if len(description) > 150 else description,
                    'type': place_type,
                    'distance': properties.get('distance', 0) / 1000,
                    'address': properties.get('formatted', ''),
                    'coordinates': {
                        'latitude': properties.get('lat'),
                        'longitude': properties.get('lon')
                    },
                    'categories': properties.get('categories', [])
                })
            return places
        except Exception as e:
            logger.warning(f"Error getting places by category: {str(e)}")
            return []

    def _get_address_from_coords(self, lat: float, lon: float) -> Optional[Dict]:
        """
        Get address information from coordinates using reverse geocoding.
        """
        if not self.geopi_api_key:
            return None
        try:
            params = {
                'lat': lat,
                'lon': lon,
                'apiKey': self.geopi_api_key,
                'type': 'street'
            }
            response = requests.get(self.GEOPI_GEOCODE_URL, params=params, timeout=10)
            response.raise_for_status()
            data = response.json()
            features = data.get('features', [])
            if features:
                properties = features[0].get('properties', {})
                address = {
                    'street': properties.get('street'),
                    'city': properties.get('city'),
                    'state': properties.get('state'),
                    'country': properties.get('country'),
                    'postcode': properties.get('postcode'),
                    'formatted': properties.get('formatted')
                }
                return {k: v for k, v in address.items() if v is not None}
            return None
        except Exception as e:
            logger.warning(f"Error in reverse geocoding: {str(e)}")
            return None

    def _get_wiki_summary(self, place: str) -> Optional[Dict]:
        """
        Fetch Wikipedia summary data.
        """
        try:
            encoded_place = urllib.parse.quote(place.replace(' ', '_'))
            url = f"{self.WIKI_BASE_URL}/{encoded_place}"
            headers = {
                'User-Agent': 'TravelAssistant/1.0 (https://travel-assistant.example.com; contact@example.com)',
                'Accept': 'application/json',
                'Accept-Language': 'en-US,en;q=0.5'
            }
            response = requests.get(url, headers=headers, timeout=10)
            response.raise_for_status()
            data = response.json()
            data['retrieved_at'] = datetime.datetime.utcnow().isoformat()
            return data
        except requests.exceptions.HTTPError as e:
            if e.response.status_code == 404:
                logger.warning(f"Wikipedia page not found for {place}")
            elif e.response.status_code == 429:
                logger.warning("Wikipedia API rate limit exceeded")
            else:
                logger.warning(f"Wikipedia API HTTP error for {place}: {str(e)}")
            return None
        except requests.exceptions.RequestException as e:
            logger.warning(f"Network error while accessing Wikipedia API: {str(e)}")
            return None
        except Exception as e:
            logger.warning(f"Unexpected error in _get_wiki_summary for {place}: {str(e)}")
            return None
