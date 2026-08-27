import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/di/injection_container.dart';
import 'core/observers/app_bloc_observer.dart';
import 'core/router/app_router.dart';
import 'core/sync/background_sync.dart';
import 'core/utils/app_logger.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/connectivity/presentation/bloc/connectivity_bloc.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';
import 'features/payments/presentation/bloc/payments_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Personalización del error widget (Pantalla roja)
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 24),
            const Text(
              'Algo salió mal',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Ocurrió un error inesperado. Por favor, intenta reiniciar la aplicación.',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  };

  try {
    // Initialize Firebase
    await Firebase.initializeApp();

    await configureDependencies();
    Bloc.observer = AppBlocObserver();
    
    // Initialize WorkManager for background sync
    await BackgroundSyncManager.initialize();
    await BackgroundSyncManager.schedulePeriodicSync();
    
    runApp(const MyApp());
  } catch (e, stackTrace) {
    AppLogger.e('Error during app initialization', e, stackTrace);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<AuthBloc>()..add(AppStarted())),
        BlocProvider(create: (context) => sl<ConnectivityBloc>()),
        BlocProvider(create: (context) => sl<SettingsBloc>()..add(LoadControlSettings())),
        BlocProvider(create: (context) => sl<PaymentsBloc>()..add(LoadPayments())),
      ],
      child: MaterialApp.router(
        title: 'SonoPay',
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
      ),
    );
  }
}
