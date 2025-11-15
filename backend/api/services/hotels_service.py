import requests
import logging
from django.conf import settings
from django.core.cache import cache
from typing import List, Dict, Optional

logger = logging.getLogger(__name__)


class HotelsService:
    """
    Professional service for fetching hotel information using Geoapify API
    """

    def __init__(self):
        self.api_key = settings.GEOPI_API_KEY
        self.base_url = "https://api.geoapify.com/v2/places"
        self.session = requests.Session()
        self.session.headers.update({'User-Agent': 'TravelAI/1.0'})

    def get_hotels(self, place: str, limit: int = 10) -> List[Dict]:
        """
        Get hotels near a specific place.
        
        Args:
            place: Place name or address
            limit: Maximum number of hotels to return
            
        Returns:
            List of hotel information
        """
        cache_key = f"hotels_{place.lower().replace(' ', '_')}_{limit}"
        cached = cache.get(cache_key)
        if cached:
            return cached

        try:
            # First, geocode the place
            coords = self._geocode_place(place)
            if not coords:
                return []

            lat, lon = coords['lat'], coords['lon']

            # Get hotels using Geoapify
            hotels = self._fetch_hotels(lat, lon, limit)
            
            cache.set(cache_key, hotels, 60 * 60 * 6)  # Cache for 6 hours
            return hotels

        except Exception as e:
            logger.error(f"Error in get_hotels: {str(e)}", exc_info=True)
            return []

    def _geocode_place(self, place: str) -> Optional[Dict]:
        """Geocode place to coordinates"""
        try:
            url = "https://api.geoapify.com/v1/geocode/search"
            params = {
                'text': place,
                'apiKey': self.api_key,
                'limit': 1
            }
            
            response = self.session.get(url, params=params, timeout=10)
            response.raise_for_status()
            data = response.json()

            if data.get('features'):
                coords = data['features'][0]['geometry']['coordinates']
                return {
                    'lat': coords[1],
                    'lon': coords[0]
                }

        except Exception as e:
            logger.error(f"Geocoding error: {str(e)}")
            
        return None

    def _fetch_hotels(self, lat: float, lon: float, limit: int) -> List[Dict]:
        """Fetch hotels from Geoapify API"""
        try:
            params = {
                'categories': 'accommodation.hotel,accommodation',
                'filter': f'circle:{lon},{lat},10000',  # 10km radius
                'limit': limit,
                'apiKey': self.api_key
            }
            
            response = self.session.get(self.base_url, params=params, timeout=10)
            response.raise_for_status()
            data = response.json()

            hotels = []
            for feature in data.get('features', []):
                props = feature['properties']
                coords = feature['geometry']['coordinates']
                
                hotel = {
                    'name': props.get('name', 'Unnamed Hotel'),
                    'address': props.get('formatted', 'Address not available'),
                    'coordinates': {
                        'latitude': coords[1],
                        'longitude': coords[0]
                    },
                    'distance': props.get('distance'),
                    'categories': props.get('categories', []),
                    'place_id': props.get('place_id'),
                    'datasource': props.get('datasource', {})
                }

                # Add contact info if available
                if 'contact' in props:
                    hotel['contact'] = props['contact']

                # Add website if available
                if 'website' in props:
                    hotel['website'] = props['website']

                hotels.append(hotel)

            return hotels

        except Exception as e:
            logger.error(f"Error fetching hotels: {str(e)}")
            return []

    def get_hotels_by_coordinates(self, lat: float, lon: float, limit: int = 10) -> List[Dict]:
        """
        Get hotels by latitude and longitude directly.
        
        Args:
            lat: Latitude
            lon: Longitude
            limit: Maximum number of hotels
            
        Returns:
            List of hotel information
        """
        cache_key = f"hotels_coords_{lat}_{lon}_{limit}"
        cached = cache.get(cache_key)
        if cached:
            return cached

        try:
            hotels = self._fetch_hotels(lat, lon, limit)
            cache.set(cache_key, hotels, 60 * 60 * 6)  # Cache for 6 hours
            return hotels

        except Exception as e:
            logger.error(f"Error in get_hotels_by_coordinates: {str(e)}")
            return []