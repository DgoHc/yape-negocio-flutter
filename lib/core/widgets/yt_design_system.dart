import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ClayContainer extends StatelessWidget {
  final Widget? child;
  final Color color;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool isPressed;
  final double? height;
  final double? width;
  final double shadowIntensity;

  const ClayContainer({
    super.key,
    this.child,
    this.color = AppTheme.backgroundColor,
    this.borderRadius = 28,
    this.padding,
    this.isPressed = false,
    this.height,
    this.width,
    this.shadowIntensity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: padding,
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: AppTheme.clayShadow(
          baseColor: color, 
          isPressed: isPressed,
          intensity: shadowIntensity,
        ),
      ),
      child: child,
    );
  }
}

class SoftCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  const SoftCard({
    super.key,
    required this.child,
    this.color,
    this.padding,
    this.borderRadius = 28,
  });

  @override
  Widget build(BuildContext context) {
    return ClayContainer(
      color: color ?? AppTheme.surfaceColor,
      borderRadius: borderRadius,
      padding: padding ?? const EdgeInsets.all(20),
      shadowIntensity: 0.6,
      child: child,
    );
  }
}

class YtCard extends SoftCard {
  const YtCard({
    super.key,
    required super.child,
    super.color,
    super.padding,
    super.borderRadius,
  });
}

class AppButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSecondary;
  final Color? color;
  final IconData? icon;
  final Widget? prefixWidget;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    this.color,
    this.icon,
    this.prefixWidget,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isSecondary = widget.isSecondary;
    final baseColor = widget.color ?? 
        (isSecondary ? Colors.white : AppTheme.primaryColor);
    
    final textColor = isSecondary ? AppTheme.textPrimary : const Color(0xFF3D2E00);
    
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.isLoading ? null : widget.onPressed,
      child: ClayContainer(
        color: widget.onPressed == null ? Colors.grey.shade200 : baseColor,
        isPressed: _isPressed,
        borderRadius: 16,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shadowIntensity: isSecondary ? 0.4 : 1.0,
        child: Center(
          child: widget.isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: textColor),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.prefixWidget != null) ...[
                      widget.prefixWidget!,
                      const SizedBox(width: 10),
                    ] else if (widget.icon != null) ...[
                      Icon(widget.icon, color: textColor, size: 20),
                      const SizedBox(width: 10),
                    ],
                    Text(
                      widget.label,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class YtButton extends AppButton {
  const YtButton({
    super.key,
    required super.label,
    super.onPressed,
    super.isLoading,
    super.isSecondary,
    super.color,
    super.icon,
  });
}

class IconActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final String? tooltip;

  const IconActionButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.color,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Tooltip(
        message: tooltip ?? '',
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color ?? Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class BrandBlobHeader extends StatelessWidget {
  final Widget child;
  final double height;
  final bool isDashboard;

  const BrandBlobHeader({
    super.key,
    required this.child,
    this.height = 280,
    this.isDashboard = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isDashboard) {
      return SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          children: [
            Positioned(
              top: -height * 0.1,
              left: -20,
              right: -20,
              child: Container(
                height: height * 1.1,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.elliptical(250, 40),
                  ),
                ),
              ),
            ),
            Center(child: child),
          ],
        ),
      );
    }

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -60,
            left: -40,
            child: Container(
              width: 320,
              height: 320,
              decoration: const BoxDecoration(
                color: AppTheme.secondaryColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 20,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Center(child: child),
        ],
      ),
    );
  }
}

class YtTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String? hintText;
  final bool isPassword;
  final bool obscureText;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;

  const YtTextField({
    super.key,
    this.controller,
    required this.label,
    this.hintText,
    this.isPassword = false,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        ClayContainer(
          color: AppTheme.surfaceColor,
          borderRadius: 16,
          isPressed: true, 
          shadowIntensity: 0.4,
          child: TextFormField(
            controller: controller,
            obscureText: isPassword || obscureText,
            keyboardType: keyboardType,
            validator: validator,
            style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(color: AppTheme.textPlaceholder),
              prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: const Color(0xFFB8930A), size: 20) : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}

class YtLoader extends StatelessWidget {
  const YtLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: AppTheme.primaryColor,
      ),
    );
  }
}
