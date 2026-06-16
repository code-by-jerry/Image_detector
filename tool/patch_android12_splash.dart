import 'dart:io';

/// Android 12+ defaults to the app launcher icon when no splash icon is set.
/// Use a blank cream icon + full-screen launch_background underneath.
void main() {
  const launchTheme = '''<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="LaunchTheme" parent="@android:style/Theme.Light.NoTitleBar">
        <item name="android:windowBackground">@drawable/launch_background</item>
        <item name="android:windowSplashScreenBackground">#FAF8F2</item>
        <item name="android:windowSplashScreenAnimatedIcon">@drawable/android12splash</item>
        <item name="android:windowSplashScreenIconBackgroundColor">#FAF8F2</item>
        <item name="android:forceDarkAllowed">false</item>
        <item name="android:windowFullscreen">false</item>
        <item name="android:windowDrawsSystemBarBackgrounds">false</item>
        <item name="android:windowLayoutInDisplayCutoutMode">shortEdges</item>
    </style>
    <style name="NormalTheme" parent="@android:style/Theme.Light.NoTitleBar">
        <item name="android:windowBackground">?android:colorBackground</item>
    </style>
</resources>
''';

  for (final path in [
    'android/app/src/main/res/values-v31/styles.xml',
    'android/app/src/main/res/values-night-v31/styles.xml',
  ]) {
    File(path).writeAsStringSync(launchTheme);
    stdout.writeln('Patched $path');
  }
}
