
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/yt_design_system.dart';
import '../bloc/auth_bloc.dart';

class SetupBusinessTypeScreen extends StatelessWidget {
  const SetupBusinessTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configura tu negocio'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.authenticatedDriver) {
            context.go('/dashboard');
          } else if (state.status == AuthStatus.needsSubscription) {
            context.go('/subscription');
          }
        },
        child: const SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: _BusinessTypeForm(),
          ),
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

  // Opciones de rubro
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
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Selecciona tu rubro',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Rubro / Tipo de negocio',
                hintText: 'Selecciona tu rubro',
                prefixIcon: const Icon(Icons.store),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              value: _selectedBusinessType,
              items: _businessTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedBusinessType = value;
                });
              },
            ),
            const SizedBox(height: 40),
            YtButton(
              label: 'Continuar',
              onPressed: state.status == AuthStatus.loading ||
                      _selectedBusinessType == null
                  ? null
                  : _submit,
              isLoading: state.status == AuthStatus.loading,
            ),
          ],
        );
      },
    );
  }
}
