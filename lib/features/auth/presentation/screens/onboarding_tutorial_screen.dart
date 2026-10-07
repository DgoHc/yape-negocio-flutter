import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/di/injection_container.dart';

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
      title: '¡Bienvenido a SonoPay!',
      subtitle: 'PASO 1 DE 4',
      description: 'Tu asistente de cobros por voz en tiempo real para Yape y Plin. Cobra sin mirar el celular mientras conduces o atiendes.',
      icon: Icons.notifications_active_rounded,
      iconColor: const Color(0xFF2C2200),
      cardBgColor: const Color(0xFFFFCD19),
    ),
    OnboardingStep(
      title: 'Alertas de Voz al Instante',
      subtitle: 'PASO 2 DE 4',
      description: 'Cada Yape o Plin recibido se anuncia en voz alta ("Juan Pérez envió 15 soles") aunque tengas el celular bloqueado o guardado.',
      icon: Icons.record_voice_over_rounded,
      iconColor: const Color(0xFF1B5E20),
      cardBgColor: const Color(0xFFE8F5E9),
    ),
    OnboardingStep(
      title: 'Reportes y Filtro por Fechas',
      subtitle: 'PASO 3 DE 4',
      description: 'Filtra tus cobros diarios, calcula tu balance en tiempo real y descarga tus reportes detallados directamente a archivos Excel.',
      icon: Icons.description_rounded,
      iconColor: const Color(0xFF0D47A1),
      cardBgColor: const Color(0xFFE3F2FD),
    ),
    OnboardingStep(
      title: 'Vinculación de Dispositivos',
      subtitle: 'PASO 4 DE 4',
      description: 'Conecta cobradores o cajas secundarias con tu código de vinculación para recibir avisos de pago centralizados al instante.',
      icon: Icons.phonelink_setup_rounded,
      iconColor: const Color(0xFFE65100),
      cardBgColor: const Color(0xFFFFF3E0),
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
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // BARRA SUPERIOR CON BOTÓN OMITIR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFCD19),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _steps[_currentPage].subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF7A6800),
                          letterSpacing: 1.1,
                          fontFamily: 'Plus Jakarta Sans',
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: _completeOnboarding,
                    child: const Text(
                      'Omitir',
                      style: TextStyle(
                        color: Color(0xFF8C827A),
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        fontFamily: 'Plus Jakarta Sans',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // CARROUSEL DE PASOS (PAGEVIEW)
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _steps.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final step = _steps[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // TARJETA DE ILUSTRACIÓN
                        Container(
                          width: double.infinity,
                          height: 240,
                          decoration: BoxDecoration(
                            color: step.cardBgColor,
                            borderRadius: BorderRadius.circular(36),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                step.icon,
                                size: 52,
                                color: step.iconColor,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // TÍTULO DE PASO
                        Text(
                          step.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF2C2200),
                            fontFamily: 'Plus Jakarta Sans',
                            height: 1.2,
                          ),
                        ),

                        const SizedBox(height: 14),

                        // DESCRIPCIÓN DE PASO
                        Text(
                          step.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14.5,
                            color: Color(0xFF6E655F),
                            height: 1.5,
                            fontFamily: 'Plus Jakarta Sans',
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // BARRA INFERIOR DE INDICADORES Y BOTÓN PRINCIPAL
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // INDICADORES DE PUNTOS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _steps.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: _currentPage == index ? 28 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? const Color(0xFFFFCD19)
                              : const Color(0xFFE0E0E0),
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // BOTÓN SIGUIENTE / COMENZAR
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFCD19),
                        foregroundColor: const Color(0xFF2C2200),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      onPressed: () {
                        if (_currentPage < _steps.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          _completeOnboarding();
                        }
                      },
                      child: Text(
                        _currentPage == _steps.length - 1 ? '¡Comenzar Ahora!' : 'Siguiente',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Plus Jakarta Sans',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingStep {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color iconColor;
  final Color cardBgColor;

  OnboardingStep({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.cardBgColor,
  });
}
