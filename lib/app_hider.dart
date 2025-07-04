import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class AppHider {
  static const MethodChannel _channel = MethodChannel('app_hider');

  static Future<bool> hideApp(String packageName) async {
    try {
      final result = await _channel.invokeMethod<bool>('hideApp', {
        'packageName': packageName,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Failed to hide app: ${e.message}');
      return false;
    }
  }

  static Future<bool> showApp(String packageName) async {
    try {
      final result = await _channel.invokeMethod<bool>('showApp', {
        'packageName': packageName,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Failed to show app: ${e.message}');
      return false;
    }
  }

  static Future<bool> isAppHidden(String packageName) async {
    try {
      final result = await _channel.invokeMethod<bool>('isAppHidden', {
        'packageName': packageName,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Failed to check app status: ${e.message}');
      return false;
    }
  }
}