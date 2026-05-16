import 'package:flutter/material.dart';
import 'package:shree/theme/app_theme.dart';

class BrandBackground extends StatelessWidget {
  const BrandBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppTheme.appGradient),
      child: Stack(
        children: [
          const Positioned(
            top: -120,
            right: -50,
            child: _GlowOrb(
              size: 260,
              colors: [Color(0x264C8A79), Color(0x0006110F)],
            ),
          ),
          const Positioned(
            top: 140,
            left: -110,
            child: _GlowOrb(
              size: 240,
              colors: [Color(0x1FE1BF78), Color(0x0006110F)],
            ),
          ),
          const Positioned(
            bottom: -120,
            right: -80,
            child: _GlowOrb(
              size: 280,
              colors: [Color(0x1A35675C), Color(0x0006110F)],
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.02),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.12),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.colors});

  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: colors),
        ),
      ),
    );
  }
}
