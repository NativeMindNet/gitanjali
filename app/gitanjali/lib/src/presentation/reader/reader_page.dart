import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/audio_service.dart';
import '../../data/book_repository.dart';
import '../../data/reader_store.dart';
import '../../domain/models.dart';
import 'reader_controller.dart';
import 'widgets/background_layer.dart';
import 'widgets/reader_toolbar.dart';
import 'widgets/current_page_audio_card.dart';
import 'widgets/navigate_links_panel.dart';
import 'widgets/page_comments_card.dart';
import 'widgets/reader_page_header.dart';
import 'widgets/page_paragraphs.dart';
import 'widgets/reader_swipe_navigator.dart';

class ReaderPage extends StatefulWidget {
  const ReaderPage({super.key});

  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  late final ReaderController _controller;
  BookLanguage _bookLanguage = BookLanguage.eng;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = ReaderController(
      repository: BookRepository(),
      store: ReaderStore(),
      audioService: AudioService(),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final languageCode = Localizations.localeOf(context).languageCode.toLowerCase();
    final nextLanguage = languageCode.startsWith('ru') ? BookLanguage.ru : BookLanguage.eng;

    if (!_initialized) {
      _initialized = true;
      _bookLanguage = nextLanguage;
      unawaited(_controller.initialize(bookLanguage: _bookLanguage));
      return;
    }

    if (nextLanguage != _bookLanguage) {
      _bookLanguage = nextLanguage;
      unawaited(_controller.initialize(bookLanguage: _bookLanguage, forceReload: true));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(_controller.book?.title ?? 'Sri Gaudiya Gitanjali'),
            actions: [
              if (_controller.book != null)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Center(
                    child: Text(
                      '${_controller.currentPageIndex + 1}/${_controller.totalPages}',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                ),
            ],
          ),
          body: _buildBody(context),
          bottomNavigationBar: _controller.book == null ? null : ReaderToolbar(controller: _controller),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_controller.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 12),
              Text(
                _controller.error!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => _controller.initialize(bookLanguage: _bookLanguage, forceReload: true),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_controller.isLoading || _controller.currentPage == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final page = _controller.currentPage!;
    return ReaderSwipeNavigator(
      onNext: _controller.nextPage,
      onPrevious: _controller.previousPage,
      child: Stack(
        children: [
          Positioned.fill(
            child: BackgroundLayer(
              assetPath: page.backgroundAsset,
              frames: page.backgroundFrames,
              framesPerSecond: page.backgroundFramesPerSecond,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.90),
                    Colors.white.withValues(alpha: 0.82),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ReaderPageHeader(
                    title: page.contentTitle ?? page.title,
                    showNumber: page.showNumber,
                    pageIndex: page.index,
                  ),
                  const SizedBox(height: 16),
                  PageParagraphs(paragraphs: page.paragraphs),
                  PageCommentsCard(comments: page.comments),
                  NavigateLinksPanel(
                    controls: page.linkControls,
                    onControlTap: _controller.handleControl,
                  ),
                  if (page.audio != null) ...[
                    const SizedBox(height: 24),
                    CurrentPageAudioCard(
                      audio: page.audio!,
                      isPlaying: _controller.isPlayingCurrentPageAudio,
                      onToggle: () => unawaited(_controller.toggleCurrentPageAudio()),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
