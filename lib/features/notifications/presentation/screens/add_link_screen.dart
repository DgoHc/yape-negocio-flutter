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
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isScanning = false;

  @override
  void dispose() {
    _codeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

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
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Conecta con un socio',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Busca a un usuario por nombre y apellido o ingresa su código de vinculación para compartir cobros.',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 28),

                // --- 1. BUSCADOR DE SOCIOS POR NOMBRE Y APELLIDO ---
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE8E9F3), width: 1.2),
                    boxShadow: AppTheme.softProShadow(intensity: 0.3),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val.trim()),
                    decoration: const InputDecoration(
                      hintText: 'Buscar socio por Nombre y Apellido...',
                      hintStyle: TextStyle(fontSize: 13, color: AppTheme.textPlaceholder),
                      prefixIcon: Icon(Icons.person_search_rounded, color: Color(0xFFFFCD19)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                  ),
                ),

                if (_searchQuery.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  SoftCard(
                    color: const Color(0xFFFFF8D6),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Color(0xFFFFCD19),
                          child: Icon(Icons.person_rounded, color: Color(0xFF2C2200)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _searchQuery,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const Text('Socio disponible en la red', style: TextStyle(fontSize: 11, color: Color(0xFF7A6800))),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFCD19),
                            foregroundColor: const Color(0xFF2C2200),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                          ),
                          onPressed: () {
                            context.read<NotificationBloc>().add(SendLinkRequest(_searchQuery));
                          },
                          child: const Text('Vincular', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 32),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('O INGRESA SU CÓDIGO', style: Theme.of(context).textTheme.labelSmall),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 28),

                // --- 2. CAMPO POR CÓDIGO DIRECTO ---
                YtTextField(
                  controller: _codeController,
                  label: 'Código de Vinculación',
                  hintText: 'SONO-8899',
                  prefixIcon: Icons.qr_code_rounded,
                ),
                const SizedBox(height: 20),
                AppButton(
                  label: 'Enviar Solicitud de Vinculación',
                  isLoading: state.isLoading,
                  onPressed: () {
                    if (_codeController.text.isNotEmpty) {
                      context.read<NotificationBloc>().add(SendLinkRequest(_codeController.text.trim()));
                    }
                  },
                ),

                const SizedBox(height: 36),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('O ESCANEA EL QR', style: Theme.of(context).textTheme.labelSmall),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 24),

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
