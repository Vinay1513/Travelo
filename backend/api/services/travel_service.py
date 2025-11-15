"""
Main travel service that orchestrates all API calls.
"""
from typing import Dict, Optional, List
from .wikipedia_service import WikipediaService
from .unsplash_service import UnsplashService
from .weather_service import WeatherService
from .route_service import RouteService
from .hotels_service import HotelsService
import logging

logger = logging.getLogger(__name__)


class TravelService:
    """Main service class that combines all travel data sources."""
    
    def __init__(self):
        self.wikipedia_service = WikipediaService()
        self.unsplash_service = UnsplashService()
        self.weather_service = WeatherService()
        self.route_service = RouteService()
        self.hotels_service = HotelsService()
    
    def get_travel_info(self, place: str, user_location: Optional[str] = None) -> Dict:
        """
        Get comprehensive travel information for a place.
        
        Args:
            place: Name of the destination place
            user_location: Optional user's current location
            
        Returns:
            Dictionary containing all travel information
        """
        try:
            # Parallel data fetching (simplified - in production use async)
            description = self.wikipedia_service.get_place_description(place)
            wiki_info = self.wikipedia_service.get_place_info(place)
            images = self.unsplash_service.get_place_images(place, limit=5)
            weather = self.weather_service.get_weather(place)
            top_spots = self._get_top_spots(place, description)
            
            route = None
            if user_location:
                route = self.route_service.get_route(user_location, place)
            
            hotels = self.hotels_service.get_hotels(place)
            itinerary = self._generate_itinerary(place, days=3)
            facts = self._generate_facts(place, wiki_info)
            
            return {
                "place": place,
                "description": description or f"{place} is a beautiful destination worth exploring.",
                "images": images or [],
                "top_spots": top_spots,
                "weather": weather or {},
                "route": route or {},
                "hotels": hotels or [],
                "itinerary": itinerary or f"Plan your visit to {place} and explore its attractions.",
                "facts": facts or [],
            }
        
        except Exception as e:
            logger.error(f"Error in get_travel_info: {str(e)}", exc_info=True)
            # Return minimal structure even on error
            return {
                "place": place,
                "description": f"Information about {place}",
                "images": [],
                "top_spots": [],
                "weather": {},
                "route": {},
                "hotels": [],
                "itinerary": f"Plan your visit to {place}.",
                "facts": [],
            }
    
    def _get_top_spots(self, place: str, description: str) -> list:
        """Extract or generate top spots for a place."""
        # Try to get from Wikipedia first
        spots = self.wikipedia_service.get_top_attractions(place)
        
        if not spots:
            # Fallback: Use default spots
            spots = self._get_default_spots(place)
        
        return spots[:5]  # Limit to top 5
    
    def _generate_itinerary(self, place: str, days: int = 3) -> str:
        """Generate a basic itinerary for a place."""
        itinerary = f"""Plan your {days}-day visit to {place}:

Day 1:
- Morning: Arrive and check into your accommodation
- Afternoon: Explore the city center and local markets
- Evening: Enjoy local cuisine and cultural experiences

Day 2:
- Morning: Visit top historical and cultural sites
- Afternoon: Discover local attractions and landmarks
- Evening: Experience nightlife or local entertainment

Day 3:
- Morning: Explore natural attractions or parks
- Afternoon: Shopping and souvenir hunting
- Evening: Farewell dinner and preparation for departure

Tips:
- Book accommodations in advance
- Carry local currency
- Respect local customs and traditions
- Stay hydrated and wear comfortable shoes
- Keep important documents safe

Enjoy your trip to {place}!"""
        return itinerary
    
    def _generate_facts(self, place: str, wiki_info: Optional[Dict] = None) -> List[str]:
        """Generate facts about a place, using Wikipedia data if available."""
        facts = []
        
        if wiki_info:
            # Extract facts from Wikipedia data
            summary = wiki_info.get('summary', '')
            description = wiki_info.get('description', '')
            location = wiki_info.get('location')
            
            # Add location fact if available
            if location and location.get('latitude') and location.get('longitude'):
                lat = location['latitude']
                lon = location['longitude']
                facts.append(f"{place} is located at coordinates {lat:.4f}°N, {lon:.4f}°E")
            
            # Extract interesting sentences from summary for facts
            if summary:
                sentences = summary.split('.')
                for sentence in sentences[:3]:  # Take first 3 meaningful sentences
                    sentence = sentence.strip()
                    if len(sentence) > 30 and len(sentence) < 200:
                        # Clean up the sentence
                        sentence = sentence.replace('\n', ' ').strip()
                        if sentence and not sentence.startswith('It '):
                            facts.append(sentence)
                            if len(facts) >= 3:
                                break
            
            # Add description as fact if available
            if description and description not in summary:
                facts.append(f"{place} is {description.lower()}")
        
        # Fill remaining slots with generic facts if needed
        generic_facts = [
            f"{place} is a beautiful destination with rich culture and history.",
            f"Best time to visit {place} is during pleasant weather seasons.",
            f"{place} offers a variety of attractions for all types of travelers.",
            f"Local cuisine in {place} is known for its unique flavors.",
            f"{place} has a vibrant local community and welcoming atmosphere.",
        ]
        
        # Add generic facts to reach 5 total
        for fact in generic_facts:
            if len(facts) >= 5:
                break
            if fact not in facts:
                facts.append(fact)
        
        return facts[:5]  # Return maximum 5 facts
    
    def _get_default_spots(self, place: str) -> List[dict]:
        """Return default spots when Wikipedia data is unavailable."""
        return [
            {
                "name": f"{place} City Center",
                "info": "The heart of the city with vibrant markets and historic buildings.",
                "image_url": f"https://picsum.photos/600/400?random={hash(f'{place}1') % 1000}"
            },
            {
                "name": f"{place} Heritage Site",
                "info": "A significant historical landmark showcasing local culture.",
                "image_url": f"https://picsum.photos/600/400?random={hash(f'{place}2') % 1000}"
            },
            {
                "name": f"{place} Natural Park",
                "info": "Beautiful natural surroundings perfect for relaxation and photography.",
                "image_url": f"https://picsum.photos/600/400?random={hash(f'{place}3') % 1000}"
            },
            {
                "name": f"{place} Museum",
                "info": "Explore the rich history and culture of the region.",
                "image_url": f"https://picsum.photos/600/400?random={hash(f'{place}4') % 1000}"
            },
            {
                "name": f"{place} Viewpoint",
                "info": "Stunning panoramic views of the city and surrounding areas.",
                "image_url": f"https://picsum.photos/600/400?random={hash(f'{place}5') % 1000}"
            },
        ]

