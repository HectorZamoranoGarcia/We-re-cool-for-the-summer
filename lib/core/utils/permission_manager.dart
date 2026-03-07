import 'package:permission_handler/permission_handler.dart';

/// Encapsulates the logic for requesting and checking native permissions.
/// Facilitates the creation of a future "Rationale Screen" for Google Play compliance.
class PermissionManager {
  /// Checks the current camera permission status.
  static Future<PermissionStatus> checkCameraPermission() async {
    return await Permission.camera.status;
  }

  /// Requests camera permission from the user.
  /// Returns [true] if granted, [false] otherwise.
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Checks if the permission was permanently denied, requiring the user
  /// to open the OS settings manually.
  static Future<bool> isCameraPermanentlyDenied() async {
    return await Permission.camera.isPermanentlyDenied;
  }
}
