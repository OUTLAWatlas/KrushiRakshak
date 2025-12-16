# Keep TFLite classes
-keep class org.tensorflow.lite.** { *; }
-keep class com.tflite_flutter.** { *; }

# Keep ML Kit classes
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.** { *; }

# Prevent warning spam
-dontwarn org.tensorflow.lite.**
-dontwarn com.google.mlkit.**
