"""
Hotels service using Geoapify Places API.
"""
import requests
import logging
from typing import List, Dict, Optional, Tuple
from django.conf import settings

logger = logging.getLogger(__name__)


class HotelsService:
    """Service to fetch hotel information using Geoapify Places API."""
    
    PLACES_URL = "https://api.geoapify.com/v2/places"
    
    def __init__(self):
        # Use Geoapify API key (stored as GEOPI_API_KEY in settings)
        self.api_key = getattr(settings, 'GEOPI_API_KEY', None)
    
    def get_hotels(self, place: str, limit: int = 5) -> List[Dict]:
        """
        Get hotels near a place using Geoapify Places API.
        
        Args:
            place: Name of the destination place
            limit: Maximum number of hotels to return
        
        Returns:
            List of hotel dictionaries with name, price, rating, and image
        """
        if not self.api_key:
            logger.warning("Geoapify API key not configured")
            return self._get_mock_hotels(place, limit)
        
        try:
            # First, get coordinates for the place
            lat, lon = self._geocode_place(place)
            if not lat or not lon:
                logger.warning(f"Could not geocode {place} for hotel search")
                return self._get_mock_hotels(place, limit)
            
            # Search for hotels using Geoapify Places API
            params = {
                'text': place,
                'categories': 'accommodation.hotel,accommodation',
                'bias': f'proximity:{lon},{lat}',  # Bias search towards location
                'limit': limit,
                'apiKey': self.api_key
            }
            
            response = requests.get(self.PLACES_URL, params=params, timeout=10)
            response.raise_for_status()
            data = response.json()
            
            hotels = []
            features = data.get('features', [])
            
            for feature in features[:limit]:
                properties = feature.get('properties', {})
                name = properties.get('name', 'Hotel')
                
                # Extract rating if available
                rating = properties.get('rating', None)
                if rating:
                    rating_str = f"{rating:.1f}"
                else:
                    # Generate a reasonable rating if not available
                    rating_str = f"{4.0 + (hash(name) % 10) / 10:.1f}"
                
                # Extract address for context
                address = properties.get('formatted', '')
                
                # Generate price based on rating (mock pricing)
                price_num = 1500 + (hash(name) % 20) * 100
                price_str = f"₹{price_num:,}"
                
                # Use placeholder image or try to get from properties
                image_url = properties.get('image', None)
                if not image_url:
                    image_url = f"https://picsum.photos/400/300?random={hash(name) % 1000}"
                
                hotels.append({
                    "name": name,
                    "price": price_str,
                    "rating": rating_str,
                    "image": image_url
                })
            
            # If we got hotels, return them
            if hotels:
                return hotels
            
            # Fallback to mock data
            return self._get_mock_hotels(place, limit)
        
        except requests.exceptions.HTTPError as e:
            error_msg = str(e)
            if e.response is not None:
                try:
                    error_data = e.response.json()
                    error_msg = f"{error_msg}: {error_data}"
                except:
                    error_msg = f"{error_msg}: {e.response.text[:200]}"
            logger.warning(f"Geoapify Places API HTTP error: {error_msg}")
            if e.response and e.response.status_code == 401:
                logger.warning("Geoapify API key is invalid")
            return self._get_mock_hotels(place, limit)
        except Exception as e:
            logger.warning(f"Hotels API error for {place}: {str(e)}")
            return self._get_mock_hotels(place, limit)
    
    def _geocode_place(self, place: str) -> Tuple[Optional[float], Optional[float]]:
        """Geocode a place name to get coordinates using Geoapify Geocoding API."""
        try:
            geocode_url = "https://api.geoapify.com/v1/geocode/search"
            params = {
                'text': place,
                'apiKey': self.api_key,
                'limit': 1
            }
            
            response = requests.get(geocode_url, params=params, timeout=10)
            response.raise_for_status()
            data = response.json()
            
            features = data.get('features', [])
            if features and len(features) > 0:
                geometry = features[0].get('geometry', {})
                coordinates = geometry.get('coordinates', [])
                if coordinates and len(coordinates) >= 2:
                    # Geoapify returns [lon, lat]
                    return coordinates[1], coordinates[0]
            
            return None, None
        
        except Exception as e:
            logger.warning(f"Geocoding error for {place}: {str(e)}")
            return None, None
    
    def _get_mock_hotels(self, place: str, limit: int) -> List[Dict]:
        """Return mock hotel data when API is unavailable."""
        hotel_templates = [
            {"name": f"Grand {place} Hotel", "price": "₹2,500", "rating": "4.5", "image": "https://picsum.photos/400/300?random=101"},
            {"name": f"{place} Plaza Resort", "price": "₹3,200", "rating": "4.8", "image": "https://picsum.photos/400/300?random=102"},
            {"name": f"Serenity {place} Inn", "price": "₹1,800", "rating": "4.2", "image": "https://picsum.photos/400/300?random=103"},
            {"name": f"{place} Heritage Stay", "price": "₹2,100", "rating": "4.6", "image": "https://picsum.photos/400/300?random=104"},
            {"name": f"Royal {place} Suites", "price": "₹3,800", "rating": "4.9", "image": "https://picsum.photos/400/300?random=105"},
        ]
        
        return hotel_templates[:limit]

