
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/yt_design_system.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/auth_bloc.dart';

class SetupBusinessTypeScreen extends StatelessWidget {
  const SetupBusinessTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.authenticatedDriver) {
            context.go('/dashboard');
          } else if (state.status == AuthStatus.needsSubscription) {
            context.go('/subscription');
          }
        },
        child: Stack(
          children: [
            const BrandBlobHeader(height: 250, isDashboard: true, child: SizedBox.shrink()),
            SafeArea(
              child: _BusinessTypeForm(),
            ),
            // BOTÓN REGRESAR MANUAL
            Positioned(
              top: MediaQuery.of(context).padding.top + 10, 
              left: 10,
              child: Material(
                color: Colors.transparent,
                child: IconButton(
                  padding: const EdgeInsets.all(12),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 24),
                  onPressed: () => context.go('/'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BusinessTypeForm extends StatefulWidget {
  const _BusinessTypeForm();

  @override
  State<_BusinessTypeForm> createState() => _BusinessTypeFormState();
}

class _BusinessTypeFormState extends State<_BusinessTypeForm> {
  String? _selectedBusinessType;

  final List<String> _businessTypes = [
    'Transporte',
    'Comercio',
    'Restaurante',
    'Servicios',
    'Librería',
    'Otro'
  ];

  void _submit() {
    if (_selectedBusinessType != null) {
      context.read<AuthBloc>().add(
            UpdateProfile(
              businessType: _selectedBusinessType,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 100),
              Text(
                'Personaliza tu experiencia',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Selecciona el rubro de tu negocio para adaptar las herramientas.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              Padding(
                padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                child: Text('Rubro / Tipo de negocio', style: Theme.of(context).textTheme.labelMedium),
              ),
              ClayContainer(
                color: AppTheme.surfaceColor,
                borderRadius: 16,
                isPressed: true,
                shadowIntensity: 0.4,
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.store_outlined, color: Color(0xFFB8930A), size: 20),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  hint: const Text('Elige una opción', style: TextStyle(color: AppTheme.textPlaceholder)),
                  value: _selectedBusinessType,
                  items: _businessTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                  onChanged: (value) => setState(() => _selectedBusinessType = value),
                ),
              ),
              const SizedBox(height: 60),
              AppButton(
                label: 'Finalizar Configuración',
                onPressed: state.status == AuthStatus.loading || _selectedBusinessType == null ? null : _submit,
                isLoading: state.status == AuthStatus.loading,
              ),
            ],
          ),
        );
      },
    );
  }
}
