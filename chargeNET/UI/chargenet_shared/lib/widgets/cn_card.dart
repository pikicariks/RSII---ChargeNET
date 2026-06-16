import 'package:flutter/material.dart';

import '../theme/chargenet_colors.dart';
import '../theme/chargenet_radii.dart';
import '../theme/chargenet_spacing.dart';

/// Station list card — slate surface with rounded-3xl corners.
class CnCard extends StatefulWidget {
  const CnCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.gradientBorder = false,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool gradientBorder;

  @override
  State<CnCard> createState() => _CnCardState();
}

class _CnCardState extends State<CnCard> {
  var _hovered = false;

  @override
  Widget build(BuildContext context) {
    final padding = widget.padding ??
        const EdgeInsets.all(ChargeNetSpacing.md);

    Widget content = AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
      padding: padding,
      decoration: BoxDecoration(
        color: ChargeNetColors.surface,
        borderRadius: BorderRadius.circular(ChargeNetRadii.xl),
        border: Border.all(
          color: widget.gradientBorder && _hovered
              ? ChargeNetColors.primary
              : ChargeNetColors.surfaceElevated,
          width: widget.gradientBorder && _hovered ? 1.5 : 1,
        ),
        boxShadow: widget.gradientBorder && _hovered
            ? [
                BoxShadow(
                  color: ChargeNetColors.primary.withValues(alpha: 0.15),
                  blurRadius: 12,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: widget.child,
    );

    final hoverable = widget.onTap != null || widget.gradientBorder;
    if (!hoverable) {
      return content;
    }

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(ChargeNetRadii.xl),
      child: MouseRegion(
        cursor: widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(ChargeNetRadii.xl),
          child: content,
        ),
      ),
    );
  }
}
