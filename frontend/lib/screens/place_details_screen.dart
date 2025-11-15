import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:travel_assistant/models/travel_info.dart';
import 'package:travel_assistant/screens/shimmer_widgets.dart';
import '../providers/travel_provider.dart';
import '../widgets/weather_card.dart';
import '../widgets/route_card.dart';
import '../widgets/top_spot_card.dart';
import '../widgets/hotel_card.dart';

class PlaceDetailsScreen extends ConsumerStatefulWidget {
  final Place place;

  const PlaceDetailsScreen({super.key, required this.place});

  @override
  ConsumerState<PlaceDetailsScreen> createState() => _PlaceDetailsScreenState();
}

class _PlaceDetailsScreenState extends ConsumerState<PlaceDetailsScreen>
    with SingleTickerProviderStateMixin {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;
  bool _showFab = false;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    );

    // Show FAB after a delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() => _showFab = true);
        _fabAnimationController.forward();
      }
    });
  }

  void _onRefresh() async {
    ref.invalidate(
        travelInfoProvider(TravelInfoRequest(place: widget.place.name)));
    await Future.delayed(const Duration(milliseconds: 1000));
    _refreshController.refreshCompleted();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final travelInfoAsync = ref.watch(
      travelInfoProvider(TravelInfoRequest(place: widget.place.name)),
    );

    return Scaffold(
      body: travelInfoAsync.when(
        data: (travelInfo) => SmartRefresher(
          controller: _refreshController,
          onRefresh: _onRefresh,
          header: WaterDropMaterialHeader(
            backgroundColor: Colors.blue.shade600,
            color: Colors.white,
          ),
          child: CustomScrollView(
            slivers: [
              // Enhanced Hero Image Sliver
              _buildHeroImageSliver(travelInfo),

              // Content with staggered animations
              SliverToBoxAdapter(
                child: AnimationLimiter(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: AnimationConfiguration.toStaggeredList(
                        duration: const Duration(milliseconds: 375),
                        childAnimationBuilder: (widget) => SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(child: widget),
                        ),
                        children: [
                          // About Section
                          if (travelInfo.description?.isNotEmpty ?? false)
                            _buildSection(
                              title: 'About',
                              icon: Icons.info_outline_rounded,
                              child:
                                  _buildAboutCard(travelInfo.description ?? ''),
                            ),
                          _sectionSpacing(),

                          // Weather Section
                          if (travelInfo.weather?.temperature != null)
                            _buildSection(
                              title: 'Weather',
                              icon: Icons.wb_sunny_outlined,
                              child: WeatherCard(weather: travelInfo.weather!),
                            ),
                          _sectionSpacing(),

                          // Route Section
                          if (travelInfo.route?.distance?.isNotEmpty ?? false)
                            _buildSection(
                              title: 'Route',
                              icon: Icons.directions_outlined,
                              child: RouteCard(route: travelInfo.route!),
                            ),
                          _sectionSpacing(),

                          // Attractions Section
                          if (travelInfo.attractions.isNotEmpty)
                            _buildSection(
                              title: 'Attractions',
                              icon: Icons.location_on_outlined,
                              child:
                                  _buildAttractionsList(travelInfo.attractions),
                            ),
                          _sectionSpacing(),

                          // Top Tourist Spots
                          if (travelInfo.topSpots.isNotEmpty)
                            _buildSection(
                              title: 'Top Tourist Spots',
                              icon: Icons.place_outlined,
                              child:
                                  _buildTopSpotsCarousel(travelInfo.topSpots),
                            ),
                          _sectionSpacing(),

                          // Hotels Section
                          if (travelInfo.hotels.isNotEmpty)
                            _buildSection(
                              title: 'Recommended Hotels',
                              icon: Icons.hotel_outlined,
                              child: _buildHotelsGrid(travelInfo.hotels),
                            ),
                          _sectionSpacing(),

                          // Attractions Section
                          if (travelInfo.attractions.isNotEmpty)
                            _buildSection(
                              title: 'Attractions',
                              icon: Icons.place_outlined,
                              child:
                                  _buildAttractionsList(travelInfo.attractions),
                            ),
                          _sectionSpacing(),

                          // Itinerary Section
                          if (travelInfo.itinerary?.isNotEmpty ?? false)
                            _buildSection(
                              title: 'Suggested Itinerary',
                              icon: Icons.calendar_today_outlined,
                              child: _buildItineraryCard(
                                  travelInfo.itinerary ?? ''),
                            ),
                          _sectionSpacing(),

                          // Fun Facts Section
                          if (travelInfo.facts.isNotEmpty)
                            _buildSection(
                              title: 'Fun Facts',
                              icon: Icons.lightbulb_outline_rounded,
                              child: Column(
                                children: travelInfo.facts
                                    .asMap()
                                    .entries
                                    .map((entry) => _buildFactCard(
                                          entry.value,
                                          entry.key,
                                        ))
                                    .toList(),
                              ),
                            ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        loading: () => TravelShimmer.placeDetailsShimmer(context),
        error: (error, stack) => _buildErrorState(error.toString()),
      ),
      floatingActionButton: _showFab
          ? ScaleTransition(
              scale: _fabAnimation,
              child: FloatingActionButton.extended(
                onPressed: () {
                  context.push(
                      '/chat?place=${Uri.encodeComponent(widget.place.name)}');
                },
                icon: const Icon(Icons.chat_bubble_outline_rounded),
                label: Text('Ask about ${widget.place.name}'),
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                elevation: 4,
              ),
            )
          : null,
    );
  }

  Widget _buildHeroImageSliver(travelInfo) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      stretch: true,
      backgroundColor: Colors.blue.shade600,
      flexibleSpace: FlexibleSpaceBar(
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            travelInfo.place.name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        centerTitle: true,
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        background: Stack(
          fit: StackFit.expand,
          children: [
            CarouselSlider.builder(
              itemCount:
                  travelInfo.images.isNotEmpty ? travelInfo.images.length : 1,
              itemBuilder: (context, index, realIndex) {
                final imageUrl = travelInfo.images.isNotEmpty
                    ? (travelInfo.images[index].url ?? '')
                    : '';
                if (imageUrl.isEmpty) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.blue.shade400,
                          Colors.blue.shade600,
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        size: 64,
                        color: Colors.white,
                      ),
                    ),
                  );
                }

                return CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(color: Colors.white),
                  ),
                  errorWidget: (context, url, error) => Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.blue.shade400,
                          Colors.blue.shade600,
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        size: 64,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              },
              options: CarouselOptions(
                height: 400,
                viewportFraction: 1.0,
                autoPlay: travelInfo.images.isNotEmpty,
                autoPlayInterval: const Duration(seconds: 4),
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                autoPlayCurve: Curves.fastOutSlowIn,
              ),
            ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.blue.shade600, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  Widget _buildAboutCard(String description) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        description,
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey.shade700,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildTopSpotsCarousel(List topSpots) {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: topSpots.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: ScaleAnimation(
              child: FadeInAnimation(
                child: TopSpotCard(spot: topSpots[index]),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAttractionsList(List attractions) {
    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: attractions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final a = attractions[index];
          return Container(
            width: 260,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  a.name ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  a.address ?? '',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: (a.category as List<dynamic>?)
                          ?.take(4)
                          .map((c) => Chip(
                                label: Text(
                                  c.toString(),
                                  style: const TextStyle(fontSize: 11),
                                ),
                                backgroundColor: Colors.blue.shade50,
                              ))
                          .toList() ??
                      [],
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHotelsGrid(List hotels) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: hotels.length,
      itemBuilder: (context, index) {
        return AnimationConfiguration.staggeredGrid(
          position: index,
          duration: const Duration(milliseconds: 375),
          columnCount: 2,
          child: ScaleAnimation(
            child: FadeInAnimation(
              child: HotelCard(hotel: hotels[index]),
            ),
          ),
        );
      },
    );
  }

  Widget _buildItineraryCard(String itinerary) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade50,
            Colors.cyan.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.blue.shade200, width: 1),
      ),
      child: Text(
        itinerary,
        style: TextStyle(
          fontSize: 15,
          color: Colors.grey.shade800,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildFactCard(String fact, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.star_rounded,
              color: Colors.amber.shade600,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              fact,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionSpacing() => const SizedBox(height: 32);

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                ref.invalidate(
                  travelInfoProvider(
                      TravelInfoRequest(place: widget.place.name)),
                );
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
