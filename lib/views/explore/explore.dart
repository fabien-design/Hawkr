import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/services/explore/map_service.dart';
import '../../core/theme/app_colors.dart';
import 'stalls/stall_list.dart';
import '../details/street_food_details.dart';
import 'filter/filters.dart';
import 'hawker_center_panel.dart';

class ExploreView extends StatefulWidget {
  const ExploreView({super.key});

  @override
  State<ExploreView> createState() => _ExploreViewState();
}

class _ExploreViewState extends State<ExploreView> {
  final MapService _mapService = MapService();
  final MapController _mapController = MapController();
  Position? _currentPosition;
  List<HawkerCenter> _nearbyHawkerCenters = [];
  List<StreetFood> _visibleStreetFoods = [];
  bool _isLoading = true;
  String? _errorMessage;
  double _searchRadius = 1.0; // In km
  double _currentZoom = 14.0;
  final double _streetFoodZoomThreshold = 16.5;

  @override
  void initState() {
    super.initState();
    _initAndFetchData();
  }

  Future<void> _initAndFetchData() async {
    try {
      final position = await _mapService.getCurrentLocation();
      _fetchHawkerCenters(position, _searchRadius);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchHawkerCenters(Position position, double radius) async {
    try {
      final hawkerCenters = await _mapService.getNearbyHawkerCenters(
        position,
        radius,
      );
      if (mounted) {
        setState(() {
          _currentPosition = position;
          _nearbyHawkerCenters = hawkerCenters;
          _searchRadius = radius;
          _isLoading = false;
        });
        if (_currentZoom >= _streetFoodZoomThreshold) {
          _fetchVisibleStreetFoods();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _fetchVisibleStreetFoods() async {
    List<StreetFood> allStalls = [];
    for (var center in _nearbyHawkerCenters) {
      final stalls = await _mapService.getStreetFoodsByHawkerCenter(center.id);
      allStalls.addAll(stalls);
    }
    if (mounted) {
      setState(() {
        _visibleStreetFoods = allStalls;
      });
    }
  }

  void _recenter() {
    if (_currentPosition != null) {
      _mapController.move(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        15.0,
      );
    }
  }

  void _openFilterMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FilterMenu(
          initialRadius: _searchRadius,
          onRadiusChanged: (newRadius) {
            if (_currentPosition != null) {
              _fetchHawkerCenters(_currentPosition!, newRadius);
            }
          },
        );
      },
    );
  }

  void _showHawkerCenterDetails(HawkerCenter center) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (_, controller) {
            return Container(
              decoration: BoxDecoration(
                color: colors.backgroundSurface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: StallListView(
                hawkerCenter: center,
                scrollController: controller,
              ),
            );
          },
        );
      },
    );
  }

  void _showStreetFoodDetails(String streetFoodId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StreetFoodDetailView(streetFoodId: streetFoodId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;
    const Color hawkColor = AppColors.brandPrimary;

    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: colors.borderFocused),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Text(
          _errorMessage!,
          style: TextStyle(color: colors.textPrimary),
        ),
      );
    }

    final LatLng initialCenter =
        _currentPosition != null
            ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
            : const LatLng(48.8566, 2.3522);

    return Scaffold(
      backgroundColor: colors.backgroundApp,
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: initialCenter,
              initialZoom: _currentZoom,
              onPositionChanged: (position, hasGesture) {
                if (position.zoom != null && position.zoom != _currentZoom) {
                  setState(() {
                    _currentZoom = position.zoom!;
                  });
                  if (_currentZoom >= _streetFoodZoomThreshold &&
                      _visibleStreetFoods.isEmpty) {
                    _fetchVisibleStreetFoods();
                  } else if (_currentZoom < _streetFoodZoomThreshold &&
                      _visibleStreetFoods.isNotEmpty) {
                    setState(() {
                      _visibleStreetFoods = [];
                    });
                  }
                }
              },
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    isDark
                        ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
                        : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.hawkr',
              ),
              if (_currentPosition != null) ...[
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: initialCenter,
                      radius: _searchRadius * 1000, // Convert km to meters
                      useRadiusInMeter: true,
                      color: hawkColor.withOpacity(0.15),
                      borderColor: hawkColor,
                      borderStrokeWidth: 2,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: initialCenter,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 30,
                      ),
                    ),
                    // Hawker Center Markers (Visible when zoom < threshold)
                    if (_currentZoom < _streetFoodZoomThreshold)
                      ..._nearbyHawkerCenters.map((center) {
                        return Marker(
                          point: LatLng(center.latitude, center.longitude),
                          width: 50,
                          height: 50,
                          child: GestureDetector(
                            onTap: () => _showHawkerCenterDetails(center),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: colors.mapHawkerCenterPin,
                                  size: 50,
                                ),
                                Positioned(
                                  top: 8,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: colors.backgroundCard,
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 18,
                                      minHeight: 18,
                                    ),
                                    child: Text(
                                      '${center.streetFoodCount}',
                                      style: TextStyle(
                                        color: colors.mapHawkerCenterPin,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    // Street Food Markers (Visible when zoom >= threshold)
                    if (_currentZoom >= _streetFoodZoomThreshold)
                      ..._visibleStreetFoods.map((stall) {
                        return Marker(
                          point: LatLng(stall.latitude, stall.longitude),
                          width: 30,
                          height: 30,
                          child: GestureDetector(
                            onTap: () => _showStreetFoodDetails(stall.id),
                            child: Icon(
                              Icons.location_on,
                              color: colors.mapStreetFoodPin,
                              size: 30,
                            ),
                          ),
                        );
                      }).toList(),
                  ],
                ),
              ],
            ],
          ),
          // Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 10,
                    bottom: 20,
                    left: 20,
                    right: 20,
                  ),
                  decoration: BoxDecoration(
                    color: colors.backgroundApp.withOpacity(0.4),
                  ),
                  child: Row(
                    children: [
                      // Search Bar
                      Expanded(
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: colors.backgroundCard,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: TextField(
                            textAlignVertical: TextAlignVertical.center,
                            style: TextStyle(color: colors.textPrimary),
                            decoration: InputDecoration(
                              isDense: true,
                              hintText: 'Search...',
                              hintStyle: TextStyle(color: colors.textSecondary),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: hawkColor,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Filter Button
                      GestureDetector(
                        onTap: _openFilterMenu,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: colors.backgroundCard,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.tune, color: hawkColor),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Recenter Button
                      GestureDetector(
                        onTap: _recenter,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: colors.backgroundCard,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.track_changes,
                            color: hawkColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Bottom Sliding Panel
          DraggableScrollableSheet(
            initialChildSize: 0.05, // Only show the bar
            minChildSize: 0.05,
            maxChildSize: 0.8,
            snap: true,
            snapSizes: const [0.05, 0.4, 0.8],
            builder: (context, scrollController) {
              return HawkerCenterPanel(
                hawkerCenters: _nearbyHawkerCenters,
                scrollController: scrollController,
                onCenterTap: _showHawkerCenterDetails,
              );
            },
          ),
        ],
      ),
    );
  }
}
