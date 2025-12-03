import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_radius.dart';
import 'package:trabalheja/core/constants/app_typography.dart';

/// Botão com animação e estado de loading
class AnimatedButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final String? iconPath;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double minWidth;

  const AnimatedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.iconPath,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.minWidth = 0,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isTapped = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.isLoading && widget.onPressed != null) {
      setState(() => _isTapped = true);
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (_isTapped) {
      setState(() => _isTapped = false);
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (_isTapped) {
      setState(() => _isTapped = false);
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.backgroundColor ?? AppColorsPrimary.primary700;
    final fgColor = widget.foregroundColor ?? AppColorsNeutral.neutral0;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.isLoading ? null : widget.onPressed,
        child: Container(
          height: 48,
          constraints: BoxConstraints(minWidth: widget.minWidth),
          decoration: BoxDecoration(
            color: widget.onPressed == null && !widget.isLoading
                ? bgColor.withOpacity(0.5)
                : bgColor,
            borderRadius: AppRadius.radius8,
            boxShadow: !widget.isLoading && widget.onPressed != null
                ? [
                    BoxShadow(
                      color: bgColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: AppRadius.radius8,
              onTap: widget.isLoading ? null : widget.onPressed,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.isLoading)
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(fgColor),
                        ),
                      )
                    else if (widget.iconPath != null)
                      SvgPicture.asset(
                        widget.iconPath!,
                        height: 20,
                        colorFilter: ColorFilter.mode(fgColor, BlendMode.srcIn),
                      )
                    else if (widget.icon != null)
                      Icon(widget.icon, size: 20, color: fgColor),

                    if (widget.isLoading ||
                        widget.iconPath != null ||
                        widget.icon != null)
                      const SizedBox(width: 8),

                    Text(
                      widget.isLoading ? 'Carregando...' : widget.text,
                      style: AppTypography.contentBold.copyWith(color: fgColor),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

