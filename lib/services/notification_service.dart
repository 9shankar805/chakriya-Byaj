import 'dart:async';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Bridges Flutter settings to the native Kotlin notification service.
/// The native side draws the BS day number directly into the status bar icon.
class NotificationService {
  static const _channel = MethodChannel('com.chakriya.byaj/notification');

  static const _prefKey = 'nepali_date_notif_enabled';
  static const _langKey = 'nepali_date_notif_lang';

  static Timer? _dailyTimer;

  // ── Init (called in main) ─────────────────────────────────────────────────
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_prefKey) ?? false) {
      final useNepali = prefs.getBool(_langKey) ?? true;
      await _show(useNepali: useNepali);
      _startDailyRefresh();
    }
  }

  // ── Show notification via native ──────────────────────────────────────────
  static Future<void> _show({bool useNepali = true}) async {
    try {
      await _channel.invokeMethod('showNotification', {'useNepali': useNepali});
    } catch (_) {
      // Native channel not available in test/web builds
    }
  }

  // ── Cancel ────────────────────────────────────────────────────────────────
  static Future<void> _cancel() async {
    try {
      await _channel.invokeMethod('cancelNotification');
    } catch (_) {}
    _dailyTimer?.cancel();
  }

  // ── Enable / disable ─────────────────────────────────────────────────────
  static Future<bool> setEnabled({
    required bool enabled,
    required bool useNepali,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_langKey, useNepali);

    if (enabled) {
      await prefs.setBool(_prefKey, true);
      await _show(useNepali: useNepali);
      _startDailyRefresh();
    } else {
      await prefs.setBool(_prefKey, false);
      await _cancel();
    }
    return true;
  }

  // ── Update language only ──────────────────────────────────────────────────
  static Future<void> updateLanguage(bool useNepali) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_langKey, useNepali);
    try {
      await _channel.invokeMethod('updateLanguage', {'useNepali': useNepali});
    } catch (_) {}
  }

  // ── Getters ───────────────────────────────────────────────────────────────
  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKey) ?? false;
  }

  static Future<bool> isNepaliLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_langKey) ?? true;
  }

  // ── Auto-refresh at midnight ──────────────────────────────────────────────
  static void _startDailyRefresh() {
    _dailyTimer?.cancel();
    _dailyTimer = Timer.periodic(const Duration(minutes: 30), (_) async {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(_prefKey) ?? false) {
        final useNepali = prefs.getBool(_langKey) ?? true;
        await _show(useNepali: useNepali);
      }
    });
  }
}
