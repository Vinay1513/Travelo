from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from django.views.decorators.cache import cache_page
from django.conf import settings
import logging
import requests

from .services.travel_service import TravelService
from .services.hotels_service import HotelsService

logger = logging.getLogger(__name__)


# ------------------------
# Health Check Endpoint
# ------------------------
@api_view(['GET'])
def health_check(request):
    """API health check endpoint"""
    return Response({
        'status': 'ok',
        'message': 'Travel AI API is running',
        'version': '1.0.0'
    }, status=status.HTTP_200_OK)


# ------------------------
# Main Travel Info Endpoint
# ------------------------
@api_view(['POST'])
def travel_info(request):
    """
    Get comprehensive travel information for a place including:
    - Place details and coordinates
    - High-quality images from Unsplash
    - Current weather
    - Nearby attractions
    - Distance from user's location
    - Nearby hotels
    
    Request Body:
        {
            "place": "Paris, France",
            "user_location": "London, UK" (optional)
        }
    """
    try:
        data = request.data
        place = data.get('place', '').strip()
        user_location = data.get('user_location', '').strip()

        if not place:
            return Response({
                'error': 'Place parameter is required',
                'example': {
                    'place': 'Paris, France',
                    'user_location': 'London, UK'
                }
            }, status=status.HTTP_400_BAD_REQUEST)

        logger.info(f"Fetching travel info for: {place}")

        # Get comprehensive travel information
        travel_service = TravelService()
        result = travel_service.get_travel_info(place, user_location)
        
        if 'error' in result:
            return Response(result, status=status.HTTP_404_NOT_FOUND)

        # Add hotels information
        hotels_service = HotelsService()
        hotels = hotels_service.get_hotels(place, limit=10)
        result['hotels'] = hotels

        logger.info(f"Successfully fetched travel info for: {place}")
        return Response(result, status=status.HTTP_200_OK)

    except Exception as e:
        logger.error(f"Error in travel_info: {str(e)}", exc_info=True)
        return Response({
            'error': 'An error occurred while fetching travel information',
            'details': str(e)
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


# ------------------------
# Nearby Restaurants Endpoint
# ------------------------
@api_view(['GET'])
def get_restaurants(request):
    """
    Get nearby restaurants using Geoapify API.
    
    Query Parameters:
        lat: Latitude (required)
        lon: Longitude (required)
        limit: Maximum number of results (optional, default: 20)
        radius: Search radius in meters (optional, default: 5000)
    
    Example: /api/restaurants/?lat=48.8566&lon=2.3522&limit=10&radius=3000
    """
    try:
        lat = request.GET.get('lat')
        lon = request.GET.get('lon')
        limit = int(request.GET.get('limit', 20))
        radius = int(request.GET.get('radius', 5000))

        if not lat or not lon:
            return Response({
                'error': 'lat and lon query parameters are required',
                'example': '/api/restaurants/?lat=48.8566&lon=2.3522&limit=10'
            }, status=status.HTTP_400_BAD_REQUEST)

        try:
            lat = float(lat)
            lon = float(lon)
        except ValueError:
            return Response({
                'error': 'Invalid lat or lon value. Must be valid numbers.'
            }, status=status.HTTP_400_BAD_REQUEST)

        if not settings.GEOPI_API_KEY:
            return Response({
                'error': 'Geoapify API key not configured'
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

        # Build Geoapify API URL
        url = (
            f"https://api.geoapify.com/v2/places?"
            f"categories=catering.restaurant,catering.cafe,catering.fast_food&"
            f"filter=circle:{lon},{lat},{radius}&"
            f"limit={limit}&"
            f"apiKey={settings.GEOPI_API_KEY}"
        )
        
        logger.info(f"Fetching restaurants near ({lat}, {lon})")
        response = requests.get(url, timeout=10)
        response.raise_for_status()
        data = response.json()

        # Format response
        restaurants = []
        for feature in data.get('features', []):
            props = feature['properties']
            coords = feature['geometry']['coordinates']
            
            restaurants.append({
                'name': props.get('name', 'Unnamed Restaurant'),
                'address': props.get('formatted'),
                'categories': props.get('categories', []),
                'coordinates': {
                    'latitude': coords[1],
                    'longitude': coords[0]
                },
                'distance': props.get('distance'),
                'place_id': props.get('place_id')
            })

        return Response({
            'total': len(restaurants),
            'restaurants': restaurants
        }, status=status.HTTP_200_OK)

    except requests.exceptions.RequestException as e:
        logger.error(f"Geoapify API request failed: {str(e)}", exc_info=True)
        return Response({
            'error': 'Failed to fetch data from Geoapify API',
            'details': str(e)
        }, status=status.HTTP_502_BAD_GATEWAY)
    
    except Exception as e:
        logger.error(f"Error in get_restaurants: {str(e)}", exc_info=True)
        return Response({
            'error': 'An error occurred while fetching restaurants',
            'details': str(e)
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


# ------------------------
# Hotels Endpoint
# ------------------------
@api_view(['GET'])
def get_hotels(request):
    """
    Get hotels near a place.
    
    Query Parameters:
        place: Place name (e.g., "Paris, France")
        OR
        lat: Latitude
        lon: Longitude
        
        limit: Maximum number of results (optional, default: 10)
    
    Examples:
        /api/hotels/?place=Paris&limit=5
        /api/hotels/?lat=48.8566&lon=2.3522&limit=10
    """
    try:
        place = request.GET.get('place', '').strip()
        lat = request.GET.get('lat')
        lon = request.GET.get('lon')
        limit = int(request.GET.get('limit', 10))

        hotels_service = HotelsService()

        # Use coordinates if provided, otherwise use place name
        if lat and lon:
            try:
                lat = float(lat)
                lon = float(lon)
                logger.info(f"Fetching hotels near coordinates ({lat}, {lon})")
                hotels = hotels_service.get_hotels_by_coordinates(lat, lon, limit=limit)
            except ValueError:
                return Response({
                    'error': 'Invalid lat or lon value. Must be valid numbers.'
                }, status=status.HTTP_400_BAD_REQUEST)
        elif place:
            logger.info(f"Fetching hotels near: {place}")
            hotels = hotels_service.get_hotels(place, limit=limit)
        else:
            return Response({
                'error': 'Either place name or coordinates (lat, lon) are required',
                'examples': [
                    '/api/hotels/?place=Paris&limit=5',
                    '/api/hotels/?lat=48.8566&lon=2.3522&limit=10'
                ]
            }, status=status.HTTP_400_BAD_REQUEST)

        return Response({
            'total': len(hotels),
            'hotels': hotels
        }, status=status.HTTP_200_OK)

    except Exception as e:
        logger.error(f"Error in get_hotels: {str(e)}", exc_info=True)
        return Response({
            'error': 'An error occurred while fetching hotels',
            'details': str(e)
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)