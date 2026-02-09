import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hawklap/components/app_bar/custom_app_bar.dart';
import 'package:hawklap/components/image_picker/image_picker_field.dart';
import 'package:hawklap/core/theme/app_colors.dart';
import 'package:hawklap/viewmodels/add_menu_item_viewmodel.dart';

class AddMenuItemView extends StatelessWidget {
  const AddMenuItemView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddMenuItemViewModel()..loadStalls(),
      child: const _AddMenuItemContent(),
    );
  }
}

class _AddMenuItemContent extends StatefulWidget {
  const _AddMenuItemContent();

  @override
  State<_AddMenuItemContent> createState() => _AddMenuItemContentState();
}

class _AddMenuItemContentState extends State<_AddMenuItemContent> {
  final _formKey = GlobalKey<FormState>();

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final viewModel = context.read<AddMenuItemViewModel>();
      final success = await viewModel.submit();

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Menu item submitted for review')),
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
    final viewModel = context.watch<AddMenuItemViewModel>();

    return Scaffold(
      backgroundColor: colors.backgroundApp,
      appBar: const CustomAppBar(title: 'Add Menu Item', showBackButton: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add a menu item',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add a new dish to an existing food stall.',
                style: TextStyle(color: colors.textSecondary),
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                initialValue: viewModel.selectedStallId,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Select Stall'),
                items:
                    viewModel.stalls.map((stall) {
                      return DropdownMenuItem(
                        value: stall.id,
                        child: Text(
                          stall.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                onChanged: viewModel.setSelectedStall,
                validator: viewModel.validateStall,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: viewModel.nameController,
                decoration: const InputDecoration(labelText: 'Dish Name'),
                validator: viewModel.validateName,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: viewModel.priceController,
                decoration: const InputDecoration(
                  labelText: 'Price (SGD)',
                  prefixText: '\$ ',
                ),
                keyboardType: TextInputType.number,
                validator: viewModel.validatePrice,
              ),
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
    );
  }
}
