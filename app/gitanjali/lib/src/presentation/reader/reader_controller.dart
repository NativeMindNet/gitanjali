import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../../data/audio_service.dart';
import '../../data/book_repository.dart';
import '../../data/reader_store.dart';
import '../../domain/models.dart';

class ReaderController extends ChangeNotifier {
  ReaderController({
    required this.repository,
    required this.store,
    required this.audioService,
  }) {
    _audioSubscription = audioService.playerStateStream.listen((_) {
      notifyListeners();
    });
  }

  final BookRepository repository;
  final ReaderStore store;
  final AudioService audioService;

  StreamSubscription<PlayerState>? _audioSubscription;

  bool isLoading = true;
  String? error;
  Book? book;
  int currentPageIndex = 0;
  Set<int> bookmarks = <int>{};

  BookPage? get currentPage =>
      book == null || book!.pages.isEmpty ? null : book!.pages[currentPageIndex];

  int get totalPages => book?.pages.length ?? 0;

  bool get canGoPrevious => currentPageIndex > 0;

  bool get canGoNext => book != null && currentPageIndex < book!.pages.length - 1;

  bool get isCurrentPageBookmarked => bookmarks.contains(currentPageIndex);

  bool get isPlayingCurrentPageAudio {
    final pageAudio = currentPage?.audio;
    if (pageAudio == null) {
      return false;
    }
    return audioService.currentAsset == pageAudio.assetPath && audioService.isPlaying;
  }

  List<BookPage> get bookmarkedPages {
    final loadedBook = book;
    if (loadedBook == null) {
      return const [];
    }
    final sorted = bookmarks.toList()..sort();
    return sorted
        .where((index) => index >= 0 && index < loadedBook.pages.length)
        .map((index) => loadedBook.pages[index])
        .toList();
  }

  Future<void> initialize({bool forceReload = false}) async {
    if (book != null && !forceReload) {
      return;
    }
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final loadedBook = await repository.loadBook();
      book = loadedBook;
      bookmarks = await store.loadBookmarks(loadedBook.id);
      currentPageIndex = await store.loadPageIndex(loadedBook.id, loadedBook.pages.length);
      await _applyAutoplay();
    } catch (exception) {
      error = 'Failed to load Gitanjali: $exception';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> nextPage() => goToPage(currentPageIndex + 1);

  Future<void> previousPage() => goToPage(currentPageIndex - 1);

  Future<void> goHome() async {
    final homeControl = book?.globalControls
        .where((control) => control.type == ControlType.pageLink)
        .cast<ControlInfo?>()
        .firstWhere(
          (control) => control?.targetPageIndex != null,
          orElse: () => null,
        );
    if (homeControl?.targetPageIndex != null) {
      await goToPage(homeControl!.targetPageIndex!);
      return;
    }
    await goToPage(0);
  }

  Future<void> goToPage(int index) async {
    final loadedBook = book;
    if (loadedBook == null || index < 0 || index >= loadedBook.pages.length) {
      return;
    }
    currentPageIndex = index;
    await store.savePageIndex(loadedBook.id, index);
    await _applyAutoplay();
    notifyListeners();
  }

  Future<void> toggleBookmark() async {
    final loadedBook = book;
    if (loadedBook == null) {
      return;
    }
    if (bookmarks.contains(currentPageIndex)) {
      bookmarks.remove(currentPageIndex);
    } else {
      bookmarks.add(currentPageIndex);
    }
    await store.saveBookmarks(loadedBook.id, bookmarks);
    notifyListeners();
  }

  Future<void> removeBookmark(int pageIndex) async {
    final loadedBook = book;
    if (loadedBook == null) {
      return;
    }
    bookmarks.remove(pageIndex);
    await store.saveBookmarks(loadedBook.id, bookmarks);
    notifyListeners();
  }

  List<SearchResult> search(String query, SearchScope scope) {
    final loadedBook = book;
    final normalizedQuery = query.trim().toLowerCase();
    if (loadedBook == null || normalizedQuery.isEmpty) {
      return const [];
    }

    return loadedBook.pages
        .where((page) => _pageMatches(page, normalizedQuery, scope))
        .map((page) => SearchResult(
              pageIndex: page.index,
              title: page.contentTitle ?? page.title,
              excerpt: _excerpt(page, scope),
            ))
        .toList();
  }

  bool _pageMatches(BookPage page, String query, SearchScope scope) {
    switch (scope) {
      case SearchScope.content:
        return page.searchableContent.contains(query);
      case SearchScope.comments:
        return (page.comments ?? '').toLowerCase().contains(query);
      case SearchScope.titles:
        return '${page.title} ${page.contentTitle ?? ''}'.toLowerCase().contains(query);
    }
  }

  String _excerpt(BookPage page, SearchScope scope) {
    switch (scope) {
      case SearchScope.content:
        return page.paragraphs.map((e) => e.text).join(' ').trim();
      case SearchScope.comments:
        return page.comments ?? '';
      case SearchScope.titles:
        return page.contentTitle ?? page.title;
    }
  }

  Future<void> handleControl(ControlInfo control) async {
    switch (control.type) {
      case ControlType.prevPage:
        await previousPage();
      case ControlType.nextPage:
        await nextPage();
      case ControlType.pageLink:
        if (control.targetPageIndex != null) {
          await goToPage(control.targetPageIndex!);
        }
      case ControlType.playSound:
        await toggleCurrentPageAudio();
      case ControlType.stopSound:
        await audioService.stop();
        notifyListeners();
      case ControlType.addBookmark:
        await toggleBookmark();
      case ControlType.bookmarks:
      case ControlType.search:
      case ControlType.togglePlayer:
      case ControlType.unknown:
        break;
    }
  }

  Future<void> toggleCurrentPageAudio() async {
    final pageAudio = currentPage?.audio;
    if (pageAudio == null) {
      return;
    }
    if (audioService.currentAsset == pageAudio.assetPath && audioService.isPlaying) {
      await audioService.stop();
    } else {
      await audioService.play(pageAudio);
    }
    notifyListeners();
  }

  Future<void> _applyAutoplay() async {
    final pageAudio = currentPage?.audio;
    if (pageAudio?.autoplay == true) {
      await audioService.play(pageAudio!);
      return;
    }
    if (audioService.currentAsset != null &&
        audioService.currentAsset != pageAudio?.assetPath &&
        !audioService.isPlaying) {
      await audioService.stop();
    }
  }

  @override
  void dispose() {
    _audioSubscription?.cancel();
    audioService.dispose();
    super.dispose();
  }
}

