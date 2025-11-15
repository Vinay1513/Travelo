"""
Geoapify Routing API for distance and route calculation.
"""
import requests
import logging
from typing import Optional, Dict
from django.conf import settings

logger = logging.getLogger(__name__)


class RouteService:
    """Service to calculate distance and travel time between locations using Geoapify."""
    
    BASE_URL = "https://api.geoapify.com/v1/routing"
    
    def __init__(self):
        # Use Geoapify API key (stored as GEOPI_API_KEY in settings)
        self.api_key = getattr(settings, 'GEOPI_API_KEY', None) or settings.OPENROUTESERVICE_API_KEY
    
    def get_route(self, origin: str, destination: str, profile: str = "driving-car") -> Optional[Dict]:
        """
        Get route information between two places using Geoapify.
        
        Args:
            origin: Starting location name
            destination: Destination location name
            profile: Route mode (drive, walk, bicycle, transit)
        
        Returns:
            Dictionary with distance, duration, and mode
        """
        if not self.api_key:
            logger.warning("Geoapify API key not configured")
            return self._get_mock_route()
        
        try:
            # Map profile to Geoapify mode
            mode_map = {
                "driving-car": "drive",
                "driving": "drive",
                "walking": "walk",
                "cycling": "bicycle",
                "transit": "transit"
            }
            mode = mode_map.get(profile, "drive")
            
            # Format waypoints: origin|destination
            waypoints = f"{origin}|{destination}"
            
            params = {
                'waypoints': waypoints,
                'mode': mode,
                'apiKey': self.api_key
            }
            
            response = requests.get(self.BASE_URL, params=params, timeout=10)
            response.raise_for_status()
            data = response.json()
            
            # Extract route information from Geoapify response
            if 'features' in data and len(data['features']) > 0:
                feature = data['features'][0]
                properties = feature.get('properties', {})
                
                # Distance in meters, convert to km
                distance_m = properties.get('distance', 0)
                distance_km = distance_m / 1000
                
                # Duration in seconds, convert to minutes/hours
                duration_sec = properties.get('time', 0)
                duration_min = duration_sec / 60
                duration_hours = duration_sec / 3600
                
                # Format duration
                if duration_hours >= 1:
                    duration_str = f"{duration_hours:.1f} hours"
                else:
                    duration_str = f"{duration_min:.0f} minutes"
                
                # Format mode name
                mode_display = mode.replace("drive", "Car").replace("walk", "Walking").replace("bicycle", "Bicycle").replace("transit", "Transit").title()
                
                return {
                    "distance": f"{distance_km:.1f} km",
                    "duration": duration_str,
                    "mode": mode_display
                }
            
            return self._get_mock_route()
        
        except requests.exceptions.HTTPError as e:
            logger.warning(f"Geoapify API HTTP error: {str(e)}")
            if e.response.status_code == 401:
                logger.warning("Geoapify API key is invalid")
            return self._get_mock_route()
        except Exception as e:
            logger.warning(f"Route API error: {str(e)}")
            return self._get_mock_route()
    
    def _get_mock_route(self) -> Dict:
        """Return mock route data when API is unavailable."""
        return {
            "distance": "~150 km",
            "duration": "~3 hours",
            "mode": "Car"
        }

