import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:injectable/injectable.dart';
import '../storage/drift/app_database.dart';
import '../utils/app_logger.dart';
import '../../features/connectivity/presentation/bloc/connectivity_bloc.dart';
import '../../features/connectivity/presentation/bloc/connectivity_state.dart';
import '../../features/payments/domain/repositories/payment_repository.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';

@lazySingleton
class SyncEngine {
  final SyncDao _syncDao;
  final ConnectivityBloc _connectivityBloc;
  final PaymentRepository _paymentRepository;
  final AuthRepository _authRepository;
  bool _isProcessing = false;

  SyncEngine(
    this._syncDao, 
    this._connectivityBloc,
    this._paymentRepository,
    this._authRepository,
  ) {
    // Listen to connectivity changes to trigger sync
    _connectivityBloc.stream.listen((state) {
      if (state.status == ConnectivityStatus.connected) {
        processQueue();
      }
    });
  }

  Future<void> processQueue() async {
    if (_isProcessing) return;
    
    final connectivityState = _connectivityBloc.state;
    if (connectivityState.status != ConnectivityStatus.connected) {
      AppLogger.d('SyncEngine: No connection, skipping process.');
      return;
    }

    _isProcessing = true;
    AppLogger.i('SyncEngine: Starting queue processing...');

    try {
      final pendingItems = await _syncDao.getPendingSyncs();
      
      for (final item in pendingItems) {
        // Re-check connectivity before each item
        if (_connectivityBloc.state.status != ConnectivityStatus.connected) break;

        await _processItem(item);
      }
    } catch (e, stack) {
      AppLogger.e('SyncEngine: Error processing queue', e, stack);
    } finally {
      _isProcessing = false;
      AppLogger.i('SyncEngine: Queue processing finished.');
    }
  }

  Future<void> _processItem(SyncQueueTableData item) async {
    AppLogger.d('SyncEngine: Processing item ${item.id} (${item.actionType})');
    
    await _syncDao.updateSyncStatus(item.id, 'processing');

    try {
      bool success = false;
      
      // Handle different action types
      switch (item.actionType) {
        case 'payment_sync':
          success = await _syncPayment(item.payload);
          break;
        case 'device_reg':
          success = await _registerDevice(item.payload);
          break;
        default:
          AppLogger.w('SyncEngine: Unknown action type: ${item.actionType}');
          success = true; // Mark as done to remove from queue if unknown
      }

      if (success) {
        await _syncDao.updateSyncStatus(item.id, 'done');
        // Optionally delete done items
        await _syncDao.deleteSynced(item.id);
        AppLogger.i('SyncEngine: Item ${item.id} processed successfully.');
      } else {
        await _handleFailure(item);
      }
    } catch (e) {
      AppLogger.e('SyncEngine: Error processing item ${item.id}', e);
      await _handleFailure(item);
    }
  }

  Future<void> _handleFailure(SyncQueueTableData item) async {
    final nextRetryCount = item.retryCount + 1;
    final maxRetries = 3;
    
    if (nextRetryCount >= maxRetries) {
      await _syncDao.updateSyncStatus(item.id, 'failed', retryCount: nextRetryCount);
      AppLogger.e('SyncEngine: Item ${item.id} failed after $maxRetries retries.');
    } else {
      // Exponential backoff: 1s, 2s, 4s
      final delaySeconds = pow(2, item.retryCount).toInt();
      AppLogger.w('SyncEngine: Item ${item.id} failed. Retrying in ${delaySeconds}s (Attempt $nextRetryCount)');
      
      await _syncDao.updateSyncStatus(item.id, 'failed', retryCount: nextRetryCount);
      
      // Schedule a retry
      Timer(Duration(seconds: delaySeconds), () {
        processQueue();
      });
    }
  }

  // Implementation of actual sync logic.
  Future<bool> _syncPayment(String payload) async {
    try {
      final result = await _paymentRepository.syncPayments();
      return result.isRight();
    } catch (e) {
      AppLogger.e('SyncEngine: Error syncing payment', e);
      return false;
    }
  }

  Future<bool> _registerDevice(String payload) async {
    try {
      final decoded = jsonDecode(payload);
      final Map<String, dynamic> deviceInfo = decoded is Map<String, dynamic> 
          ? decoded 
          : {'uuid': decoded.toString()};
      
      final result = await _authRepository.registerDevice(deviceInfo);
      return result.isRight();
    } catch (e) {
      AppLogger.e('SyncEngine: Error registering device', e);
      return false;
    }
  }
}
