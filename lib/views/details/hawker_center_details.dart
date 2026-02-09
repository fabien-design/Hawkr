import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hawklap/models/hawker_center.dart' as model;
import 'package:hawklap/services/hawker_center_service.dart';
import '../../core/services/explore/map_service.dart';
import '../../core/theme/app_colors.dart';
import '../../components/rating/rating_widget.dart';
import 'street_food_details.dart';

class HawkerCenterDetailView extends StatefulWidget {
  final String hawkerCenterId;

  const HawkerCenterDetailView({super.key, required this.hawkerCenterId});

  @override
  State<HawkerCenterDetailView> createState() => _HawkerCenterDetailViewState();
}

class _HawkerCenterDetailViewState extends State<HawkerCenterDetailView> {
  final HawkerCenterService _hawkerCenterService = HawkerCenterService();
  final MapService _mapService = MapService();
  bool _isLoading = true;
  model.HawkerCenter? _hawkerCenter;
  List<StreetFood> _streetFoods = [];
  bool _isFavorite = false;
  bool _isLiked = false;
  bool _isDisliked = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        _hawkerCenterService.getHawkerCenterDetails(widget.hawkerCenterId),
        _mapService.getStreetFoodsByHawkerCenter(widget.hawkerCenterId),
        _mapService.isHawkerCenterFavorite(widget.hawkerCenterId),
      ]);
      if (mounted) {
        setState(() {
          _hawkerCenter = results[0] as model.HawkerCenter;
          _streetFoods = results[1] as List<StreetFood>;
          _isFavorite = results[2] as bool;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading details: $e')));
      }
    }
  }

  void _toggleFavorite() async {
    try {
      await _mapService.toggleHawkerCenterFavorite(widget.hawkerCenterId);
      setState(() {
        _isFavorite = !_isFavorite;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating favorite: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: colors.backgroundApp,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_hawkerCenter == null) {
      return Scaffold(
        backgroundColor: colors.backgroundApp,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: const Center(child: Text('Hawker center not found')),
      );
    }

    final hc = _hawkerCenter!;

    return Scaffold(
      backgroundColor: colors.backgroundApp,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, hc, colors),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRatingSection(colors),
                  const SizedBox(height: 16),
                  Text(
                    hc.name,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 18,
                        color: colors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          hc.address,
                          style: TextStyle(
                            fontSize: 16,
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (hc.description != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      hc.description!,
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => _openInGoogleMaps(hc),
                    child: _buildMapSection(hc, colors),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Text(
                        'Stalls',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${_streetFoods.length})',
                        style: TextStyle(
                          fontSize: 18,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_streetFoods.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Text(
                          'No stalls found',
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    )
                  else
                    ..._streetFoods.map(
                      (stall) => _buildStallCard(stall, colors),
                    ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    model.HawkerCenter hc,
    AppColorScheme colors,
  ) {
    return Stack(
      children: [
        Container(
          height: 300,
          width: double.infinity,
          decoration: BoxDecoration(color: colors.backgroundGreyInformation),
          child:
              hc.imageUrl != null
                  ? Image.network(hc.imageUrl!, fit: BoxFit.cover)
                  : Center(
                    child: Icon(
                      Icons.storefront,
                      size: 50,
                      color: colors.textDisabled,
                    ),
                  ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCircularIconButton(
                  icon: Icons.arrow_back,
                  onTap: () => Navigator.pop(context),
                  colors: colors,
                  backgroundColor: Colors.black.withValues(alpha: 0.5),
                  iconColor: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCircularIconButton({
    required IconData icon,
    required VoidCallback onTap,
    required AppColorScheme colors,
    required Color backgroundColor,
    required Color iconColor,
    double size = 40,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }

  Future<void> _openInGoogleMaps(model.HawkerCenter hc) async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${hc.latitude},${hc.longitude}',
    );
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  Widget _buildMapSection(model.HawkerCenter hc, AppColorScheme colors) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final point = LatLng(hc.latitude, hc.longitude);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 180,
        child: AbsorbPointer(
          child: FlutterMap(
            options: MapOptions(
              initialCenter: point,
              initialZoom: 15,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    isDark
                        ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
                        : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.hawkr',
                retinaMode: isDark ? RetinaMode.isHighDensity(context) : false,
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: point,
                    width: 40,
                    height: 40,
                    child: Icon(
                      Icons.location_on,
                      color: AppColors.brandPrimary,
                      size: 36,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingSection(AppColorScheme colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CommunityRatingWidget(
          percentage: '96%',
          initialIsLiked: _isLiked,
          initialIsDisliked: _isDisliked,
          onRatingChanged: (liked, disliked) {
            setState(() {
              _isLiked = liked;
              _isDisliked = disliked;
            });
          },
        ),
        _buildCircularIconButton(
          icon: _isFavorite ? Icons.favorite : Icons.favorite_border,
          onTap: _toggleFavorite,
          colors: colors,
          backgroundColor: colors.backgroundCard,
          iconColor: _isFavorite ? Colors.red : colors.actionFavorite,
        ),
      ],
    );
  }

  Widget _buildStallCard(StreetFood stall, AppColorScheme colors) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StreetFoodDetailView(streetFoodId: stall.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.backgroundCard,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Container(
                width: 100,
                height: 100,
                color: colors.backgroundGreyInformation,
                child:
                    stall.imageUrl != null
                        ? Image.network(stall.imageUrl!, fit: BoxFit.cover)
                        : Center(
                          child: Icon(
                            Icons.storefront,
                            color: colors.textDisabled,
                          ),
                        ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stall.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stall.description ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: colors.textSecondary, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.restaurant_menu,
                        size: 16,
                        color: AppColors.brandPrimary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${stall.menuItems.length} dish${stall.menuItems.length != 1 ? 'es' : ''}',
                        style: const TextStyle(
                          color: AppColors.brandPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: colors.textSecondary),
          ],
        ),
      ),
    );
  }
}
