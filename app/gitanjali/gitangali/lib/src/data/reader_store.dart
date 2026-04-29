import 'package:shared_preferences/shared_preferences.dart';

class ReaderStore {
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
}

