import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/home_screen.dart';
import '../screens/place_details_screen.dart';
import '../screens/chat_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/place/:placeName',
      name: 'place-details',
      builder: (context, state) {
        final placeName = state.pathParameters['placeName'] ?? '';
        return PlaceDetailsScreen(place: placeName);
      },
    ),
    GoRoute(
      path: '/chat',
      name: 'chat',
      builder: (context, state) {
        final place = state.uri.queryParameters['place'];
        return ChatScreen(place: place);
      },
    ),
  ],
);

