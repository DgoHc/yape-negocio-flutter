import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/widgets/yt_design_system.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';

class AddLinkScreen extends StatelessWidget {
  const AddLinkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<NotificationBloc>(),
      child: const AddLinkView(),
    );
  }
}

class AddLinkView extends StatefulWidget {
  const AddLinkView({super.key});

  @override
  State<AddLinkView> createState() => _AddLinkViewState();
}

class _AddLinkViewState extends State<AddLinkView> {
  final _codeController = TextEditingController();
  bool _isScanning = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Nueva Vinculación'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<NotificationBloc, NotificationState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage!), backgroundColor: AppTheme.errorColor));
          } else if (!state.isLoading && _codeController.text.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Solicitud enviada correctamente'), backgroundColor: AppTheme.successColor));
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Text('Conecta con un socio', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 12),
                const Text('Ingresa el código único del socio para empezar a recibir sus notificaciones de pago.', style: TextStyle(color: AppTheme.textSecondary)),
                const SizedBox(height: 48),
                YtTextField(
                  controller: _codeController,
                  label: 'Código de Vinculación',
                  hintText: 'ABC-123456',
                  prefixIcon: Icons.qr_code_rounded,
                ),
                const SizedBox(height: 32),
                AppButton(
                  label: 'Enviar Solicitud',
                  isLoading: state.isLoading,
                  onPressed: () {
                    if (_codeController.text.isNotEmpty) {
                      context.read<NotificationBloc>().add(SendLinkRequest(_codeController.text.trim()));
                    }
                  },
                ),
                const SizedBox(height: 48),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('O ESCANEA EL QR', style: Theme.of(context).textTheme.labelSmall)),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 32),
                AppButton(
                  label: 'Abrir Escáner QR',
                  icon: Icons.qr_code_scanner_rounded,
                  isSecondary: true,
                  onPressed: _isScanning ? null : _openQrScanner,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _openQrScanner() async {
    setState(() => _isScanning = true);
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(color: Colors.black, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: MobileScanner(
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                _codeController.text = barcodes.first.rawValue!;
                Navigator.pop(context);
              }
            },
          ),
        ),
      ),
    );
    setState(() => _isScanning = false);
  }
}
