from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from django.views.decorators.cache import cache_page
from django.http import JsonResponse
from django.conf import settings
import logging
import requests

from .services.travel_service import TravelService

logger = logging.getLogger(__name__)

# ------------------------
# Existing endpoints
# ------------------------

@api_view(['GET'])
def health_check(request):
    """Health check endpoint."""
    return JsonResponse({'status': 'ok', 'message': 'Travel Assistant API is running'})

@api_view(['POST'])
@cache_page(60 * 15)  # Cache for 15 minutes
def travel_info(request):
    """
    Main endpoint to get comprehensive travel information for a place.
    
    Expected input:
    {
        "place": "Pune",
        "user_location": "Mumbai"
    }
    """
    try:
        logger.info(f"Received request: {request.data}")
        place = request.data.get('place', '').strip()
        user_location = request.data.get('user_location', '').strip()
        
        if not place:
            return Response(
                {'error': 'Place parameter is required'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        logger.info(f"Fetching travel info for: {place}, from: {user_location}")
        service = TravelService()
        result = service.get_travel_info(place, user_location)
        logger.info(f"Successfully fetched info for: {place}")
        
        return Response(result, status=status.HTTP_200_OK)
    
    except Exception as e:
        logger.error(f"Error in travel_info: {str(e)}", exc_info=True)
        return Response(
            {'error': f'An error occurred: {str(e)}'},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )

# ------------------------
# NEW endpoint: Geoapify Restaurants
# ------------------------

@api_view(['GET'])
def get_restaurants(request):
    """
    Get nearby restaurants using Geoapify API.
    Query params:
      ?lat=18.5204&lon=73.8567
    """
    try:
        lat = request.GET.get('lat')
        lon = request.GET.get('lon')

        if not lat or not lon:
            return Response(
                {'error': 'lat and lon query parameters are required'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        url = (
            f"https://api.geoapify.com/v2/places?"
            f"categories=catering.restaurant&"
            f"filter=circle:{lon},{lat},5000&"
            f"limit=20&"
            f"apiKey={settings.GEOAPIFY_API_KEY}"
        )
        logger.info(f"Calling Geoapify API: {url}")
        response = requests.get(url)
        response.raise_for_status()
        data = response.json()
        
        return Response(data, status=status.HTTP_200_OK)
    
    except requests.exceptions.RequestException as e:
        logger.error(f"Geoapify API request failed: {str(e)}", exc_info=True)
        return Response(
            {'error': 'Failed to fetch data from Geoapify API'},
            status=status.HTTP_502_BAD_GATEWAY
        )
    
    except Exception as e:
        logger.error(f"Error in get_restaurants: {str(e)}", exc_info=True)
        return Response(
            {'error': f'An error occurred: {str(e)}'},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )
