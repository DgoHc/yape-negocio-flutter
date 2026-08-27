import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/widgets/yt_design_system.dart';

class OnboardingTutorialScreen extends StatefulWidget {
  const OnboardingTutorialScreen({super.key});

  @override
  State<OnboardingTutorialScreen> createState() => _OnboardingTutorialScreenState();
}

class _OnboardingTutorialScreenState extends State<OnboardingTutorialScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingStep> _steps = [
    OnboardingStep(
      title: 'Registra tu Cuenta',
      description: 'Crea tu perfil en segundos. Elige tu rubro comercial y regístrate de forma tradicional o mediante tu cuenta de Google.',
      icon: Icons.person_add_rounded,
      color: const Color(0xFF7C4DFF),
      gradientColors: [const Color(0xFF7C4DFF), const Color(0xFF9E77F3)],
    ),
    OnboardingStep(
      title: 'Alertas de Pago por Voz',
      description: 'SonoPay intercepta tus notificaciones de Yape, Plin y más, leyéndolas en voz alta en tiempo real para que cobres sin mirar la pantalla.',
      icon: Icons.record_voice_over_rounded,
      color: const Color(0xFF00E5FF),
      gradientColors: [const Color(0xFF00BFA5), const Color(0xFF00E5FF)],
    ),
    OnboardingStep(
      title: 'Exporta tus Reportes',
      description: 'Mantén el control total de tu negocio. Exporta tu historial de cobros diarios o mensuales directamente a archivos de Excel.',
      icon: Icons.description_rounded,
      color: const Color(0xFF00E676),
      gradientColors: [const Color(0xFF00E676), const Color(0xFF69F0AE)],
    ),
    OnboardingStep(
      title: 'Vincula Dispositivos',
      description: 'Conecta múltiples terminales (cajas, conductores) con tu código de vinculación para centralizar cobros y alertas en tiempo real.',
      icon: Icons.phonelink_setup_rounded,
      color: const Color(0xFFFF3D00),
      gradientColors: [const Color(0xFFFF3D00), const Color(0xFFFF9100)],
    ),
  ];

  Future<void> _completeOnboarding() async {
    final prefs = sl<SharedPreferences>();
    await prefs.setBool('seen_onboarding', true);
    if (mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B071E) : const Color(0xFFF9F9FB),
      body: SafeArea(
        child: Column(
          children: [
            // Botón Omitir en la parte superior derecha
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: Text(
                    'Omitir',
                    style: TextStyle(
                      color: isDark ? Colors.white60 : Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
            
            // Cuerpo del carrusel (PageView)
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _steps.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final step = _steps[index];
                  return AnimatedOnboardingContent(
                    step: step,
                    isActive: _currentPage == index,
                  );
                },
              ),
            ),

            // Controles inferiores (Indicadores y Botones)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Dot Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _steps.length,
                      (index) => _buildDot(index, theme),
                    ),
                  ),
                  const SizedBox(height: 36),
                  
                  // Botón Siguiente / Comenzar
                  YtButton(
                    label: _currentPage == _steps.length - 1 ? 'Comenzar' : 'Siguiente',
                    onPressed: () {
                      if (_currentPage < _steps.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOutCubic,
                        );
                      } else {
                        _completeOnboarding();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index, ThemeData theme) {
    final isSelected = _currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 5),
      height: 8,
      width: isSelected ? 24 : 8,
      decoration: BoxDecoration(
        color: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.primary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingStep {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<Color> gradientColors;

  OnboardingStep({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.gradientColors,
  });
}

class AnimatedOnboardingContent extends StatelessWidget {
  final OnboardingStep step;
  final bool isActive;

  const AnimatedOnboardingContent({
    super.key,
    required this.step,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ilustración animada con iconos y gradientes
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutBack,
            padding: EdgeInsets.all(isActive ? 32 : 16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  step.color.withValues(alpha: 0.15),
                  step.color.withValues(alpha: 0.0),
                ],
                radius: 1.0,
              ),
            ),
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 600),
              tween: Tween(begin: 0.0, end: isActive ? 1.0 : 0.0),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: step.gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: step.color.withValues(alpha: 0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      step.icon,
                      size: 72,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 48),
          
          // Título del paso
          AnimatedOpacity(
            duration: const Duration(milliseconds: 400),
            opacity: isActive ? 1.0 : 0.0,
            child: Text(
              step.title,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          
          // Descripción del paso
          AnimatedOpacity(
            duration: const Duration(milliseconds: 500),
            opacity: isActive ? 1.0 : 0.0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                step.description,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
