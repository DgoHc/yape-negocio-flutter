import 'dart:async';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/utils/app_logger.dart';

@lazySingleton
class NotificationPlatformService {
  static const EventChannel _eventChannel = EventChannel('pe.yape.transporte/notifications');
  static const MethodChannel _methodChannel = MethodChannel('pe.yape.transporte/settings');

  late final StreamController<Map<String, dynamic>> _streamController;
  late final Stream<Map<String, dynamic>> _notificationStream;
  StreamSubscription? _eventChannelSubscription;

  NotificationPlatformService() {
    AppLogger.i('NotificationPlatformService: Inicializando...');
    _streamController = StreamController<Map<String, dynamic>>.broadcast();
    _notificationStream = _streamController.stream;
    _listenToEventChannel();
  }

  Stream<Map<String, dynamic>> get notificationStream => _notificationStream;

  void _listenToEventChannel() {
    AppLogger.i('NotificationPlatformService: Escuchando EventChannel...');
    _eventChannelSubscription = _eventChannel.receiveBroadcastStream().listen(
      (event) {
        AppLogger.d('NotificationPlatformService: Evento recibido: $event');
        _streamController.add(Map<String, dynamic>.from(event));
      },
      onError: (error) {
        AppLogger.e('Error from EventChannel', error);
        _streamController.addError(error);
      },
    );
  }

  void dispose() {
    _eventChannelSubscription?.cancel();
    _streamController.close();
  }

  Future<bool> isNotificationPermissionGranted() async {
    try {
      final bool isGranted = await _methodChannel.invokeMethod('isNotificationServiceEnabled');
      return isGranted;
    } on PlatformException catch (e) {
      AppLogger.e('Error checking notification permission', e);
      return false;
    }
  }

  Future<void> openNotificationSettings() async {
    try {
      await _methodChannel.invokeMethod('openNotificationSettings');
    } on PlatformException catch (e) {
      AppLogger.e('Error opening notification settings', e);
    }
  }

  Future<bool> isAccessibilityServiceEnabled() async {
    try {
      final bool isEnabled = await _methodChannel.invokeMethod('isAccessibilityServiceEnabled');
      return isEnabled;
    } on PlatformException catch (e) {
      AppLogger.e('Error checking accessibility service', e);
      return false;
    }
  }

  Future<void> openAccessibilitySettings() async {
    try {
      await _methodChannel.invokeMethod('openAccessibilitySettings');
    } on PlatformException catch (e) {
      AppLogger.e('Error opening accessibility settings', e);
    }
  }
}
