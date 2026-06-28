# ── Flutter ──────────────────────────────────────────────────────────
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# ── Firebase Crashlytics ────────────────────────────────────────────
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception

# ── Google Mobile Ads (AdMob) ───────────────────────────────────────
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.ads.** { *; }

# ── Google Play Billing (In-App Purchases) ──────────────────────────
-keep class com.android.vending.billing.** { *; }

# ── Firebase ────────────────────────────────────────────────────────
-keep class com.google.firebase.** { *; }

# ── Prevent stripping of annotations ────────────────────────────────
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses

# ── Google Play Core (Fixes R8 missing class errors) ───────────────
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }
