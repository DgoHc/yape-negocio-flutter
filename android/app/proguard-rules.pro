# Flutter & Deferred Components
-keep class io.flutter.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.app.** { *; }
-dontwarn io.flutter.embedding.engine.deferredcomponents.**
-dontwarn com.google.android.play.core.**

# Google Services & Auth
-keep class com.google.android.gms.** { *; }
-keep class com.google.firebase.** { *; }
-dontwarn com.google.android.gms.**
-dontwarn com.google.firebase.**

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
