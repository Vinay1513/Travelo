"""
Script to create/update .env file with API keys
"""
import os

env_content = """SECRET_KEY=django-insecure-change-this-in-production-xyz123
UNSPLASH_ACCESS_KEY=y4Pj5KzKEEp6jAjDYuZoYCO_eTjD91fs9E3pwiYJCAU
UNSPLASH_SECRET_KEY=saY2WFq0R_x0OWFpjpKPzw6tGmQadWuVCPN2z92Y5xc
OPENWEATHER_API_KEY=a66f410cb7cdd3f1deda35cb2306b736
OPENROUTESERVICE_API_KEY=
GEOPI_API_KEY=6f681d232cb6487e836bdaa45185abba
"""

env_path = os.path.join(os.path.dirname(__file__), '.env')

# Create or update .env file
with open(env_path, 'w') as f:
    f.write(env_content)

print(f"Created/updated .env file at {env_path}")
print("Current API Keys:")
print("   - OPENWEATHER_API_KEY: a66f410cb7cdd3f1deda35cb2306b736 [SET]")
print("   - UNSPLASH_ACCESS_KEY: y4Pj5KzKEEp6jAjDYuZoYCO_eTjD91fs9E3pwiYJCAU [SET]")
print("   - UNSPLASH_SECRET_KEY: saY2WFq0R_x0OWFpjpKPzw6tGmQadWuVCPN2z92Y5xc [SET]")
print("   - GEOPI_API_KEY: 6f681d232cb6487e836bdaa45185abba [SET]")
print("   - OPENROUTESERVICE_API_KEY: (empty)")
print("\nYou can edit .env file to add more API keys")

