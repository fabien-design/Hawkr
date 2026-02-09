import 'package:flutter/material.dart';
import 'package:hawklap/core/theme/app_colors.dart';

class HorizontalCarousel<T> extends StatelessWidget {
  final double height;
  final List<T> items;
  final AppColorScheme colors;
  final Widget Function(BuildContext, T) itemBuilder;

  const HorizontalCarousel({
    super.key,
    required this.height,
    required this.items,
    required this.colors,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'Nothing to show yet',
            style: TextStyle(color: colors.textSecondary),
          ),
        ),
      );
    }

    final controller = PageController(viewportFraction: 0.82);
    return SizedBox(
      height: height + 18,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: ScrollConfiguration(
          behavior: const _StretchScrollBehavior(),
          child: PageView.builder(
            controller: controller,
            itemCount: items.length,
            padEnds: false,
            clipBehavior: Clip.none,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 14),
                child: itemBuilder(context, items[index]),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _StretchScrollBehavior extends ScrollBehavior {
  const _StretchScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return StretchingOverscrollIndicator(
      axisDirection: details.direction,
      clipBehavior: Clip.none,
      child: child,
    );
  }
}
