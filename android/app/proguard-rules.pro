# ProGuard rules for PantryPro release build.
#
# Flutter's R8 integration handles most shrinking automatically.
# These rules prevent stripping classes that are accessed via reflection
# (Drift generated code, Supabase JSON models).

# Drift / SQLite generated classes
-keep class com.pantrypro.** { *; }

# Keep Dart/Flutter reflection hooks (flutter_embedding)
-keep class io.flutter.** { *; }
-keep class io.flutter.plugin.** { *; }

# Supabase / Ktor / OkHttp — keep annotations used for serialisation
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions

# Keep all Kotlin Serialization classes
-keepclassmembers class kotlinx.serialization.** { *; }

# OkHttp platform checks (used internally by Supabase)
-dontwarn okhttp3.internal.platform.**
-dontwarn org.conscrypt.**
-dontwarn org.bouncycastle.**
-dontwarn org.openjsse.**
