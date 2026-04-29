import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitangali/src/data/audio_service.dart';
import 'package:gitangali/src/data/book_repository.dart';
import 'package:gitangali/src/data/reader_store.dart';
import 'package:gitangali/src/domain/models.dart';
import 'package:gitangali/src/presentation/reader/reader_controller.dart';
import 'package:just_audio/just_audio.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ReaderController', () {
    late _FakeBookRepository repository;
    late _FakeReaderStore store;
    late _FakeAudioService audioService;
    late ReaderController controller;

    setUp(() {
      repository = _FakeBookRepository();
      store = _FakeReaderStore();
      audioService = _FakeAudioService();
      controller = ReaderController(
        repository: repository,
        store: store,
        audioService: audioService,
      );
    });

    tearDown(() {
      controller.dispose();
    });

    test('initialize loads book, bookmarks, and restored page', () async {
      store.loadedBookmarks = {1};
      store.loadedPageIndex = 1;

      await controller.initialize(bookLanguage: BookLanguage.eng);

      expect(controller.book, isNotNull);
      expect(controller.totalPages, 2);
      expect(controller.currentPageIndex, 1);
      expect(controller.isCurrentPageBookmarked, isTrue);
    });

    test('navigation changes page and persists index', () async {
      await controller.initialize(bookLanguage: BookLanguage.eng);
      expect(controller.currentPageIndex, 0);

      await controller.nextPage();
      expect(controller.currentPageIndex, 1);
      expect(store.lastSavedPageIndex, 1);

      await controller.nextPage();
      expect(controller.currentPageIndex, 1);

      await controller.previousPage();
      expect(controller.currentPageIndex, 0);
      expect(store.lastSavedPageIndex, 0);
    });

    test('toggleBookmark adds/removes current page and persists', () async {
      await controller.initialize(bookLanguage: BookLanguage.eng);
      expect(controller.bookmarks, isEmpty);

      await controller.toggleBookmark();
      expect(controller.bookmarks, {0});
      expect(store.lastSavedBookmarks, {0});

      await controller.toggleBookmark();
      expect(controller.bookmarks, isEmpty);
      expect(store.lastSavedBookmarks, isEmpty);
    });

    test('search returns matches by selected scope', () async {
      await controller.initialize(bookLanguage: BookLanguage.eng);

      final contentResults = controller.search('Hari', SearchScope.content);
      expect(contentResults.map((e) => e.pageIndex), [0]);

      final commentsResults = controller.search('note', SearchScope.comments);
      expect(commentsResults.map((e) => e.pageIndex), [1]);

      final titleResults = controller.search('chapter', SearchScope.titles);
      expect(titleResults.map((e) => e.pageIndex), [0, 1]);
    });

    test('initialize triggers autoplay on restored page with autoplay audio', () async {
      store.loadedPageIndex = 1;

      await controller.initialize(bookLanguage: BookLanguage.eng);

      expect(audioService.playCalls, 1);
      expect(audioService.currentAsset, 'assets/legacy/Sounds/chapter-two.m4a');
      expect(controller.isPlayingCurrentPageAudio, isTrue);
    });

    test('goToPage triggers autoplay when target page has autoplay audio', () async {
      await controller.initialize(bookLanguage: BookLanguage.eng);
      expect(audioService.playCalls, 0);

      await controller.goToPage(1);

      expect(audioService.playCalls, 1);
      expect(audioService.currentAsset, 'assets/legacy/Sounds/chapter-two.m4a');
    });

    test('toggleCurrentPageAudio stops and replays current page audio', () async {
      store.loadedPageIndex = 1;
      await controller.initialize(bookLanguage: BookLanguage.eng);
      expect(audioService.playCalls, 1);
      expect(audioService.isPlaying, isTrue);

      await controller.toggleCurrentPageAudio();
      expect(audioService.stopCalls, 1);
      expect(audioService.isPlaying, isFalse);

      await controller.toggleCurrentPageAudio();
      expect(audioService.playCalls, 2);
      expect(audioService.isPlaying, isTrue);
    });
  });
}

class _FakeBookRepository extends BookRepository {
  @override
  Future<Book> loadBook({required BookLanguage language}) async => _sampleBook;
}

class _FakeReaderStore extends ReaderStore {
  int loadedPageIndex = 0;
  Set<int> loadedBookmarks = <int>{};
  int? lastSavedPageIndex;
  Set<int>? lastSavedBookmarks;

  @override
  Future<int> loadPageIndex(String bookId, int pageCount) async => loadedPageIndex;

  @override
  Future<Set<int>> loadBookmarks(String bookId) async => loadedBookmarks;

  @override
  Future<void> savePageIndex(String bookId, int index) async {
    lastSavedPageIndex = index;
  }

  @override
  Future<void> saveBookmarks(String bookId, Set<int> bookmarks) async {
    lastSavedBookmarks = Set<int>.from(bookmarks);
  }
}

class _FakeAudioService extends AudioService {
  final StreamController<PlayerState> _stateController = StreamController<PlayerState>.broadcast();
  bool _isPlaying = false;
  bool _disposed = false;
  int playCalls = 0;
  int stopCalls = 0;

  @override
  Stream<PlayerState> get playerStateStream => _stateController.stream;

  @override
  bool get isPlaying => _isPlaying;

  @override
  Future<void> play(PageAudio audio) async {
    playCalls += 1;
    currentAsset = audio.assetPath;
    _isPlaying = true;
  }

  @override
  Future<void> stop() async {
    stopCalls += 1;
    _isPlaying = false;
  }

  @override
  Future<void> dispose() async {
    if (_disposed) {
      return;
    }
    _disposed = true;
    await _stateController.close();
  }
}

final _sampleBook = Book(
  id: 'book',
  title: 'Sample',
  pages: [
    BookPage(
      index: 0,
      title: 'Chapter One',
      contentTitle: 'Chapter One',
      paragraphs: const [
        ParagraphSpec(
          text: 'Hari bol',
          hidden: false,
          style: ParagraphStyleSpec(
            fontFamily: 'MurariChandUni',
            fontSize: 18,
            textAlign: TextAlign.left,
            textColor: Color(0xFF000000),
          ),
        ),
      ],
      comments: '',
      backgroundAsset: null,
      backgroundFrames: const [],
      backgroundFramesPerSecond: null,
      controls: const [],
      showNumber: true,
      audio: null,
    ),
    BookPage(
      index: 1,
      title: 'Chapter Two',
      contentTitle: 'Chapter Two',
      paragraphs: const [
        ParagraphSpec(
          text: 'Gaura',
          hidden: false,
          style: ParagraphStyleSpec(
            fontFamily: 'MurariChandUni',
            fontSize: 18,
            textAlign: TextAlign.left,
            textColor: Color(0xFF000000),
          ),
        ),
      ],
      comments: 'Important note',
      backgroundAsset: null,
      backgroundFrames: const [],
      backgroundFramesPerSecond: null,
      controls: const [],
      showNumber: true,
      audio: const PageAudio(
        assetPath: 'assets/legacy/Sounds/chapter-two.m4a',
        displayName: 'Chapter two',
        autoplay: true,
        loop: false,
      ),
    ),
  ],
  globalControls: const [],
);
