import 'package:flutter/material.dart';

class YtButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSecondary;
  final IconData? icon;

  const YtButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final buttonChild = isLoading
        ? const SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: Colors.white),
                const SizedBox(width: 10),
              ],
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: Colors.white,
                ),
              ),
            ],
          );

    if (isSecondary) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.5),
            width: 1.5,
          ),
          color: theme.colorScheme.primary.withValues(alpha: 0.05),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 56,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: isLoading
                  ? SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, size: 20, color: theme.colorScheme.primary),
                          const SizedBox(width: 10),
                        ],
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: onPressed == null
              ? [Colors.grey.shade400, Colors.grey.shade500]
              : [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withValues(alpha: 0.85),
                  theme.colorScheme.secondary,
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: onPressed == null
            ? []
            : [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 56,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: buttonChild,
          ),
        ),
      ),
    );
  }
}

class YtCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final List<Color>? gradientColors;
  final Color? borderColor;

  const YtCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.gradientColors,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: gradientColors != null
            ? LinearGradient(
                colors: gradientColors!,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : isDark
                ? LinearGradient(
                    colors: [
                      const Color(0xFF1B1437),
                      const Color(0xFF151026).withValues(alpha: 0.95),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : const LinearGradient(
                    colors: [Colors.white, Color(0xFFF9F9FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
        border: Border.all(
          color: borderColor ?? (isDark
              ? const Color(0xFF7C4DFF).withValues(alpha: 0.25)
              : const Color(0xFFE0E0F0)),
          width: 1.2,
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: const Color(0xFF1A1528).withValues(alpha: 0.05),
              blurRadius: 24,
              offset: const Offset(0, 10),
            )
          else
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(20.0),
            child: child,
          ),
        ),
      ),
    );
  }
}

class YtTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final IconData? prefixIcon;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool autovalidate;
  final bool readOnly;

  const YtTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.prefixIcon,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.autovalidate = false,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: isDark ? Colors.white70 : Colors.black87,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          autovalidateMode: autovalidate
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          readOnly: readOnly,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: isDark ? Colors.white30 : Colors.grey.shade500,
            ),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: theme.colorScheme.primary)
                : null,
            filled: true,
            fillColor: isDark
                ? const Color(0xFF1B1437).withValues(alpha: 0.6)
                : Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDark
                    ? const Color(0xFF7C4DFF).withValues(alpha: 0.15)
                    : Colors.grey.shade200,
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDark
                    ? const Color(0xFF7C4DFF).withValues(alpha: 0.25)
                    : Colors.grey.shade200,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2.0,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: theme.colorScheme.error,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
            strokeWidth: 3.5,
          ),
          const SizedBox(height: 12),
          const Text(
            'Cargando...',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class YtBadge extends StatelessWidget {
  final String label;
  final Color? color;

  const YtBadge({super.key, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color != null ? Colors.white : Theme.of(context).colorScheme.primary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
