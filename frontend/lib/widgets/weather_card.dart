import 'package:flutter/material.dart';
import '../models/travel_info.dart';
import 'package:cached_network_image/cached_network_image.dart';

class WeatherCard extends StatelessWidget {
  final Weather weather;

  const WeatherCard({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    // 🔥 Auto-generate OpenWeather icon URL
    final iconUrl = weather.icon != null
        ? "https://openweathermap.org/img/wn/${weather.icon}@4x.png"
        : null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 🌤 WEATHER ICON
          if (iconUrl != null)
            CachedNetworkImage(
              imageUrl: iconUrl,
              width: 70,
              height: 70,
              errorWidget: (context, url, error) => Icon(
                Icons.cloud,
                size: 60,
                color: Colors.white.withOpacity(0.9),
              ),
            )
          else
            Icon(
              Icons.cloud,
              size: 60,
              color: Colors.white.withOpacity(0.9),
            ),

          const SizedBox(width: 20),

          // 🌡️ WEATHER DETAILS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TEMPERATURE
                Text(
                  weather.temperature != null
                      ? "${weather.temperature!.toStringAsFixed(1)}°C"
                      : "N/A",
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 8),

                // DESCRIPTION
                Text(
                  weather.description?.toUpperCase() ?? "",
                  style: TextStyle(
                    fontSize: 14,
                    letterSpacing: 1,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),

                const SizedBox(height: 10),

                // HUMIDITY + WIND
                Row(
                  children: [
                    if (weather.humidity != null) ...[
                      Icon(Icons.water_drop,
                          size: 16, color: Colors.white.withOpacity(0.8)),
                      const SizedBox(width: 4),
                      Text(
                        "${weather.humidity}%",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                    if (weather.windSpeed != null) ...[
                      Icon(Icons.air,
                          size: 16, color: Colors.white.withOpacity(0.8)),
                      const SizedBox(width: 4),
                      Text(
                        "${weather.windSpeed} m/s",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
