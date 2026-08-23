import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Skeleton shimmer used while a pairing code is being generated.
class ShimmerBox extends StatefulWidget {
  const ShimmerBox({
    super.key,
    this.width = double.infinity,
    this.height = 24,
    this.borderRadius = 8,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = AppColors.shimmerBase;
    final highlight = AppColors.shimmerHighlight;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        final slide = -1.5 + (t * 3);
        return ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: SizedBox(
            width: widget.width,
            height: widget.height,
            child: DecoratedBox(
              decoration: BoxDecoration(color: base),
              child: Stack(
                children: [
                  Transform.translate(
                    offset: Offset(widget.width * slide, 0),
                    child: Container(
                      width: widget.width * 0.6,
                      height: widget.height,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            base,
                            highlight,
                            base,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                          transform: const GradientRotation(-pi / 4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Grouped shimmer block shown inside the pairing-code card while loading.
class PairingCodeShimmer extends StatelessWidget {
  const PairingCodeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ShimmerBox(width: 180, height: 11),
          SizedBox(height: 20),
          ShimmerBox(width: 220, height: 40, borderRadius: 10),
          SizedBox(height: 16),
          ShimmerBox(width: 90, height: 16),
        ],
      ),
    );
  }
}
