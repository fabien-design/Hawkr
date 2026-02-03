import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final viewModel = context.read<AddStreetFoodViewModel>();
      final success = await viewModel.submit();

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Street food stall submitted for review')),
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
    final viewModel = context.watch<AddStreetFoodViewModel>();

    return Scaffold(
      backgroundColor: colors.backgroundApp,
      appBar: AppBar(
        title: const Text('Add Street Food'),
        backgroundColor: colors.backgroundSurface,
        elevation: 0,
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
              // TODO: Remplacer par map Leaflet
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colors.backgroundCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.textSecondary.withValues(alpha: 0.3)),
                ),
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
                      'Map selection coming soon',
                      style: TextStyle(color: colors.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lat: ${viewModel.latitude.toStringAsFixed(4)}, Lng: ${viewModel.longitude.toStringAsFixed(4)}',
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
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
}
