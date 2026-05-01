import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitangali/src/data/audio_controller.dart';
import 'package:gitangali/src/data/book_repository.dart';
import 'package:gitangali/src/data/reader_store.dart';
import 'package:gitangali/src/domain/models.dart';
import 'package:gitangali/src/presentation/reader/reader_controller.dart';
import 'package:gitangali/src/presentation/reader/widgets/reader_toolbar.dart';
import 'package:just_audio/just_audio.dart';

void main() {
  testWidgets('ReaderToolbar renders actions and disables audio without page audio', (tester) async {
    final controller = ReaderController(
      repository: _FakeBookRepository(),
      store: _FakeReaderStore(),
      audioService: _FakeAudioController(),
    );
    addTearDown(controller.dispose);
    await controller.initialize(bookLanguage: BookLanguage.eng);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: ReaderToolbar(controller: controller),
        ),
      ),
    );

    expect(find.byTooltip('Previous'), findsOneWidget);
    expect(find.byTooltip('Bookmarks'), findsOneWidget);
    expect(find.byTooltip('Home'), findsOneWidget);
    expect(find.byTooltip('Search'), findsOneWidget);
    expect(find.byTooltip('Play / stop audio'), findsOneWidget);
    expect(find.byTooltip('Next'), findsOneWidget);

    final audioButtonFinder = find.ancestor(
      of: find.byTooltip('Play / stop audio'),
      matching: find.byType(IconButton),
    );
    final audioButton = tester.widget<IconButton>(audioButtonFinder);
    expect(audioButton.onPressed, isNull);
  });
}

class _FakeBookRepository extends BookRepository {
  @override
  Future<Book> loadBook({required BookLanguage language}) async => _sampleBook;
}

class _FakeReaderStore extends ReaderStore {
  @override
  Future<int> loadPageIndex(String bookId, int pageCount) async => 0;

  @override
  Future<Set<int>> loadBookmarks(String bookId) async => <int>{};
}

class _FakeAudioController extends AudioController {
  final StreamController<PlayerState> _stateController = StreamController<PlayerState>.broadcast();
  bool _disposed = false;

  @override
  Stream<PlayerState> get playerStateStream => _stateController.stream;

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _stateController.close();
    super.dispose();
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
  ],
  globalControls: const [],
);
