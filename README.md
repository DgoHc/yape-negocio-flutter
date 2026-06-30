
# Yape Transporte - Sistema de Detección de Pagos

## Descripción
Aplicación Flutter para detectar pagos de Yape mediante notificaciones, con sistema de suscripción, sincronización con backend y exportación de reportes Excel.

## Arquitectura
- **Clean Architecture**: Separation of concerns entre Data → Domain → Presentation
- **State Management**: flutter_bloc
- **Dependency Injection**: get_it + injectable
- **Local Storage**: Drift (SQLite) + flutter_secure_storage
- **Navigation**: go_router
- **Networking**: Dio con interceptores JWT

## Funcionalidades Principales
1. **Detección de Notificaciones Yape**: Escucha notificaciones del sistema para capturar pagos entrantes.
2. **Registro de Pagos**: Almacena pagos localmente y sincroniza con el backend.
3. **Exportación a Excel**: Genera reportes en formato Excel con filtros de fecha.
4. **Sistema de Suscripción**: Prueba gratuita de 14 días y suscripción mensual.
5. **Pasarelas de Pago**: Integración con Culqi, Mercado Pago y Yape.
6. **Auto-aprobación de Dispositivos**: Si el usuario tiene prueba o suscripción activa, no necesita aprobación del admin.
7. **Notificaciones TTS (Text-to-Speech)**: Lee los pagos entrantes en voz alta.
8. **Sincronización Offline-First**: Funciona sin conexión y sincroniza cuando hay internet.

## Configuración

### Requisitos Previos
- Flutter 3.24+
- Dart 3.5+
- Android SDK 21+ / iOS 13+

### 1. Instalar Dependencias
```bash
flutter pub get
```

### 2. Generar Código (Injectable, Drift)
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Configurar Variables de Entorno
Crea un archivo `.env` en la raíz del proyecto (usa `.env.example` como plantilla):
```env
ENV=dev
BASE_URL=https://api.tudominio.com/v1
API_KEY=tu_api_key_aqui

# Pasarelas de Pago
CULQI_PUBLIC_KEY=pk_test_culqi_public_key
CULQI_SECRET_KEY=sk_test_culqi_secret_key
MERCADO_PAGO_PUBLIC_KEY=TEST-1234567890abcdef
MERCADO_PAGO_ACCESS_TOKEN=TEST-1234567890abcdef
```

### 4. Backend Integration
La app requiere un backend para manejar pagos seguros (nunca confíes en la validación del cliente). Los endpoints necesarios son:

#### Endpoints de Pago
Todos deben estar autenticados con JWT (token en el header `Authorization: Bearer <token>`).

##### POST `/payments/culqi`
- **Descripción**: Crea un pago en Culqi y devuelve la URL del checkout.
- **Body**:
  ```json
  {
    "amount": 500,
    "currency": "PEN",
    "description": "Suscripción mensual Yape Transporte"
  }
  ```
- **Respuesta**:
  ```json
  {
    "id": "pay_123abc",
    "payment_url": "https://checkout.culqi.com/pay/pay_123abc"
  }
  ```

##### POST `/payments/mercadopago`
- **Descripción**: Crea una preferencia de pago en Mercado Pago.
- **Body**:
  ```json
  {
    "amount": 5.0,
    "currency": "PEN",
    "description": "Suscripción mensual Yape Transporte"
  }
  ```
- **Respuesta**:
  ```json
  {
    "id": "123456789",
    "init_point": "https://www.mercadopago.com.ar/checkout/v1/redirect?pref_id=..."
  }
  ```

##### POST `/payments/yape`
- **Descripción**: Crea un pago con Yape (integración a través de tu proveedor).
- **Body**:
  ```json
  {
    "amount": 5.0,
    "currency": "PEN",
    "description": "Suscripción mensual Yape Transporte"
  }
  ```
- **Respuesta**:
  ```json
  {
    "id": "yape_123abc",
    "payment_url": "https://yape.pe/pay/yape_123abc"
  }
  ```

#### Webhooks
Configura webhooks en Culqi/Mercado Pago/Yape para notificar a tu backend cuando un pago se complete exitosa o fallidamente. Tu backend debe:
1. Validar la firma del webhook (¡importante para seguridad!).
2. Marcar la suscripción del usuario como activa.
3. (Opcional) Enviar una notificación push a la app.

## Build de Producción

### Android
```bash
flutter build apk --release --obfuscate --split-debug-info=./debug-info
```

### iOS
```bash
flutter build ios --release
```

## Seguridad
- **JWT**: Autenticación segura con tokens.
- **Token Manager**: Almacenamiento seguro de tokens con `flutter_secure_storage`.
- **Pagos Seguros**: Todos los pagos se procesan en el backend (nunca en el cliente).
- **SSL/TLS**: Usa HTTPS en producción.

## Estructura del Proyecto
```
lib/
├── core/                # Configuración central, utilidades, DI, etc.
│   ├── config/
│   ├── di/
│   ├── errors/
│   ├── network/
│   ├── storage/
│   ├── theme/
│   ├── utils/
│   └── widgets/
├── features/            # Feature modules
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── dashboard/
│   ├── notifications/
│   ├── payments/
│   └── settings/
└── main.dart
```

## Mejoras Futuras
- [ ] Notificaciones push cuando se completa un pago.
- [ ] Soporte para múltiples dispositivos por usuario.
- [ ] Reportes gráficos (ingresos mensuales, etc.).
- [ ] Integración con más pasarelas de pago (Niubiz, Izipay, etc.).
