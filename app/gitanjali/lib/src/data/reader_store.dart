import 'package:shared_preferences/shared_preferences.dart';

import '../domain/models.dart';

class ReaderStore {
  // Settings keys
  static const _keyLanguage = 'reader_settings_language';
  static const _keyTextSize = 'reader_settings_textSize';
  static const _keyTheme = 'reader_settings_theme';
  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<int> loadPageIndex(String bookId, int pageCount) async {
    final prefs = await _prefs;
    final index = prefs.getInt('reader_page_$bookId') ?? 0;
    if (index < 0 || index >= pageCount) {
      return 0;
    }
    return index;
  }

  Future<void> savePageIndex(String bookId, int index) async {
    final prefs = await _prefs;
    await prefs.setInt('reader_page_$bookId', index);
  }

  Future<Set<int>> loadBookmarks(String bookId) async {
    final prefs = await _prefs;
    final saved = prefs.getStringList('reader_bookmarks_$bookId') ?? const [];
    return saved.map(int.tryParse).whereType<int>().toSet();
  }

  Future<void> saveBookmarks(String bookId, Set<int> bookmarks) async {
    final prefs = await _prefs;
    final values = bookmarks.toList()..sort();
    await prefs.setStringList(
      'reader_bookmarks_$bookId',
      values.map((value) => value.toString()).toList(),
    );
  }

  // ===========================================================================
  // Settings Persistence (VDD: vdd-gitanjaly-layout)
  // ===========================================================================

  Future<LanguageOption> loadLanguage() async {
    final prefs = await _prefs;
    final value = prefs.getString(_keyLanguage);
    return LanguageOption.values.firstWhere(
      (e) => e.name == value,
      orElse: () => LanguageOption.auto,
    );
  }

  Future<void> saveLanguage(LanguageOption value) async {
    final prefs = await _prefs;
    await prefs.setString(_keyLanguage, value.name);
  }

  Future<TextSizeOption> loadTextSize() async {
    final prefs = await _prefs;
    final value = prefs.getString(_keyTextSize);
    return TextSizeOption.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TextSizeOption.medium,
    );
  }

  Future<void> saveTextSize(TextSizeOption value) async {
    final prefs = await _prefs;
    await prefs.setString(_keyTextSize, value.name);
  }

  Future<ThemeOption> loadTheme() async {
    final prefs = await _prefs;
    final value = prefs.getString(_keyTheme);
    return ThemeOption.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ThemeOption.light,
    );
  }

  Future<void> saveTheme(ThemeOption value) async {
    final prefs = await _prefs;
    await prefs.setString(_keyTheme, value.name);
  }
}

