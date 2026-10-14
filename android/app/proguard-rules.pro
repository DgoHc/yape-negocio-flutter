# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.app.** { *; }

# Google Services & Auth
-keep class com.google.android.gms.** { *; }
-keep class com.google.firebase.** { *; }

# Services & Receivers
-keep class com.novabytex.aplicativo.YapeNotificationListenerService { *; }
-keep class com.novabytex.aplicativo.BootReceiver { *; }
-keep class com.novabytex.aplicativo.MainActivity { *; }

# Network & DB
-keep class okhttp3.** { *; }
-keep class retrofit2.** { *; }
-keep class com.dio.** { *; }

# Attributes
-keepattributes Signature,AnnotationDefault,EnclosingMethod,InnerClasses,*Annotation*
