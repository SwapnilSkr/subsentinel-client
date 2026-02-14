import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class ServiceAvatar extends StatelessWidget {
  final String name;
  final String? logoUrl;
  final double size;
  final double borderRadius;
  final Color? textColor;
  final BoxShape shape;

  const ServiceAvatar({
    super.key,
    required this.name,
    this.logoUrl,
    this.size = 48,
    this.borderRadius = 12,
    this.textColor,
    this.shape = BoxShape.rectangle,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = _normalizedUrl(logoUrl);
    final fallback = _fallbackText(name);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.glassBackgroundFor(context),
        borderRadius: shape == BoxShape.rectangle
            ? BorderRadius.circular(borderRadius)
            : null,
        shape: shape,
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl == null
          ? _FallbackText(text: fallback, textColor: textColor)
          : Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  _FallbackText(text: fallback, textColor: textColor),
            ),
    );
  }
}

class _FallbackText extends StatelessWidget {
  final String text;
  final Color? textColor;

  const _FallbackText({required this.text, this.textColor});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: textColor ?? AppColors.active,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

String _fallbackText(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return '?';
  return trimmed[0].toUpperCase();
}

String? _normalizedUrl(String? value) {
  if (value == null) return null;
  final trimmed = value.trim();
  if (trimmed.isEmpty) return null;
  return trimmed;
}
