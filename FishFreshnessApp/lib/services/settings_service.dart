import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _kHapticFeedback = 'haptic_feedback';
  static const String _kFlashOnStart = 'flash_on_start';

  bool _hapticFeedback = true;
  bool _flashOnStart = false;

  bool get hapticFeedback => _hapticFeedback;
  bool get flashOnStart => _flashOnStart;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _hapticFeedback = prefs.getBool(_kHapticFeedback) ?? true;
      _flashOnStart = prefs.getBool(_kFlashOnStart) ?? false;
    } catch (_) {
      // Keep defaults if preferences cannot be loaded.
    }
  }

  Future<void> setHapticFeedback(bool value) async {
    _hapticFeedback = value;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kHapticFeedback, value);
    } catch (_) {}
  }

  Future<void> setFlashOnStart(bool value) async {
    _flashOnStart = value;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kFlashOnStart, value);
    } catch (_) {}
  }
}
