"""
URL configuration for travel_assistant project.
"""
from django.contrib import admin
from django.urls import path, include
from django.http import JsonResponse

def root_view(request):
    """Root endpoint showing API information."""
    return JsonResponse({
        'message': 'Travel Assistant API',
        'version': '1.0.0',
        'endpoints': {
            'health_check': '/api/',
            'travel_info': '/api/travel/info/',
            'admin': '/admin/',
        },
        'usage': {
            'travel_info': {
                'method': 'POST',
                'url': '/api/travel/info/',
                'body': {
                    'place': 'Pune',
                    'user_location': 'Mumbai (optional)'
                }
            }
        }
    })

urlpatterns = [
    path('', root_view, name='root'),
    path('admin/', admin.site.urls),
    path('api/', include('api.urls')),
]

