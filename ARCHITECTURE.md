# 🏛️ Arquitectura del Sistema

## 🏗️ Clean Architecture + Feature-Based
El proyecto sigue los principios de **SOLID** y **Clean Architecture**, dividiendo el código en capas para facilitar el mantenimiento y escalabilidad.

### Capas:
1.  **Domain (Capa de Negocio)**: Contiene Entidades y Use Cases. Es pura lógica de negocio, independiente de cualquier framework.
2.  **Data (Capa de Datos)**: Implementa los Repositorios y gestiona las fuentes de datos (Drift SQLite, API REST, SharedPreferences).
3.  **Presentation (Capa de Interfaz)**: Utiliza **flutter_bloc** para la gestión de estados y widgets reactivos.

## 🌉 El Puente Nativo (Native Bridge)
La funcionalidad más crítica es la escucha de notificaciones de Yape.

- **Kotlin Service**: `YapeNotificationListenerService` hereda de `NotificationListenerService`. Captura eventos del sistema Android.
- **EventChannel**: Túnel de comunicación bidireccional que envía los datos crudos desde Kotlin hacia Dart en tiempo real.
- **Persistence Layer**: Uso de `requestRebind()` para asegurar que el servicio se mantenga vivo.

## 🧩 Decisiones Clave
- **Drift (SQLite)**: Elegido por su soporte de streams reactivos y generación de código tipado.
- **Injectable/GetIt**: Para la inversión de dependencias, permitiendo cambiar implementaciones fácilmente (ej: mocks para tests).
- **GoRouter**: Gestión de navegación declarativa y robusta.
