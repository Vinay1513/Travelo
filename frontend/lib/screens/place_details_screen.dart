import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:go_router/go_router.dart';
import '../providers/travel_provider.dart';
import '../widgets/weather_card.dart';
import '../widgets/route_card.dart';
import '../widgets/top_spot_card.dart';
import '../widgets/hotel_card.dart';

class PlaceDetailsScreen extends ConsumerStatefulWidget {
  final String place;

  const PlaceDetailsScreen({super.key, required this.place});

  @override
  ConsumerState<PlaceDetailsScreen> createState() => _PlaceDetailsScreenState();
}

class _PlaceDetailsScreenState extends ConsumerState<PlaceDetailsScreen> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  void _onRefresh() async {
    ref.invalidate(travelInfoProvider(TravelInfoRequest(place: widget.place)));
    await Future.delayed(const Duration(milliseconds: 1000));
    _refreshController.refreshCompleted();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final travelInfoAsync = ref.watch(
      travelInfoProvider(TravelInfoRequest(place: widget.place)),
    );

    return Scaffold(
      body: travelInfoAsync.when(
        data: (travelInfo) => SmartRefresher(
          controller: _refreshController,
          onRefresh: _onRefresh,
          child: CustomScrollView(
            slivers: [
              // Hero Image Sliver
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    travelInfo.place,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 10)],
                    ),
                  ),
                  background: CarouselSlider.builder(
                    itemCount: travelInfo.images.isNotEmpty ? travelInfo.images.length : 1,
                    itemBuilder: (context, index, realIndex) {
                      final imageUrl = travelInfo.images.isNotEmpty
                          ? travelInfo.images[index]
                          : '';
                      return CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey.shade200,
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.image_not_supported),
                        ),
                      );
                    },
                    options: CarouselOptions(
                      height: 300,
                      viewportFraction: 1.0,
                      autoPlay: travelInfo.images.isNotEmpty,
                      autoPlayInterval: const Duration(seconds: 3),
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // About
                      if (travelInfo.description.isNotEmpty)
                        _buildSection(title: 'About', child: Text(
                          travelInfo.description,
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade700, height: 1.6),
                        )),
                      _sectionSpacing(),

                      // Weather
                      if (travelInfo.weather.temp.isNotEmpty)
                        _buildSection(title: 'Weather', child: WeatherCard(weather: travelInfo.weather)),
                      _sectionSpacing(),

                      // Route
                      if (travelInfo.route != null && travelInfo.route!.distance.isNotEmpty)
                        _buildSection(title: 'Route', child: RouteCard(route: travelInfo.route!)),
                      _sectionSpacing(),

                      // Top Tourist Spots
                      if (travelInfo.topSpots.isNotEmpty)
                        _buildSection(
                          title: 'Top Tourist Spots',
                          child: SizedBox(
                            height: 200,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: travelInfo.topSpots.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 16),
                              itemBuilder: (context, index) => TopSpotCard(spot: travelInfo.topSpots[index]),
                            ),
                          ),
                        ),
                      _sectionSpacing(),

                      // Hotels
                      if (travelInfo.hotels.isNotEmpty)
                        _buildSection(
                          title: 'Hotels',
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.75,
                            ),
                            itemCount: travelInfo.hotels.length,
                            itemBuilder: (context, index) => HotelCard(hotel: travelInfo.hotels[index]),
                          ),
                        ),
                      _sectionSpacing(),

                      // Itinerary
                      if (travelInfo.itinerary.isNotEmpty)
                        _buildSection(
                          title: 'Itinerary',
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.blue.shade200, width: 1),
                            ),
                            child: Text(
                              travelInfo.itinerary,
                              style: TextStyle(fontSize: 15, color: Colors.grey.shade800, height: 1.6),
                            ),
                          ),
                        ),
                      _sectionSpacing(),

                      // Fun Facts
                      if (travelInfo.facts.isNotEmpty)
                        _buildSection(
                          title: 'Fun Facts',
                          child: Column(
                            children: travelInfo.facts.map((fact) => _buildFactCard(fact)).toList(),
                          ),
                        ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        loading: () => _buildLoadingState(),
        error: (error, stack) => _buildErrorState(error.toString()),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/chat?place=${Uri.encodeComponent(widget.place)}');
        },
        icon: const Icon(Icons.chat),
        label: Text('Ask AI about ${widget.place}'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  Widget _buildFactCard(String fact) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.star, color: Colors.amber.shade600, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(fact, style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
          ),
        ],
      ),
    );
  }

  Widget _sectionSpacing() => const SizedBox(height: 24);

  Widget _buildLoadingState() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          flexibleSpace: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(color: Colors.white),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: List.generate(
                5,
                    (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              'Error loading data',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
            ),
            const SizedBox(height: 8),
            Text(error, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(travelInfoProvider(TravelInfoRequest(place: widget.place)));
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
