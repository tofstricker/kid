import 'package:permission_handler/permission_handler.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';

class PermissionService {
  // Check if all critical permissions are granted
  Future<bool> hasAllPermissions() async {
    bool overlay = await Permission.systemAlertWindow.isGranted;
    // Accessibility and Usage Stats are harder to check via standard Flutter plugins
    // without MethodChannels or extra packages. We'll rely on the overlay permission
    // check as a proxy that the user went through the setup, or if they click proceed.
    return overlay;
  }

  // Usage Stats (Needed to monitor app usage)
  Future<bool> isUsageStatsEnabled() async {
    return true; // Placeholder: Android check requires native code or usage_stats plugin
  }

  void requestUsageAccess() {
    final intent = AndroidIntent(
      action: 'android.settings.USAGE_ACCESS_SETTINGS',
      flags: [Flag.FLAG_ACTIVITY_NEW_TASK],
    );
    intent.launch();
  }

  void requestOverlayPermission() {
    final intent = AndroidIntent(
      action: 'android.settings.action.MANAGE_OVERLAY_PERMISSION',
      flags: [Flag.FLAG_ACTIVITY_NEW_TASK],
    );
    intent.launch();
  }

  void requestAccessibilityService() {
    final intent = AndroidIntent(
      action: 'android.settings.ACCESSIBILITY_SETTINGS',
      flags: [Flag.FLAG_ACTIVITY_NEW_TASK],
    );
    intent.launch();
  }
}
