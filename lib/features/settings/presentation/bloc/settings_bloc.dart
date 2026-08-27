import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:drift/drift.dart' as drift;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/storage/drift/app_database.dart';
import '../../../../core/network/network_config_service.dart';
import '../../../../core/services/tts_service.dart';
import '../../../auth/data/mappers/user_profile_mapper.dart';
import '../../../auth/data/models/auth_models.dart';

// Events
abstract class SettingsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadSecondaryNumbers extends SettingsEvent {}

class AddSecondaryNumber extends SettingsEvent {
  final String phoneNumber;
  final String type;
  AddSecondaryNumber(this.phoneNumber, this.type);

  @override
  List<Object?> get props => [phoneNumber, type];
}

class DeleteSecondaryNumber extends SettingsEvent {
  final int id;
  DeleteSecondaryNumber(this.id);

  @override
  List<Object?> get props => [id];
}

class LoadBaseUrl extends SettingsEvent {}

class UpdateBaseUrl extends SettingsEvent {
  final String url;
  UpdateBaseUrl(this.url);

  @override
  List<Object?> get props => [url];
}

class AutoDetectBaseUrl extends SettingsEvent {}

class ToggleDetection extends SettingsEvent {
  final bool enabled;
  ToggleDetection(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class UpdateVolume extends SettingsEvent {
  final double volume;
  UpdateVolume(this.volume);

  @override
  List<Object?> get props => [volume];
}

class ToggleMute extends SettingsEvent {
  final bool isMuted;
  ToggleMute(this.isMuted);

  @override
  List<Object?> get props => [isMuted];
}

class LoadControlSettings extends SettingsEvent {}

class UpdateRetentionDays extends SettingsEvent {
  final int days;
  UpdateRetentionDays(this.days);

  @override
  List<Object?> get props => [days];
}

// States
class SettingsState extends Equatable {
  final List<SecondaryNumbersTableData> secondaryNumbers;
  final bool isLoading;
  final bool isAutoDetecting;
  final String? error;
  final String? baseUrl;
  final bool isDetectionEnabled;
  final double volume;
  final bool isMuted;
  final int retentionDays;

  const SettingsState({
    this.secondaryNumbers = const [],
    this.isLoading = false,
    this.isAutoDetecting = false,
    this.error,
    this.baseUrl,
    this.isDetectionEnabled = true,
    this.volume = 1.0,
    this.isMuted = false,
    this.retentionDays = 30,
  });

  SettingsState copyWith({
    List<SecondaryNumbersTableData>? secondaryNumbers,
    bool? isLoading,
    bool? isAutoDetecting,
    String? error,
    String? baseUrl,
    bool? isDetectionEnabled,
    double? volume,
    bool? isMuted,
    int? retentionDays,
  }) {
    return SettingsState(
      secondaryNumbers: secondaryNumbers ?? this.secondaryNumbers,
      isLoading: isLoading ?? this.isLoading,
      isAutoDetecting: isAutoDetecting ?? this.isAutoDetecting,
      error: error ?? this.error,
      baseUrl: baseUrl ?? this.baseUrl,
      isDetectionEnabled: isDetectionEnabled ?? this.isDetectionEnabled,
      volume: volume ?? this.volume,
      isMuted: isMuted ?? this.isMuted,
      retentionDays: retentionDays ?? this.retentionDays,
    );
  }

  @override
  List<Object?> get props => [
        secondaryNumbers,
        isLoading,
        isAutoDetecting,
        error,
        baseUrl,
        isDetectionEnabled,
        volume,
        isMuted,
        retentionDays,
      ];
}

@injectable
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SecondaryNumberDao _secondaryNumberDao;
  final UserProfileDao _userProfileDao;
  final NetworkConfigService _networkConfig;
  final TtsService _ttsService;
  final SharedPreferences _prefs;

  SettingsBloc(
    this._secondaryNumberDao,
    this._userProfileDao,
    this._networkConfig,
    this._ttsService,
    this._prefs,
  ) : super(const SettingsState()) {
    on<LoadSecondaryNumbers>(_onLoadSecondaryNumbers);
    on<AddSecondaryNumber>(_onAddSecondaryNumber);
    on<DeleteSecondaryNumber>(_onDeleteSecondaryNumber);
    on<LoadBaseUrl>(_onLoadBaseUrl);
    on<UpdateBaseUrl>(_onUpdateBaseUrl);
    on<AutoDetectBaseUrl>(_onAutoDetectBaseUrl);
    on<ToggleDetection>(_onToggleDetection);
    on<UpdateVolume>(_onUpdateVolume);
    on<ToggleMute>(_onToggleMute);
    on<LoadControlSettings>(_onLoadControlSettings);
    on<UpdateRetentionDays>(_onUpdateRetentionDays);
  }

  Future<void> _onUpdateRetentionDays(UpdateRetentionDays event, Emitter<SettingsState> emit) async {
    await _prefs.setInt('history_retention_days', event.days);
    emit(state.copyWith(retentionDays: event.days));
  }

  Future<void> _onLoadControlSettings(LoadControlSettings event, Emitter<SettingsState> emit) async {
    final isEnabled = _prefs.getBool('detection_enabled') ?? true;
    final vol = _prefs.getDouble('notification_volume') ?? 1.0;
    final muted = _prefs.getBool('is_muted') ?? false;
    final retention = _prefs.getInt('history_retention_days') ?? 30;

    await _ttsService.setVolume(vol);
    
    emit(state.copyWith(
      isDetectionEnabled: isEnabled,
      volume: vol,
      isMuted: muted,
      retentionDays: retention,
    ));
  }

  Future<void> _onToggleDetection(ToggleDetection event, Emitter<SettingsState> emit) async {
    await _prefs.setBool('detection_enabled', event.enabled);
    emit(state.copyWith(isDetectionEnabled: event.enabled));
  }

  Future<void> _onUpdateVolume(UpdateVolume event, Emitter<SettingsState> emit) async {
    await _prefs.setDouble('notification_volume', event.volume);
    await _ttsService.setVolume(event.volume);
    emit(state.copyWith(volume: event.volume));
  }

  Future<void> _onToggleMute(ToggleMute event, Emitter<SettingsState> emit) async {
    await _prefs.setBool('is_muted', event.isMuted);
    emit(state.copyWith(isMuted: event.isMuted));
  }

  Future<void> _onLoadBaseUrl(LoadBaseUrl event, Emitter<SettingsState> emit) async {
    final url = await _networkConfig.getBaseUrl();
    emit(state.copyWith(baseUrl: url));
  }

  Future<void> _onUpdateBaseUrl(UpdateBaseUrl event, Emitter<SettingsState> emit) async {
    await _networkConfig.setBaseUrl(event.url);
    emit(state.copyWith(baseUrl: event.url));
  }

  Future<void> _onAutoDetectBaseUrl(AutoDetectBaseUrl event, Emitter<SettingsState> emit) async {
    emit(state.copyWith(isAutoDetecting: true));
    try {
      final url = await _networkConfig.autoDetectBaseUrl();
      await _networkConfig.setBaseUrl(url);
      emit(state.copyWith(isAutoDetecting: false, baseUrl: url));
    } catch (e) {
      emit(state.copyWith(isAutoDetecting: false, error: e.toString()));
    }
  }

  Future<void> _onLoadSecondaryNumbers(LoadSecondaryNumbers event, Emitter<SettingsState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final numbers = await _secondaryNumberDao.getAll();
      emit(state.copyWith(isLoading: false, secondaryNumbers: numbers));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onAddSecondaryNumber(AddSecondaryNumber event, Emitter<SettingsState> emit) async {
    try {
      final dbProfile = await _userProfileDao.getProfile();
      final currentNumbers = await _secondaryNumberDao.getAll();

      // Verificar límites según el plan
      if (dbProfile != null) {
        final profile = UserProfileMapper.fromModel(UserProfileModel.fromDb(dbProfile));
        final isPremium = profile.subscriptionPlan == 'premium';
        final isTrial = !profile.isSubscribed && profile.trialEndDate != null;
        
        // La prueba gratuita funciona como el plan básico (máximo 4 números)
        if ((!isPremium || isTrial) && currentNumbers.length >= 4) {
          emit(state.copyWith(error: 'Límite alcanzado: El Plan Básico y la Prueba Gratuita permiten hasta 4 números. Actualiza a Premium para números ilimitados.'));
          return;
        }
      }

      await _secondaryNumberDao.insertNumber(SecondaryNumbersTableCompanion.insert(
        phoneNumber: event.phoneNumber,
        type: drift.Value(event.type),
      ));
      final numbers = await _secondaryNumberDao.getAll();
      emit(state.copyWith(secondaryNumbers: numbers));
    } catch (e) {
      emit(state.copyWith(error: 'Error al guardar el número: $e'));
    }
  }

  Future<void> _onDeleteSecondaryNumber(DeleteSecondaryNumber event, Emitter<SettingsState> emit) async {
    try {
      await _secondaryNumberDao.deleteNumber(event.id);
      final numbers = await _secondaryNumberDao.getAll();
      emit(state.copyWith(secondaryNumbers: numbers));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}
