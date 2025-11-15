"""
OpenWeatherMap API service for weather information.
"""
import requests
import logging
from typing import Optional, Dict, Tuple
from django.conf import settings

logger = logging.getLogger(__name__)

class WeatherService:
    """Service to fetch weather data from OpenWeatherMap One Call API 3.0."""

    GEOCODING_URL = "https://api.openweathermap.org/geo/1.0/direct"
    ONECALL_URL = "https://api.openweathermap.org/data/3.0/onecall"

    def __init__(self):
        # Use the API key from settings or environment variable
        self.api_key = getattr(settings, 'OPENWEATHER_API_KEY', None)
        if not self.api_key:
            logger.warning("OpenWeather API key not found. Using mock data.")

    def get_weather(self, place: str) -> Optional[Dict]:
        """Get current weather for a place using One Call API 3.0."""
        if not self.api_key:
            return self._get_mock_weather()

        try:
            # Get coordinates from place name
            lat, lon = self._get_coordinates(place)
            if not lat or not lon:
                logger.warning(f"Could not get coordinates for {place}. Using mock data.")
                return self._get_mock_weather()

            # Get weather data
            params = {
                'lat': lat,
                'lon': lon,
                'appid': self.api_key,
                'units': 'metric'
            }
            response = requests.get(self.ONECALL_URL, params=params, timeout=10)
            response.raise_for_status()
            data = response.json()

            current = data.get('current', {})
            weather_data = current.get('weather', [{}])[0]

            return {
                "temp": f"{current.get('temp', 0):.1f}°C",
                "condition": weather_data.get('description', 'Unknown').title(),
                "humidity": f"{current.get('humidity', 0)}%",
                "wind_speed": f"{current.get('wind_speed', 0) * 3.6:.1f} km/h",  # m/s → km/h
                "icon": f"https://openweathermap.org/img/wn/{weather_data.get('icon', '')}@2x.png"
            }

        except requests.exceptions.HTTPError as e:
            if e.response.status_code == 401:
                logger.warning(f"OpenWeather API key is invalid. Using mock data for {place}.")
            else:
                logger.warning(f"Weather API HTTP error for {place}: {str(e)}")
            return self._get_mock_weather()
        except Exception as e:
            logger.warning(f"Weather API error for {place}: {str(e)}")
            return self._get_mock_weather()

    def _get_coordinates(self, place: str) -> Tuple[Optional[float], Optional[float]]:
        """Get latitude and longitude for a place name using geocoding API."""
        try:
            params = {
                'q': place,
                'limit': 1,
                'appid': self.api_key
            }
            response = requests.get(self.GEOCODING_URL, params=params, timeout=10)
            response.raise_for_status()
            data = response.json()

            if data and len(data) > 0:
                location = data[0]
                return location.get('lat'), location.get('lon')

            return None, None

        except Exception as e:
            logger.warning(f"Geocoding error for {place}: {str(e)}")
            return None, None

    def _get_mock_weather(self) -> Dict:
        """Return mock weather data when API is unavailable."""
        return {
            "temp": "25°C",
            "condition": "Partly Cloudy",
            "humidity": "60%",
            "wind_speed": "10 km/h",
            "icon": ""
        }
