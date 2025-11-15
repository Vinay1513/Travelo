"""
ASGI config for travel_assistant project.
"""

import os

from django.core.asgi import get_asgi_application

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'travel_assistant.settings')

application = get_asgi_application()

