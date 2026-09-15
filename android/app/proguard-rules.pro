# Conservar todo lo relacionado con Google Play Services y Auth
-keep class com.google.android.gms.** { *; }
-keep class com.google.firebase.** { *; }
-keep class com.novabytex.aplicativo.** { *; }

# Mantener protocolos de red
-keep class okhttp3.** { *; }
-keep class retrofit2.** { *; }
-keep class com.dio.** { *; }

# Evitar errores de des-serialización de JSON
-keepattributes Signature,AnnotationDefault,EnclosingMethod,InnerClasses
-keep public class * extends com.novabytex.aplicativo.features.auth.data.dtos.** { *; }
