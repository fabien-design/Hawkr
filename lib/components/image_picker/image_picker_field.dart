import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hawklap/core/theme/app_colors.dart';

class ImagePickerField extends StatelessWidget {
  final File? imageFile;
  final ValueChanged<File> onImagePicked;
  final VoidCallback onImageRemoved;
  final String placeholderText;

  const ImagePickerField({
    super.key,
    required this.imageFile,
    required this.onImagePicked,
    required this.onImageRemoved,
    this.placeholderText = 'Add a photo (recommended)',
  });

  void _showSourceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder:
          (ctx) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Choose from gallery'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pick(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Take a photo'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pick(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _pick(ImageSource source) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (picked != null) {
      onImagePicked(File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;

    if (imageFile != null) {
      return _buildPreview(colors);
    }
    return _buildPlaceholder(context, colors);
  }

  Widget _buildPreview(AppColorScheme colors) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: 200,
            child: Image.file(imageFile!, fit: BoxFit.cover),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: onImageRemoved,
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context, AppColorScheme colors) {
    return GestureDetector(
      onTap: () => _showSourceSheet(context),
      child: SizedBox(
        width: double.infinity,
        height: 160,
        child: CustomPaint(
          painter: _DashedBorderPainter(color: colors.borderDefault),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.camera_alt_outlined,
                size: 40,
                color: colors.textDisabled,
              ),
              const SizedBox(height: 12),
              Text(
                placeholderText,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;

  _DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke;

    const dashWidth = 6.0;
    const dashSpace = 4.0;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(12),
    );

    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final end = (distance + dashWidth).clamp(0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end.toDouble()), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      color != oldDelegate.color;
}
