"""
Unsplash API service for beautiful travel images.
"""
import requests
import logging
from typing import List, Dict
from django.conf import settings

logger = logging.getLogger(__name__)


class UnsplashService:
    """Service to fetch images from Unsplash."""
    
    BASE_URL = "https://api.unsplash.com"
    
    def __init__(self):
        # Get access key from settings with fallback
        self.access_key = getattr(settings, 'UNSPLASH_ACCESS_KEY', '') or 'y4Pj5KzKEEp6jAjDYuZoYCO_eTjD91fs9E3pwiYJCAU'
    
    def get_place_images(self, place: str, limit: int = 5) -> List[str]:
        """Get images for a place from Unsplash."""
        if not self.access_key:
            logger.warning("Unsplash access key not configured")
            # Return placeholder images
            return self._get_placeholder_images(place, limit)
        
        try:
            url = f"{self.BASE_URL}/search/photos"
            params = {
                'query': place,
                'per_page': limit,
                'orientation': 'landscape',
                'client_id': self.access_key
            }
            response = requests.get(url, params=params, timeout=10)
            response.raise_for_status()
            data = response.json()
            
            images = []
            for photo in data.get('results', [])[:limit]:
                # Get regular size URL
                image_url = photo.get('urls', {}).get('regular', '')
                if image_url:
                    images.append(image_url)
            
            return images if images else self._get_placeholder_images(place, limit)
        
        except Exception as e:
            logger.warning(f"Unsplash API error for {place}: {str(e)}")
            return self._get_placeholder_images(place, limit)
    
    def _get_placeholder_images(self, place: str, limit: int) -> List[str]:
        """Return placeholder images when API is unavailable."""
        # Using Picsum as fallback
        return [f"https://picsum.photos/800/600?random={i}" for i in range(limit)]

