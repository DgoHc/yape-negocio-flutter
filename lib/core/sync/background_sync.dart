import 'package:workmanager/workmanager.dart';
import '../di/injection_container.dart';
import 'sync_engine.dart';
import '../utils/app_logger.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    AppLogger.i('WorkManager: Starting background task: $task');
    
    try {
      await configureDependencies();
      final syncEngine = sl<SyncEngine>();
      await syncEngine.processQueue();
      return Future.value(true);
    } catch (e, stack) {
      AppLogger.e('WorkManager: Background task failed', e, stack);
      return Future.value(false);
    }
  });
}

class BackgroundSyncManager {
  static const String syncTaskName = 'pe.yape.transporte.sync_task';

  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
    );
  }

  static Future<void> schedulePeriodicSync() async {
    await Workmanager().registerPeriodicTask(
      '1',
      syncTaskName,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }

  static Future<void> runOnce() async {
    await Workmanager().registerOneOffTask(
      DateTime.now().millisecondsSinceEpoch.toString(),
      syncTaskName,
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }
}
