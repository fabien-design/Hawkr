import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hawklap/components/image_picker/image_picker_field.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:hawklap/components/app_bar/custom_app_bar.dart';
import 'package:hawklap/core/theme/app_colors.dart';
import 'package:hawklap/viewmodels/add_street_food_viewmodel.dart';

class AddStreetFoodView extends StatelessWidget {
  const AddStreetFoodView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddStreetFoodViewModel()..loadHawkerCenters(),
      child: const _AddStreetFoodContent(),
    );
  }
}

class _AddStreetFoodContent extends StatefulWidget {
  const _AddStreetFoodContent();

  @override
  State<_AddStreetFoodContent> createState() => _AddStreetFoodContentState();
}

class _AddStreetFoodContentState extends State<_AddStreetFoodContent> {
  final _formKey = GlobalKey<FormState>();
  final _mapController = MapController();

  // Track selected hawker center to detect changes
  String? _prevHawkerCenterId;

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final viewModel = context.read<AddStreetFoodViewModel>();
      final success = await viewModel.submit();

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Street food stall submitted for review')),
        );
        Navigator.pop(context);
      } else if (viewModel.errorMessage != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${viewModel.errorMessage}')),
        );
      }
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;
    final viewModel = context.watch<AddStreetFoodViewModel>();

    // Move map when hawker center selection changes
    if (viewModel.selectedHawkerCenterId != _prevHawkerCenterId) {
      _prevHawkerCenterId = viewModel.selectedHawkerCenterId;

      if (viewModel.selectedHawkerCenter != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _mapController.move(
            LatLng(
              viewModel.selectedHawkerCenter!.latitude,
              viewModel.selectedHawkerCenter!.longitude,
            ),
            19.0,
          );
        });
      }
    }

    return Scaffold(
      backgroundColor: colors.backgroundApp,
      appBar: const CustomAppBar(
        title: 'Add Street Food',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add a food stall',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add a new food stall to an existing hawker center.',
                style: TextStyle(color: colors.textSecondary),
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                initialValue: viewModel.selectedHawkerCenterId,
                decoration: const InputDecoration(
                  labelText: 'Select Hawker Center',
                ),
                items: viewModel.hawkerCenters.map((center) {
                  return DropdownMenuItem(
                    value: center.id,
                    child: Text(center.name),
                  );
                }).toList(),
                onChanged: viewModel.setSelectedHawkerCenter,
                validator: viewModel.validateHawkerCenter,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: viewModel.nameController,
                decoration: const InputDecoration(
                  labelText: 'Stall Name',
                ),
                validator: viewModel.validateName,
              ),
              const SizedBox(height: 16),
              // Interactive map with Grab-style picker
              _buildInteractiveMap(viewModel, colors),
              const SizedBox(height: 16),
              ImagePickerField(
                imageFile: viewModel.imageFile,
                onImagePicked: viewModel.setImage,
                onImageRemoved: viewModel.removeImage,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: viewModel.descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: viewModel.isLoading ? null : _submit,
                  child: viewModel.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Submit',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInteractiveMap(
      AddStreetFoodViewModel viewModel, AppColorScheme colors) {
    final hasHawkerCenter = viewModel.selectedHawkerCenter != null;

    // Default to Singapore
    final center = hasHawkerCenter
        ? LatLng(viewModel.latitude, viewModel.longitude)
        : const LatLng(1.3521, 103.8198);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Stall Location',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 250,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasHawkerCenter
                  ? colors.borderFocused
                  : colors.textSecondary.withValues(alpha: 0.3),
              width: hasHawkerCenter ? 2 : 1,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Map
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: center,
                  initialZoom: hasHawkerCenter ? 19.0 : 11.0,
                  onPositionChanged: (position, hasGesture) {
                    if (hasGesture && hasHawkerCenter) {
                      viewModel.setLocation(
                        position.center.latitude,
                        position.center.longitude,
                      );
                    }
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.hawkr',
                  ),
                  // User location marker (blue dot with direction)
                  if (viewModel.userPosition != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(
                            viewModel.userPosition!.latitude,
                            viewModel.userPosition!.longitude,
                          ),
                          width: 30,
                          height: 30,
                          child: _buildUserLocationMarker(viewModel),
                        ),
                      ],
                    ),
                  // Hawker center area indicator (optional circle)
                  if (hasHawkerCenter)
                    CircleLayer(
                      circles: [
                        CircleMarker(
                          point: LatLng(
                            viewModel.selectedHawkerCenter!.latitude,
                            viewModel.selectedHawkerCenter!.longitude,
                          ),
                          radius: 30,
                          color: AppColors.brandPrimary.withValues(alpha: 0.1),
                          borderColor: AppColors.brandPrimary,
                          borderStrokeWidth: 2,
                        ),
                      ],
                    ),
                ],
              ),
              // Center pin (Grab style - fixed in center)
              if (hasHawkerCenter)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colors.backgroundCard,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            'Stall position',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 50,
                        ),
                      ],
                    ),
                  ),
                ),
              // Overlay when no hawker center selected
              if (!hasHawkerCenter)
                Container(
                  color: colors.backgroundCard.withValues(alpha: 0.8),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.store_outlined,
                          size: 48,
                          color: colors.textSecondary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Select a hawker center first',
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'The map will show its location',
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              // Instructions overlay
              if (hasHawkerCenter)
                Positioned(
                  bottom: 8,
                  left: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: colors.backgroundCard.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.touch_app,
                          size: 16,
                          color: colors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Drag the map to position the stall',
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Coordinates display
        Row(
          children: [
            Icon(
              Icons.location_on,
              color: hasHawkerCenter ? Colors.green : colors.textSecondary,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              hasHawkerCenter
                  ? 'Lat: ${viewModel.latitude.toStringAsFixed(6)}, Lng: ${viewModel.longitude.toStringAsFixed(6)}'
                  : 'No location set',
              style: TextStyle(
                color:
                    hasHawkerCenter ? colors.textPrimary : colors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUserLocationMarker(AddStreetFoodViewModel viewModel) {
    final heading = viewModel.userPosition?.heading;
    final hasHeading = heading != null && heading != 0.0;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer glow
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue.withValues(alpha: 0.2),
          ),
        ),
        // Direction indicator
        if (hasHeading)
          Transform.rotate(
            angle: heading * (3.14159 / 180),
            child: CustomPaint(
              size: const Size(30, 30),
              painter: _DirectionPainter(),
            ),
          ),
        // Blue dot
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Painter for direction indicator cone
class _DirectionPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    final path = ui.Path();
    final center = Offset(size.width / 2, size.height / 2);

    // Draw a cone pointing up (will be rotated by Transform.rotate)
    path.moveTo(center.dx, center.dy - 12);
    path.lineTo(center.dx - 8, center.dy);
    path.lineTo(center.dx + 8, center.dy);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
