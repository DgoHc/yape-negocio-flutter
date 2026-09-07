import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/yt_design_system.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/auth_bloc.dart';

class UserRegistrationScreen extends StatelessWidget {
  const UserRegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.needsSubscription) context.go('/subscription');
          else if (state.status == AuthStatus.needsVerification) context.go('/verify-email');
          else if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!), backgroundColor: AppTheme.errorColor));
            context.read<AuthBloc>().add(const ClearError());
          }
        },
        child: Stack(
          children: [
            const BrandBlobHeader(height: 250, child: SizedBox.shrink()),
            
            // Cuerpo del Formulario
            SafeArea(
              child: _RegistrationForm(),
            ),

            // BOTÓN REGRESAR MANUAL - Siempre encima de todo
            Positioned(
              top: MediaQuery.of(context).padding.top + 10, 
              left: 10,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () {
                    context.read<AuthBloc>().add(const ResetAuthStatus());
                    context.go('/');
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary, size: 24),
                  ),
                ),
              ),
            ),
          ],
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
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _passwordConfirmController;
  late final TextEditingController _phoneController;
  String? _selectedBusinessType;

  @override
  void initState() {
    super.initState();
    final profile = context.read<AuthBloc>().state.userProfile;
    _nameController = TextEditingController(text: profile?.name);
    _emailController = TextEditingController(text: profile?.email);
    _passwordController = TextEditingController();
    _passwordConfirmController = TextEditingController();
    _phoneController = TextEditingController(text: profile?.phone);
    _selectedBusinessType = profile?.businessType;
  }

  final List<String> _businessTypes = ['Transporte', 'Comercio', 'Restaurante', 'Servicios', 'Librería', 'Otro'];

  @override
  void dispose() { _nameController.dispose(); _emailController.dispose(); _passwordController.dispose(); _passwordConfirmController.dispose(); _phoneController.dispose(); super.dispose(); }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(RegisterUser(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            phone: _phoneController.text.isNotEmpty ? _phoneController.text.trim() : null,
            businessType: _selectedBusinessType,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(32.0, 80.0, 32.0, 32.0), // Padding top para no tapar el botón back
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Text('Únete a SonoPay', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                Text('Gestiona tus pagos de forma profesional', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 40),
                YtTextField(controller: _nameController, label: 'Nombre Completo', hintText: 'Ej. Juan Pérez', prefixIcon: Icons.person_outline, validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null),
                const SizedBox(height: 20),
                YtTextField(controller: _phoneController, label: 'Teléfono (Opcional)', hintText: '999 888 777', prefixIcon: Icons.phone_android_outlined, keyboardType: TextInputType.phone),
                const SizedBox(height: 20),
                YtTextField(controller: _emailController, label: 'Correo Electrónico', hintText: 'tu@correo.com', prefixIcon: Icons.email_outlined, keyboardType: TextInputType.emailAddress, validator: (v) => (v == null || v.isEmpty) ? 'Campo requerido' : (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(v) ? 'Correo inválido' : null)),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Rubro / Tipo de negocio', prefixIcon: Icon(Icons.storefront_outlined), border: InputBorder.none),
                  value: _selectedBusinessType,
                  items: _businessTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) => setState(() => _selectedBusinessType = v),
                  validator: (v) => v == null ? 'Selecciona un rubro' : null,
                ),
                const SizedBox(height: 20),
                YtTextField(controller: _passwordController, label: 'Contraseña', hintText: 'Mínimo 6 caracteres', prefixIcon: Icons.lock_outline, obscureText: true, validator: (v) => v == null || v.length < 6 ? 'Mínimo 6 caracteres' : null),
                const SizedBox(height: 20),
                YtTextField(controller: _passwordConfirmController, label: 'Confirmar Contraseña', hintText: 'Repite tu contraseña', prefixIcon: Icons.lock_clock_outlined, obscureText: true, validator: (v) => v != _passwordController.text ? 'No coinciden' : null),
                const SizedBox(height: 40),
                AppButton(label: 'Registrarme', isLoading: state.status == AuthStatus.loading, onPressed: _submit),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }
}
