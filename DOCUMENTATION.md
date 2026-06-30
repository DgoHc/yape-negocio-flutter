# 🚌 Yape Transporte - Guía Maestra del Proyecto

Bienvenido a la documentación oficial de **Yape Transporte**. Este proyecto es una solución integral para la gestión de pagos automáticos en transporte público, integrando Android Nativo, Flutter y un Backend robusto en Node.js.

---

## 🚀 1. Visión General
Yape Transporte detecta automáticamente pagos de la app Yape, los procesa, los reproduce por voz (TTS) para el conductor y los sincroniza con un servidor central para auditoría y gestión administrativa.

### Características Principales
- **Detección en Tiempo Real**: Escucha notificaciones nativas de Android.
- **Offline-First**: Funciona sin internet y sincroniza cuando hay conexión.
- **Multi-Rol**: SuperAdmin, Admin, Supervisor y Driver.
- **Seguridad**: JWT, Hashing de PIN y cifrado local.

---

## 🛠️ 2. Arquitectura Técnica

### Frontend (Flutter)
- **Patrón**: Clean Architecture + Feature-Based.
- **Estado**: `flutter_bloc`.
- **Persistencia**: 
  - `Drift` (SQLite) para historial y colas.
  - `Hive` para caché rápido.
  - `Secure Storage` para tokens y PINs.

### Backend (Node.js)
- **Framework**: Express + TypeScript.
- **ORM**: Prisma con MySQL.
- **Seguridad**: RBAC (Control de acceso basado en roles).

---

## 🔌 3. El Corazón del Sistema (Código Clave)

### A. Detección Nativa (Kotlin)
El servicio `YapeNotificationListenerService` intercepta las notificaciones de Yape y las envía a Flutter.

```kotlin
// android/app/src/main/kotlin/.../YapeNotificationListenerService.kt
override fun onNotificationPosted(sbn: StatusBarNotification?) {
    if (sbn?.packageName == "pe.com.interbank.yape") {
        val extras = sbn.notification.extras
        val data = mapOf(
            "rawTitle" to extras.getString("android.title", ""),
            "rawBody" to extras.getString("android.text", "")
        )
        eventSink?.success(data) // Envío a Flutter
    }
}
```

### B. El Parser de Pagos (Dart)
Convierte el texto de la notificación en datos estructurados.

```dart
// lib/features/notifications/domain/parsers/payment_parser.dart
static Either<Failure, PaymentData> parse(String text) {
  final regex = RegExp(r'(.+?)\s+te envió un pago por\s+(S/|PEN)\s*(\d+\.\d+)');
  final match = regex.firstMatch(text);
  if (match != null) {
    return Right(PaymentData(
      senderName: match.group(1)!,
      amount: double.parse(match.group(3)!),
      currency: match.group(2)!,
    ));
  }
  return Left(Failure('Formato no reconocido'));
}
```

### C. Sincronización Inteligente
Garantiza que ningún pago se pierda mediante una cola de sincronización.

```dart
// lib/core/sync/sync_engine.dart
Future<void> processQueue() async {
  final pending = await _db.syncQueueDao.getPending();
  for (var task in pending) {
    final result = await _api.post(task.endpoint, data: task.payload);
    if (result.isSuccess) await _db.syncQueueDao.markAsDone(task.id);
  }
}
```

---

## 👥 4. Gestión de Roles

| Rol | Capacidades |
| :--- | :--- |
| **SuperAdmin** | Gestión total de usuarios (Admins/Supervisores) y conductores. |
| **Admin** | Aprobación y suspensión de conductores (UUIDs). |
| **Supervisor** | Visualización de pagos y estados en tiempo real. |
| **Driver** | Dashboard de pagos, TTS y configuración de voz. |

---

## 📍 5. ¿Cómo encontrar mi UUID? (Para Conductores)
Si eres un conductor y necesitas que el administrador apruebe tu dispositivo, sigue estos pasos:
1. Abre la aplicación **Yape Transporte**.
2. Si tu dispositivo no está vinculado, verás la pantalla de **"Dispositivo no vinculado"**.
3. En el centro de la pantalla verás una sección que dice **"UUID DE TU DISPOSITIVO"**.
4. Puedes **mantener presionado** sobre el código para copiarlo y enviárselo a tu administrador por WhatsApp o mensaje.
5. Una vez que el administrador te confirme la aprobación, presiona el botón **"Verificar Estado"**.

---

## 📝 6. Guía para Desarrolladores

### ¿Cómo agregar una nueva funcionalidad?
1. **Modelo**: Define la tabla en `schema.prisma` (Backend) y `tables.dart` (Frontend).
2. **Data**: Crea el Data Source y el Repositorio.
3. **Domain**: Crea el UseCase.
4. **Presentation**: Implementa el BLoC y la pantalla.
5. **Inyección**: Ejecuta `dart run build_runner build`.

### Ejemplo: Agregar "Alertas de Mantenimiento"
```dart
// 1. Repositorio
abstract class MaintenanceRepository {
  Future<Either<Failure, void>> notifyIssue(String description);
}

// 2. Uso en BLoC
void _onNotify(NotifyEvent event, Emitter<State> emit) async {
  await _repository.notifyIssue(event.desc);
}
```

---

## 🏁 6. Instalación Rápida

1. **Backend**:
   ```bash
   cd yape_transporte_backend
   npm install
   npx prisma migrate dev
   npm run dev
   ```

2. **Frontend**:
   ```bash
   flutter pub get
   dart run build_runner build --delete-conflicting-outputs
   flutter run
   ```

---
*Desarrollado con ❤️ para la eficiencia en el transporte.*
