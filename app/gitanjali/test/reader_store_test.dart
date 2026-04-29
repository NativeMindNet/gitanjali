import 'package:flutter_test/flutter_test.dart';
import 'package:gitangali/src/data/reader_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ReaderStore', () {
    late ReaderStore store;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      store = ReaderStore();
    });

    test('returns 0 when saved page index is missing', () async {
      final index = await store.loadPageIndex('book', 10);
      expect(index, 0);
    });

    test('falls back to 0 for out-of-range saved page index', () async {
      SharedPreferences.setMockInitialValues({'reader_page_book': 99});
      store = ReaderStore();

      final index = await store.loadPageIndex('book', 10);
      expect(index, 0);
    });

    test('loads saved page index when within range', () async {
      SharedPreferences.setMockInitialValues({'reader_page_book': 3});
      store = ReaderStore();

      final index = await store.loadPageIndex('book', 10);
      expect(index, 3);
    });

    test('saves and loads sorted bookmarks', () async {
      await store.saveBookmarks('book', {5, 1, 3});
      final bookmarks = await store.loadBookmarks('book');

      expect(bookmarks, {1, 3, 5});
    });

    test('ignores malformed bookmark values', () async {
      SharedPreferences.setMockInitialValues({
        'reader_bookmarks_book': ['2', 'abc', '-1'],
      });
      store = ReaderStore();

      final bookmarks = await store.loadBookmarks('book');
      expect(bookmarks, {2, -1});
    });
  });
}
