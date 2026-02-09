import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hawklap/components/image_picker/image_picker_field.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:hawklap/components/app_bar/custom_app_bar.dart';
import 'package:hawklap/core/theme/app_colors.dart';
import 'package:hawklap/viewmodels/add_hawker_center_viewmodel.dart';

class AddHawkerCenterView extends StatelessWidget {
  const AddHawkerCenterView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddHawkerCenterViewModel(),
      child: const _AddHawkerCenterContent(),
    );
  }
}

class _AddHawkerCenterContent extends StatefulWidget {
  const _AddHawkerCenterContent();

  @override
  State<_AddHawkerCenterContent> createState() =>
      _AddHawkerCenterContentState();
}

class _AddHawkerCenterContentState extends State<_AddHawkerCenterContent> {
  final _formKey = GlobalKey<FormState>();
  final _addressFocusNode = FocusNode();
  final _mapController = MapController();

  // Track previous coordinates to detect changes
  double _prevLatitude = 0.0;
  double _prevLongitude = 0.0;

  @override
  void initState() {
    super.initState();
    _addressFocusNode.addListener(_onAddressFocusChange);
  }

  void _onAddressFocusChange() {
    if (!_addressFocusNode.hasFocus) {
      context.read<AddHawkerCenterViewModel>().clearSuggestions();
    }
  }

  @override
  void dispose() {
    _addressFocusNode.removeListener(_onAddressFocusChange);
    _addressFocusNode.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final viewModel = context.read<AddHawkerCenterViewModel>();
      final success = await viewModel.submit();

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hawker center submitted for review')),
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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;
    final viewModel = context.watch<AddHawkerCenterViewModel>();

    if (viewModel.latitude != _prevLatitude ||
        viewModel.longitude != _prevLongitude) {
      _prevLatitude = viewModel.latitude;
      _prevLongitude = viewModel.longitude;

      if (viewModel.latitude != 0.0 && viewModel.longitude != 0.0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _mapController.move(
            LatLng(viewModel.latitude, viewModel.longitude),
            19.0,
          );
        });
      }
    }

    return Scaffold(
      backgroundColor: colors.backgroundApp,
      appBar: const CustomAppBar(
        title: 'Add Hawker Center',
        showBackButton: true,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          viewModel.clearSuggestions();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Register a new hawker center',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Fill in the details below to add a new hawker center to our directory.',
                  style: TextStyle(color: colors.textSecondary),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: viewModel.nameController,
                  decoration: const InputDecoration(
                    labelText: 'Hawker Center Name',
                  ),
                  validator: viewModel.validateName,
                ),
                const SizedBox(height: 16),
                // Address field with autocomplete
                _buildAddressField(viewModel, colors),
                const SizedBox(height: 16),
                _buildMapPreview(viewModel, colors),
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
                    child:
                        viewModel.isLoading
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Text(
                              'Submit',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddressField(
    AddHawkerCenterViewModel viewModel,
    AppColorScheme colors,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: viewModel.addressController,
          focusNode: _addressFocusNode,
          decoration: InputDecoration(
            labelText: 'Address',
            suffixIcon:
                viewModel.isLoadingSuggestions
                    ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                    : const Icon(Icons.search),
          ),
          validator: viewModel.validateAddress,
          onChanged: viewModel.searchAddress,
        ),
        if (viewModel.suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: colors.backgroundCard,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: colors.textSecondary.withValues(alpha: 0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: viewModel.suggestions.length,
              separatorBuilder:
                  (_, __) => Divider(
                    height: 1,
                    color: colors.textSecondary.withValues(alpha: 0.2),
                  ),
              itemBuilder: (context, index) {
                final suggestion = viewModel.suggestions[index];
                return ListTile(
                  dense: true,
                  leading: Icon(
                    Icons.location_on_outlined,
                    color: colors.textSecondary,
                    size: 20,
                  ),
                  title: Text(
                    suggestion.displayName,
                    style: TextStyle(color: colors.textPrimary, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle:
                      suggestion.country != null
                          ? Text(
                            suggestion.country!,
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 12,
                            ),
                          )
                          : null,
                  onTap: () {
                    viewModel.selectSuggestion(suggestion);
                    FocusScope.of(context).unfocus();
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildMapPreview(
    AddHawkerCenterViewModel viewModel,
    AppColorScheme colors,
  ) {
    final hasLocation = viewModel.latitude != 0.0 && viewModel.longitude != 0.0;

    // Default to Singapore if no location selected
    final center =
        hasLocation
            ? LatLng(viewModel.latitude, viewModel.longitude)
            : const LatLng(1.3521, 103.8198);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  hasLocation
                      ? Colors.green.withValues(alpha: 0.5)
                      : colors.textSecondary.withValues(alpha: 0.3),
              width: hasLocation ? 2 : 1,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: center,
                  initialZoom: hasLocation ? 16.0 : 11.0,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.none,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.hawkr',
                  ),
                  if (hasLocation)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: center,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              if (!hasLocation)
                Container(
                  color: colors.backgroundCard.withValues(alpha: 0.7),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.map_outlined,
                          size: 40,
                          color: colors.textSecondary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Select an address to show location',
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 14,
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
        Row(
          children: [
            Icon(
              Icons.location_on,
              color: hasLocation ? Colors.green : colors.textSecondary,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              hasLocation
                  ? 'Lat: ${viewModel.latitude.toStringAsFixed(4)}, Lng: ${viewModel.longitude.toStringAsFixed(4)}'
                  : 'No coordinates set',
              style: TextStyle(
                color: hasLocation ? colors.textPrimary : colors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
