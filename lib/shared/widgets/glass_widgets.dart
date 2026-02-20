import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/themes/vision_os_colors.dart';
import '../../core/themes/vision_os_typography.dart';

class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.borderRadius,
    this.color,
    this.borderColor,
    this.blurSigma = 14,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final BorderRadiusGeometry? borderRadius;
  final Color? color;
  final Color? borderColor;
  final double blurSigma;

  @override
  Widget build(BuildContext context) {
    final resolvedRadius = borderRadius ?? BorderRadius.circular(16);

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? VisionOSColors.glassSurface,
        borderRadius: resolvedRadius,
        border: Border.all(
          color: borderColor ?? VisionOSColors.glassStroke,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: resolvedRadius,
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.borderRadius,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final BorderRadiusGeometry? borderRadius;

  @override
  Widget build(BuildContext context) {
    final card = GlassContainer(
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      child: child,
    );

    if (onTap == null) {
      return card;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: borderRadius as BorderRadius? ?? BorderRadius.circular(16),
      child: card,
    );
  }
}

class GlassButton extends StatelessWidget {
  const GlassButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.isPrimary = true,
    this.expand = false,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final foreground = isPrimary ? Colors.white : VisionOSColors.accentBlue;
    final background = isPrimary
        ? VisionOSColors.accentBlue
        : VisionOSColors.glassSurface;

    final button = ElevatedButton.icon(
      onPressed: onPressed,
      icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 18),
      label: Text(
        label,
        style: VisionOSTypography.button.copyWith(color: foreground),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: background,
        foregroundColor: foreground,
        side: isPrimary
            ? null
            : const BorderSide(color: VisionOSColors.accentBlue, width: 0.8),
        minimumSize: const Size(80, 42),
      ),
    );

    if (!expand) {
      return button;
    }

    return SizedBox(width: double.infinity, child: button);
  }
}

class GlassTextField extends StatelessWidget {
  const GlassTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.validator,
    this.onChanged,
    this.readOnly = false,
    this.onTap,
    this.suffix,
    this.obscureText = false,
  });

  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int maxLines;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffix;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      maxLines: maxLines,
      validator: validator,
      onChanged: onChanged,
      obscureText: obscureText,
      readOnly: readOnly,
      onTap: onTap,
      style: VisionOSTypography.bodyMedium,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        suffixIcon: suffix,
      ),
    );
  }
}

class GlassTag extends StatelessWidget {
  const GlassTag({
    super.key,
    required this.text,
    this.color = VisionOSColors.accentBlue,
    this.backgroundColor,
  });

  final String text;
  final Color color;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.32), width: 0.6),
      ),
      child: Text(
        text,
        style: VisionOSTypography.captionStrong.copyWith(color: color),
      ),
    );
  }
}

class ScreenBackground extends StatelessWidget {
  const ScreenBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            VisionOSColors.backgroundGradientTop,
            VisionOSColors.backgroundGradientBottom,
          ],
        ),
      ),
      child: child,
    );
  }
}
