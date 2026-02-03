import 'package:flutter/material.dart';
import 'package:hawklap/components/app_bar/custom_app_bar.dart';
import 'package:hawklap/core/theme/app_colors.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/services/explore/map_service.dart';

class ExploreView extends StatefulWidget {
  const ExploreView({super.key});

  @override
  State<ExploreView> createState() => _ExploreViewState();
}

class _ExploreViewState extends State<ExploreView> {
  final MapService _mapService = MapService();
  Position? _currentPosition;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    try {
      final position = await _mapService.getCurrentLocation();
      if (mounted) {
        setState(() {
          _currentPosition = position;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;

    return Scaffold(
      backgroundColor: colors.backgroundApp,
      appBar: const CustomAppBar(title: 'Explore'),
      body: _buildBody(colors),
    );
  }

  Widget _buildBody(AppColorScheme colors) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
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
            : const LatLng(48.8566, 2.3522); // Default to Paris if null

    return FlutterMap(
      options: MapOptions(initialCenter: initialCenter, initialZoom: 15.0),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.hawkr',
        ),
        if (_currentPosition != null)
          MarkerLayer(
            markers: [
              Marker(
                point: initialCenter,
                width: 80,
                height: 80,
                child: const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
