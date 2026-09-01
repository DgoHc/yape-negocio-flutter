import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ClayContainer extends StatelessWidget {
  final Widget? child;
  final Color color;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool isPressed;

  const ClayContainer({
    super.key,
    this.child,
    this.color = AppTheme.primaryColor,
    this.borderRadius = 24,
    this.padding,
    this.isPressed = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: AppTheme.clayShadow(baseColor: color, isPressed: isPressed),
      ),
      child: child,
    );
  }
}

class YtCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  const YtCard({
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
      child: child,
    );
  }
}

class YtButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSecondary;
  final Color? color;

  const YtButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    this.color,
  });

  @override
  State<YtButton> createState() => _YtButtonState();
}

class _YtButtonState extends State<YtButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.color ?? 
        (widget.isSecondary ? AppTheme.secondaryColor : AppTheme.primaryColor);
    
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.isLoading ? null : widget.onPressed,
      child: ClayContainer(
        color: widget.onPressed == null ? Colors.grey.shade300 : baseColor,
        isPressed: _isPressed,
        borderRadius: 18,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Center(
          child: widget.isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.textPrimary),
                )
              : Text(
                  widget.label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
        ),
      ),
    );
  }
}

class YtTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String? hintText;
  final bool isPassword;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;

  const YtTextField({
    super.key,
    this.controller,
    required this.label,
    this.hintText,
    this.isPassword = false,
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
          padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        ClayContainer(
          color: AppTheme.backgroundColor.withValues(alpha: 0.5),
          borderRadius: 18,
          isPressed: true, // Efecto "hundido"
          child: TextFormField(
            controller: controller,
            obscureText: isPassword,
            keyboardType: keyboardType,
            validator: validator,
            style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: AppTheme.textSecondary.withValues(alpha: 0.5)),
              prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppTheme.textSecondary) : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(18),
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
