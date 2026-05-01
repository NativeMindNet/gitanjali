import 'package:flutter/material.dart';

import '../../data/reader_store.dart';
import '../../domain/models.dart';

/// Controller for user settings (language, text size, theme)
class SettingsController extends ChangeNotifier {
  SettingsController({required this.store});

  final ReaderStore store;

  LanguageOption _language = LanguageOption.auto;
  TextSizeOption _textSize = TextSizeOption.medium;
  ThemeOption _theme = ThemeOption.light;
  bool _isInitialized = false;

  /// Current language preference
  LanguageOption get language => _language;

  /// Current text size preference
  TextSizeOption get textSize => _textSize;

  /// Current theme preference
  ThemeOption get theme => _theme;

  /// Whether settings have been loaded from storage
  bool get isInitialized => _isInitialized;

  /// Text scale factor based on text size setting
  double get textScaleFactor => _textSize.scaleFactor;

  /// ThemeMode for MaterialApp
  ThemeMode get themeMode {
    switch (_theme) {
      case ThemeOption.light:
        return ThemeMode.light;
      case ThemeOption.dark:
        return ThemeMode.dark;
      case ThemeOption.system:
        return ThemeMode.system;
    }
  }

  /// Get effective BookLanguage based on language setting and system locale
  BookLanguage effectiveLanguage(String systemLocale) {
    return _language.toBookLanguage(systemLocale);
  }

  /// Initialize by loading settings from storage
  Future<void> initialize() async {
    if (_isInitialized) return;

    _language = await store.loadLanguage();
    _textSize = await store.loadTextSize();
    _theme = await store.loadTheme();
    _isInitialized = true;
    notifyListeners();
  }

  /// Update language preference
  Future<void> setLanguage(LanguageOption value) async {
    if (_language == value) return;
    _language = value;
    await store.saveLanguage(value);
    notifyListeners();
  }

  /// Update text size preference
  Future<void> setTextSize(TextSizeOption value) async {
    if (_textSize == value) return;
    _textSize = value;
    await store.saveTextSize(value);
    notifyListeners();
  }

  /// Update theme preference
  Future<void> setTheme(ThemeOption value) async {
    if (_theme == value) return;
    _theme = value;
    await store.saveTheme(value);
    notifyListeners();
  }
}
