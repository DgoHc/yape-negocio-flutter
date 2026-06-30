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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
      ],
      child: MaterialApp.router(
        title: 'Yape Transporte',
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
      ),
    );
  }
}
