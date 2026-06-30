
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/widgets/yt_design_system.dart';
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
      appBar: AppBar(title: const Text('Agregar vinculación')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocConsumer<NotificationBloc, NotificationState>(
          listener: (context, state) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage!), backgroundColor: Colors.red),
              );
            } else if (!state.isLoading && state.errorMessage == null && _codeController.text.isNotEmpty) {
              // Si terminó de cargar y no hay error, asumimos éxito
              // Nota: Sería mejor tener un flag de éxito en el estado
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Solicitud enviada con éxito')),
              );
              Navigator.pop(context);
            }
          },
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ingresa el código de notificaciones',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                YtTextField(
                  controller: _codeController,
                  label: 'Código de Notificaciones',
                  hintText: 'ABC-123456',
                ),
                const SizedBox(height: 16),
                YtButton(
                  label: 'Enviar solicitud',
                  isLoading: state.isLoading,
                  onPressed: () {
                    if (_codeController.text.isNotEmpty) {
                      context.read<NotificationBloc>().add(SendLinkRequest(_codeController.text));
                    }
                  },
                ),
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 32),
                const Text(
                  'O escanea un código QR',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                YtButton(
                  label: 'Escanear QR',
                  icon: Icons.qr_code_scanner,
                  isSecondary: true,
                  onPressed: _isScanning ? null : _openQrScanner,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _openQrScanner() async {
    setState(() => _isScanning = true);
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: MobileScanner(
          onDetect: (capture) {
            final List<Barcode> barcodes = capture.barcodes;
            for (final barcode in barcodes) {
              if (barcode.rawValue != null) {
                _codeController.text = barcode.rawValue!;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Código detectado: ${barcode.rawValue}')),
                );
                break;
              }
            }
          },
        ),
      ),
    );
    setState(() => _isScanning = false);
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }
}
