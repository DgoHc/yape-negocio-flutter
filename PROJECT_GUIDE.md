
# Yape Transporte - Proyecto Frontend (Flutter)

## 1. Descripción General
El proyecto Yape Transporte es una aplicación móvil Flutter diseñada para:
- Detectar notificaciones de pagos Yape
- Almacenar pagos localmente con SQLite (Drift)
- Permitir exportar pagos a Excel
- Gestionar dispositivos (aprobar, eliminar)
- Gestionar suscripciones de usuarios
- Funcionar sin conexión a internet (Offline First)
- Sincronizar datos cuando se recupera la conexión

## 2. Arquitectura General - Clean Architecture + Feature First
El proyecto sigue estrictamente los principios de Clean Architecture, organizado por **características (Feature First)** en lugar de por capas.

### 2.1 Estructura de Directorios
```
lib/
├── core/
│   ├── config/
│   │   └── env_config.dart
│   ├── di/
│   │   ├── injection_container.dart
│   │   └── register_module.dart
│   ├── errors/
│   │   └── failures.dart
│   ├── network/
│   │   ├── dio_client.dart
│   │   └── network_config_service.dart
│   ├── services/
│   │   ├── device_info_service.dart
│   │   └── tts_service.dart
│   ├── storage/
│   │   ├── drift/
│   │   │   ├── app_database.dart
│   │   │   └── tables.dart
│   │   └── secure/
│   │       ├── db_encryption_service.dart
│   │       ├── pin_manager.dart
│   │       └── token_manager.dart
│   ├── sync/
│   │   └── background_sync.dart
│   ├── usecases/
│   │   └── usecase.dart
│   ├── utils/
│   │   └── app_logger.dart
│   └── widgets/
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── auth_remote_data_source.dart
│   │   │   │   └── auth_local_data_source.dart
│   │   │   ├── models/
│   │   │   │   └── auth_models.dart
│   │   │   ├── dtos/
│   │   │   │   └── user_profile_dto.dart
│   │   │   ├── mappers/
│   │   │   │   └── user_profile_mapper.dart
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── bloc/
│   │       └── screens/
│   ├── payments/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── payment_remote_data_source.dart
│   │   │   │   └── payment_local_data_source.dart
│   │   │   ├── models/
│   │   │   │   └── payment_models.dart
│   │   │   ├── dtos/
│   │   │   │   └── payment_dto.dart
│   │   │   ├── mappers/
│   │   │   │   └── payment_mapper.dart
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   └── repositories/
│   │   └── presentation/
│   │       ├── bloc/
│   │       └── screens/
│   ├── settings/
│   │   └── ...
│   └── connectivity/
│       └── ...
├── main.dart
└── ARCHITECTURE.md
```

### 2.2 Capas de Clean Architecture (Por Feature)
Cada feature (auth, payments, etc.) se divide en 3 capas principales:

#### 2.2.1 Presentation Layer
- **Responsabilidad**: Mostrar UI y gestionar el estado
- **Contiene**: Blocs, Screens, Widgets
- **Reglas**:
  - NO importa Dio, Drift, SharedPreferences, Flutter Secure Storage
  - NO contiene lógica de negocio
  - SÓLO se comunica con Use Cases
- **Ejemplo**: `AuthBloc` llama a `CheckAuthStatusUseCase`, `StartTrialUseCase`, etc.

#### 2.2.2 Domain Layer
- **Responsabilidad**: Contener la lógica de negocio y las entidades
- **Contiene**: Entities, Repository Interfaces, Use Cases, Failures
- **Reglas**:
  - COMPLETAMENTE independiente (NO importa Flutter ni ninguna librería externa)
  - NO tiene acceso a la capa de datos ni a la de presentación
- **Ejemplo**:
  - Entidades: `UserProfile`, `AuthStatusResult`, `PaymentData`
  - Use Cases: `CheckAuthStatusUseCase`, `LogoutUseCase`

#### 2.2.3 Data Layer
- **Responsabilidad**: Implementar las operaciones de acceso a datos (API, SQLite, etc.)
- **Contiene**: RemoteDataSource, LocalDataSource, Models, DTOs, Mappers, Repository Implementations
- **Reglas**:
  - Implementa las interfaces de la capa Domain
  - Todo acceso a API pasa por `RemoteDataSource`
  - Todo acceso a almacenamiento local pasa por `LocalDataSource`
- **Ejemplo**:
  - `AuthLocalDataSource` (usa Drift)
  - `AuthRemoteDataSource` (usa Dio)
  - `UserProfileRepositoryImpl` (usa los Data Sources y Mappers)

### 2.3 Inyección de Dependencias (DI)
- **Librerías**: `get_it` + `injectable`
- **Archivos clave**:
  - `lib/core/di/injection_container.dart`: Archivo inicial
  - `lib/core/di/register_module.dart`: Registra dependencias específicas
  - `lib/core/di/injection_container.config.dart`: **Generado automáticamente** con build_runner

#### 2.3.1 Regenerar código de Injectable
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## 3. Core Modules (Módulos Principales)
### 3.1 AppLogger
- **Archivo**: `lib/core/utils/app_logger.dart`
- **Uso**: Para logging en lugar de `print`
- **Ejemplos**:
  ```dart
  AppLogger.d('Mensaje de debug');
  AppLogger.i('Mensaje de información');
  AppLogger.w('Mensaje de advertencia');
  AppLogger.e('Mensaje de error', exception, stackTrace);
  ```

### 3.2 DeviceInfoService
- **Archivo**: `lib/core/services/device_info_service.dart`
- **Responsabilidad**: Encapsular el uso de `device_info_plus` y `Platform` para no exponerlos a capas superiores
- **Uso**:
  ```dart
  final deviceInfoService = sl<DeviceInfoService>();
  final uuid = await deviceInfoService.getDeviceUUID();
  ```

### 3.3 NetworkConfigService
- **Archivo**: `lib/core/network/network_config_service.dart`
- **Responsabilidad**: Gestionar la configuración de la URL base
- **Uso**:
  ```dart
  final networkConfig = sl<NetworkConfigService>();
  await networkConfig.setBaseUrl('http://localhost:3000');
  final url = await networkConfig.getBaseUrl();
  ```

### 3.4 BackgroundSync
- **Archivo**: `lib/core/sync/background_sync.dart`
- **Responsabilidad**: Gestionar la sincronización en segundo plano con `workmanager`

### 3.5 Failures
- **Archivo**: `lib/core/errors/failures.dart`
- **Responsabilidad**: Tipar los errores que pueden ocurrir
- **Tipos**:
  - `Failure`: Clase abstracta
  - `ServerFailure`: Error de servidor (API)
  - `DatabaseFailure`: Error de base de datos (Drift)
  - `CacheFailure`: Error de caché

## 4. Feature: Auth
### 4.1 Entidades Domain
#### UserProfile (`lib/features/auth/domain/entities/user_profile.dart`)
Representa el perfil de un usuario
```dart
final String? id;
final String name;
final String? email;
final String? phone;
final String? uuid;
final DateTime? trialStartDate;
final DateTime? trialEndDate;
final DateTime? subscriptionStartDate;
final DateTime? subscriptionEndDate;
final bool isSubscribed;
final DateTime createdAt;
```
- Métodos de utilidad: `hasAccess`, `isTrialActive`, `createTrial`, `createSubscription`, `copyWith`

#### AuthStatusResult (`lib/features/auth/domain/entities/auth_status_result.dart`)
Resultado del uso caso `CheckAuthStatus`
```dart
enum ResultStatus {
  initial,
  authenticatedAdmin,
  authenticatedDriver,
  unauthenticated,
  needsPairing,
  needsSubscription,
  noAccess,
}

final ResultStatus status;
final String? userRole;
final String? deviceId;
final UserProfile? userProfile;
final String? error;
```

### 4.2 Use Cases (Capa Domain)
Todos los casos de uso implementan la clase abstracta `UseCase`
- `GetDeviceIdUseCase`: Obtener UUID del dispositivo
- `CheckAuthStatusUseCase`: Verificar el estado de autenticación
- `ApproveDeviceUseCase`: Aprobar un dispositivo
- `LogoutUseCase`: Cerrar sesión
- `StartTrialUseCase`: Iniciar período de prueba
- `ActivateSubscriptionUseCase`: Activar suscripción
- `LoginAdminUseCase`: Iniciar sesión como admin
- `RegisterUserUseCase`: Registrar un usuario
- `LoginUserUseCase`: Iniciar sesión como usuario
- `RegisterDeviceUseCase`: Registrar un dispositivo

### 4.3 Data Layer
#### Models y DTOs
- `UserProfileModel`: Para almacenamiento en Drift (`lib/features/auth/data/models/auth_models.dart`)
- `UserProfileDto`: Para comunicación con la API (`lib/features/auth/data/dtos/user_profile_dto.dart`)
- `UserProfileMapper`: Convierte entre Entity ↔ Model ↔ Dto

#### Remote Data Source
- **Archivo**: `lib/features/auth/data/datasources/auth_remote_data_source.dart`
- **Responsabilidad**: Todas las llamadas a la API del backend
- **Métodos**:
  - `loginAdmin(String username, String pin)`
  - `loginUser(String email, String password)`
  - `registerUser(String name, String email, String password, String? phone, String? uuid)`
  - `registerDevice(String uuid)`
  - `checkDeviceStatus(String uuid)`
  - `approveDevice(String uuid, String? alias)`
  - `unapproveDevice(String uuid)`
  - `createDeviceIfNotExists(String uuid, String alias)`

#### Local Data Source
- **Archivo**: `lib/features/auth/data/datasources/auth_local_data_source.dart`
- **Responsabilidad**: Todas las operaciones con la base de datos local (Drift)
- **Métodos**:
  - `getProfile()`, `saveProfile(UserProfileModel profile)`, `deleteProfile()`
  - `findProfileByEmail(String email)`
  - `getDeviceByUuid(String uuid)`, `upsertDevice(String uuid, String alias, bool isApproved)`

## 5. Feature: Payments
### 5.1 Domain
- **Entity**: `PaymentData` (`lib/features/notifications/domain/entities/payment_data.dart`)
- **Repository Interface**: `PaymentRepository` (`lib/features/payments/domain/repositories/payment_repository.dart`)
- **Parser**: `PaymentParser` (`lib/features/notifications/domain/parsers/payment_parser.dart`) - parsea notificaciones Yape

### 5.2 Data Layer
- **Models**: `PaymentModel` (`lib/features/payments/data/models/payment_models.dart`)
- **DTOs**: `PaymentDto` (`lib/features/payments/data/dtos/payment_dto.dart`)
- **Mappers**: `PaymentMapper` (`lib/features/payments/data/mappers/payment_mapper.dart`)
- **Remote Data Source**: `PaymentRemoteDataSource` (`lib/features/payments/data/remote_data_source/payment_remote_data_source.dart`)
- **Local Data Source**: `PaymentLocalDataSource` (`lib/features/payments/data/local_data_source/payment_local_data_source.dart`)
- **Repository Impl**: `PaymentRepositoryImpl` (`lib/features/payments/data/repositories/payment_repository_impl.dart`)

### 5.3 Flujo de un nuevo pago
1. El servicio nativo (`NotificationPlatformService`) escucha notificaciones Yape
2. `PaymentRepository` recibe la notificación
3. `PaymentParser` parsea el contenido (nombre remitente, monto, moneda)
4. Si el parseo es exitoso:
   a. Se convierte a `PaymentModel` y se guarda localmente con `PaymentLocalDataSource`
   b. Se envía al backend a través de `PaymentRemoteDataSource` (si hay conexión a internet)
   c. Si no hay conexión, se agrega a la cola de sincronización (`SyncQueue`)
   d. Se reproduce audio con `TtsService` ("[nombre] envió [monto] soles")
5. `PaymentsBloc` escucha el evento de nuevo pago y actualiza el estado y la UI

## 6. Comunicación con el Backend
### 6.1 Arquitectura de Desacoplamiento
El frontend está **completamente desacoplado del backend**:
- Todo acceso a API pasa por `RemoteDataSource`
- Todo acceso a DB local pasa por `LocalDataSource`
- Las capas Presentation y Domain **NO importan Dio**
- Si el backend cambia completamente (ej. NestJS → Laravel → Go), solo hay que modificar:
  - Remote Data Source
  - Models/DTOs
  - Mappers

### 6.2 Dio Client
- **Archivo**: `lib/core/network/dio_client.dart`
- **Configuración**: `baseUrl` se lee de `EnvConfig.baseUrl` o de `NetworkConfigService`
- **Interceptores**: Agrega headers de autenticación, logging, etc.

### 6.3 API Endpoints (Ejemplo)
- `POST /auth/admin/login`: Inicio de sesión admin
- `POST /auth/register`: Registro de usuario
- `POST /auth/login`: Inicio de sesión usuario
- `POST /devices`: Registro de dispositivo
- `GET /devices/:uuid/status`: Estado del dispositivo
- `POST /devices/:uuid/approve`: Aprobar dispositivo
- `POST /devices/:uuid/unapprove`: Desaprobar dispositivo
- `POST /payments`: Envío de pago al servidor
- `GET /payments`: Obtener pagos

## 7. Offline First Strategy
1. **Almacenamiento local primero**: Todo dato nuevo se guarda primero en la base de datos local
2. **Sincronización en segundo plano**: `BackgroundSync` programa tareas para sincronizar cuando hay conexión
3. **Cola de sincronización**: Si no hay conexión, los datos se guardan en `SyncQueueTable` para sincronizar más tarde

## 8. Implementar una Nueva Feature
### Paso 1: Crear la estructura de directorios
```
lib/features/nueva_feature/
├── data/
│   ├── datasources/
│   │   ├── nueva_feature_remote_data_source.dart
│   │   └── nueva_feature_local_data_source.dart
│   ├── models/
│   │   └── nueva_feature_models.dart
│   ├── dtos/
│   │   └── nueva_feature_dto.dart
│   ├── mappers/
│   │   └── nueva_feature_mapper.dart
│   └── repositories/
│       └── nueva_feature_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── nueva_feature_entity.dart
│   ├── repositories/
│   │   └── nueva_feature_repository.dart
│   └── usecases/
│       └── nueva_feature_usecase.dart
└── presentation/
    ├── bloc/
    │   └── nueva_feature_bloc.dart
    ├── screens/
    │   └── nueva_feature_screen.dart
    └── widgets/
        └── nueva_feature_widget.dart
```

### Paso 2: Implementar la capa Domain
1. Crea las `Entities` (solo data, sin lógica de UI/API/DB)
2. Crea las `Use Cases` (lógica de negocio)
3. Crea las `Repository Interfaces` (abstractas, para desacoplamiento)

### Paso 3: Implementar la capa Data
1. Crea `Models` (para almacenamiento local)
2. Crea `DTOs` (para comunicación con API)
3. Crea `Mappers` (convierte Entity ↔ Model ↔ DTO)
4. Implementa `RemoteDataSource` y `LocalDataSource`
5. Implementa el `RepositoryImpl` que usa los data sources

### Paso 4: Implementar la capa Presentation
1. Crea el `Bloc` que usa los `Use Cases`
2. Crea los `Screens` y `Widgets`
3. Usa `BlocProvider` para proveer el bloc

### Paso 5: Registrar dependencias en Injectable
- Añade `@lazySingleton` o `@singleton` a tus clases
- Añade nuevos módulos a `RegisterModule`
- Regenera el código con build_runner

## 9. Generar Código
- **Build Runner**:
  ```bash
  flutter pub run build_runner build --delete-conflicting-outputs
  ```
  Se usa para generar código de:
  - Drift
  - Injectable

## 10. Despliegue

### 10.1 Desplegar Backend (Yape Transporte Backend)
1. **Configurar variables de entorno**:
   Asegúrate de configurar un archivo `.env` en la raíz del backend con tus credenciales (ej. `DATABASE_URL`, `JWT_SECRET`, `PORT`, etc.)
2. **Instalar dependencias**:
   ```bash
   cd yape_transporte_backend
   npm install
   # O si usas yarn
   yarn install
   ```
3. **Ejecutar Prisma migrations**:
   ```bash
   npx prisma migrate deploy
   ```
4. **Iniciar el servidor**:
   - En modo desarrollo:
     ```bash
     npm run dev
     # O yarn dev
     ```
   - En modo producción (con Node.js):
     ```bash
     npm run build
     npm start
     ```
5. **Despliegue en la nube (ej. Vercel, Render, Heroku, Railway)**:
   - Sube tu código a un repositorio Git (GitHub, GitLab, etc.)
   - Conecta tu cuenta a la plataforma de despliegue (ej. Render, Railway)
   - Configura las variables de entorno en la plataforma
   - Elige el comando de inicio (ej. `npm start` o el que uses)
   - Espera a que se complete el despliegue y obtén la URL pública de tu backend
   - Actualiza `EnvConfig.baseUrl` en el frontend Flutter si es necesario

### 10.2 Publicar la aplicación Flutter en Google Play Store
1. **Preparar la aplicación para publicación**:
   - Asegúrate de que el `pubspec.yaml` tenga un `versionName` y `versionCode` correctos (ej. `version: 1.0.0+1`)
   - Genera un keystore para firmar la aplicación:
     ```bash
     keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
     ```
   - Guarda el archivo `upload-keystore.jks` en un lugar seguro (NO lo subas al repositorio)
   - Crea un archivo `key.properties` en `android/` con la información del keystore:
     ```properties
     storePassword=tu_contraseña
     keyPassword=tu_contraseña
     keyAlias=upload
     storeFile=upload-keystore.jks
     ```
   - Configura `android/app/build.gradle` para firmar la aplicación:
     ```gradle
     def keystoreProperties = new Properties()
     def keystorePropertiesFile = rootProject.file('key.properties')
     if (keystorePropertiesFile.exists()) {
         keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
     }
     android {
         ...
         signingConfigs {
             release {
                 keyAlias keystoreProperties['keyAlias']
                 keyPassword keystoreProperties['keyPassword']
                 storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
                 storePassword keystoreProperties['storePassword']
             }
         }
         buildTypes {
             release {
                 signingConfig signingConfigs.release
                 ...
             }
         }
     }
     ```
2. **Compilar el APK o App Bundle**:
   - App Bundle (recomendado para Play Store):
     ```bash
     flutter build appbundle
     ```
     El archivo estará en: `build/app/outputs/bundle/release/app-release.aab`
   - APK (si prefieres):
     ```bash
     flutter build apk --release
     ```
     El archivo estará en: `build/app/outputs/flutter-apk/app-release.apk`
3. **Crear cuenta en Google Play Console**:
   - Ve a [Google Play Console](https://play.google.com/console/)
   - Inicia sesión con tu cuenta de Google
   - Si no tienes una cuenta de desarrollador, paga la tarifa de registro (una vez)
4. **Crear una nueva aplicación**:
   - Haz clic en "Crear app"
   - Rellena la información básica (nombre, idioma, categoría, etc.)
5. **Configurar la tienda**:
   - Sube capturas de pantalla, íconos, descripción de la aplicación, etc., en la sección "Listado de la tienda"
6. **Subir el App Bundle o APK**:
   - Ve a la sección "Producción" → "Crear una nueva versión"
   - Sube tu archivo `app-release.aab` o `app-release.apk`
   - Rellena la información de la versión (notas de la versión, etc.)
7. **Revisar y publicar**:
   - Revisa que toda la información sea correcta
   - Haz clic en "Comenzar lanzamiento a producción" (o a un canal de prueba primero, si prefieres)
   - Espera la revisión de Google (generalmente de unas horas a 1-2 días)
8. **¡Tu aplicación está en Google Play Store!**

## 11. Changelog de Refactorización
### Versión 2.0 (Clean Architecture Refactor)
1. **Auth Feature**:
   - Separación completa en Capas Presentation/Domain/Data
   - Creación de `DeviceInfoService` para encapsular device info
   - Creación de `Use Cases` para toda la lógica de auth
   - `AuthBloc` ahora SOLO usa casos de uso
   - Implementación de `RemoteDataSource`, `LocalDataSource`, `Mappers`, `Models`, `DTOs`
2. **Payments Feature**:
   - Creación de `PaymentRemoteDataSource`, `PaymentLocalDataSource`, `PaymentModels`, `PaymentDto`, `PaymentMapper`
   - Actualización de `PaymentRepositoryImpl` para usar los data sources y mappers
3. **Core**:
   - Eliminación de imports innecesarios
   - Remplazo de todos los `print` por `AppLogger`
   - `NetworkConfigService` simplificado sin `network_info_plus`
   - Añadidas dependencias `path` y `crypto` al pubspec
   - Eliminado `CacheService` y `hive_ce` (no usados)
4. **Data Layer**:
   - `AuthRepositoryImpl`, `UserAuthRepositoryImpl`, `UserProfileRepositoryImpl` refactorizados para usar DataSources y Mappers
5. **Fixes**:
   - Arreglado `UserProfile` (ID es String? en lugar de int)
   - Eliminados campos `rubro` y `password` de entidades
   - Arreglado flutter analyze sin errores

## 12. Mejoras Pendientes
- Refactorizar Feature Settings a arquitectura Clean completa
- Añadir pruebas unitarias y de integración
- Añadir comentarios en código clave
- Mejorar la gestión de errores
