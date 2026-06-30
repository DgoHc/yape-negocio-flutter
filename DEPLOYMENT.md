# 🚀 Guía de Despliegue (Release)

## 📦 Generación de APK Release

Para generar el APK listo para producción, ejecuta el siguiente comando:

```bash
flutter build apk --release \
  --obfuscate --split-debug-info=build/app/outputs/symbols \
  --dart-define=ENVIRONMENT=production
```

### Parámetros clave:
- `--release`: Activa optimizaciones de compilación y desactiva logs de debug.
- `--obfuscate`: Oculta nombres de clases y funciones en el código compilado.
- `--dart-define`: Define variables de entorno para apuntar a la URL de producción.

## 📋 Checklist Pre-Release
1.  **Versión**: Incrementar `version` en `pubspec.yaml`.
2.  **Changelog**: Actualizar `CHANGELOG.md` con las nuevas mejoras.
3.  **Tests**: Ejecutar `flutter test` para asegurar que no hay regresiones.
4.  **Permisos**: Verificar que `AndroidManifest.xml` no tenga permisos de desarrollo innecesarios.
5.  **Icono**: Generar iconos con `flutter_launcher_icons` si es necesario.

## 🤖 CI/CD con GitHub Actions
El proyecto incluye un flujo automatizado que:
- Ejecuta `flutter analyze` y `flutter test` en cada Pull Request.
- Genera el APK de release automáticamente al hacer push a `main`.
- Sube el APK como un artefacto descargable en la pestaña "Actions" de GitHub.
