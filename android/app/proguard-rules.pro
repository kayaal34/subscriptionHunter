# Release builds run R8 with shrinking enabled. These keeps are the minimum
# required to stop it stripping code the plugins reach reflectively.

# flutter_local_notifications serialises scheduled notifications to disk with
# Gson. R8 strips the model classes' generic signatures otherwise, and every
# scheduled reminder silently fails to restore after a reboot.
-keep class com.dexterous.** { *; }
-keepattributes Signature
-keepattributes *Annotation*

# Gson internals
-dontwarn sun.misc.**
-keepclassmembers,allowobfuscation class * {
  @com.google.gson.annotations.SerializedName <fields>;
}

# sqlite3_flutter_libs loads the bundled native library through JNI.
-keep class org.sqlite.** { *; }

# Flutter deferred components / Play Core are referenced by the embedding but
# are not bundled in a plain APK build.
-dontwarn io.flutter.embedding.engine.deferredcomponents.**
-dontwarn com.google.android.play.core.**
