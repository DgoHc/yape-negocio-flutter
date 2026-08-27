import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/yt_design_system.dart';
import '../bloc/auth_bloc.dart';

class UserRegistrationScreen extends StatelessWidget {
  const UserRegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.needsSubscription) {
            context.go('/subscription');
          } else if (state.status == AuthStatus.needsVerification) {
            context.go('/verify-email');
          } else if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!), backgroundColor: Colors.red),
            );
            context.read<AuthBloc>().add(const ClearError());
          }
        },
        child: const SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: _RegistrationForm(),
          ),
        ),
      ),
    );
  }
}

class _RegistrationForm extends StatefulWidget {
  const _RegistrationForm();

  @override
  State<_RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<_RegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _phoneController = TextEditingController();
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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            RegisterUser(
              name: _nameController.text,
              email: _emailController.text,
              password: _passwordController.text,
              phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
              businessType: _selectedBusinessType,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Crea tu cuenta',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                YtTextField(
                  controller: _nameController,
                  label: 'Nombre completo',
                  hintText: 'Tu nombre',
                  prefixIcon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu nombre';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                YtTextField(
                  controller: _phoneController,
                  label: 'Teléfono',
                  hintText: '999888777',
                  prefixIcon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu teléfono';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                YtTextField(
                  controller: _emailController,
                  label: 'Correo electrónico',
                  hintText: 'correo@ejemplo.com',
                  prefixIcon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu correo electrónico';
                    }
                    // Simple email validation
                    final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');
                    if (!emailRegex.hasMatch(value)) {
                      return 'Por favor ingresa un correo válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Selector de rubro
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
                  initialValue: _selectedBusinessType,
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
                const SizedBox(height: 20),
                YtTextField(
                  controller: _passwordController,
                  label: 'Contraseña',
                  hintText: 'Tu contraseña',
                  prefixIcon: Icons.lock,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu contraseña';
                    }
                    if (value.length < 6) {
                      return 'La contraseña debe tener al menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                YtTextField(
                  controller: _passwordConfirmController,
                  label: 'Confirmar contraseña',
                  hintText: 'Confirma tu contraseña',
                  prefixIcon: Icons.lock,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor confirma tu contraseña';
                    }
                    if (value != _passwordController.text) {
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),
                YtButton(
                  label: 'Continuar',
                  onPressed: state.status == AuthStatus.loading ? null : _submit,
                  isLoading: state.status == AuthStatus.loading,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
