from django.urls import path
from . import views

urlpatterns = [
    path('', views.health_check, name='health_check'),
    path('travel/info/', views.travel_info, name='travel_info'),
    path('restaurants/', views.get_restaurants, name='get_restaurants'),  # NEW endpoint
]
