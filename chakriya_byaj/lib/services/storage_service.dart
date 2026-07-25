import 'package:shared_preferences/shared_preferences.dart';
import '../models/saved_record.dart';

class StorageService {
  static const _key = 'chakriya_records';

  static Future<List<SavedRecord>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    return list
        .map((s) => SavedRecord.fromJsonString(s))
        .toList()
      ..sort((a, b) => b.savedAt.compareTo(a.savedAt)); // newest first
  }

  static Future<void> save(SavedRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    list.add(record.toJsonString());
    await prefs.setStringList(_key, list);
  }

  static Future<void> delete(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    list.removeWhere((s) => SavedRecord.fromJsonString(s).id == id);
    await prefs.setStringList(_key, list);
  }

  static Future<void> deleteAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
