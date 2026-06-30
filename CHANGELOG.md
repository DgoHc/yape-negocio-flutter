# CHANGELOG

Todas las modificaciones notables de este proyecto se documentarán en este archivo.

El formato se basa en [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
y este proyecto se adhiere a [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-06-09

### Añadido
- Nueva lógica de persistencia para el servicio de notificaciones (Rebind automático).
- Soporte para versiones modernas de Yape (`com.bcp.innovacxion.yapeapp`).
- Pantalla de historial de pagos completo con modal deslizable.
- Funcionalidad para eliminar pagos individuales del historial local.
- Botón para solicitar omisión de optimización de batería en Android.

### Mejoras
- Refactorización del parser de Yape para manejar nombres con asteriscos de privacidad.
- Limpieza de nombres en la voz de TTS (ya no se leen los asteriscos).
- Optimización de la comunicación nativa -> Flutter mediante el hilo principal de UI.
- Filtro de notificaciones mejorado para ignorar eventos del sistema (como el cargador).

### Corregido
- Error `MissingForegroundServiceTypeException` en Android 14+.
- Problema de sincronización donde el monitor de debug bloqueaba el procesamiento de pagos.
- Error de compilación por falta de imports de `Handler` y `Looper`.

## [1.0.0] - 2026-05-01
- Lanzamiento inicial del proyecto Yape Transporte.
- Detección básica de notificaciones de Yape.
- Integración con TTS para lectura de montos.
- Persistencia local con Drift (SQLite).
