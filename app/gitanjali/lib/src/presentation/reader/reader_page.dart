import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/audio_service.dart';
import '../../data/book_repository.dart';
import '../../data/reader_store.dart';
import '../../domain/models.dart';
import 'reader_controller.dart';
import 'widgets/background_layer.dart';
import 'widgets/reader_toolbar.dart';

class ReaderPage extends StatefulWidget {
  const ReaderPage({super.key});

  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  late final ReaderController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ReaderController(
      repository: BookRepository(),
      store: ReaderStore(),
      audioService: AudioService(),
    );
    unawaited(_controller.initialize());
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
                onPressed: () => _controller.initialize(forceReload: true),
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
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity == null) {
          return;
        }
        if (details.primaryVelocity! < -150) {
          _controller.nextPage();
        } else if (details.primaryVelocity! > 150) {
          _controller.previousPage();
        }
      },
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
                  if ((page.contentTitle ?? page.title).isNotEmpty)
                    Text(
                      page.contentTitle ?? page.title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF5A3D2B),
                          ),
                    ),
                  if (page.showNumber) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Page ${page.index + 1}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.brown.shade700,
                          ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  ...page.paragraphs.where((paragraph) => !paragraph.hidden).map(
                        (paragraph) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            paragraph.text,
                            textAlign: paragraph.style.textAlign,
                            style: TextStyle(
                              fontFamily: paragraph.style.fontFamily,
                              fontSize: paragraph.style.fontSize,
                              color: paragraph.style.textColor,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                  if (page.comments != null && page.comments!.trim().isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          page.comments!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  ],
                  if (page.linkControls.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      'Navigate',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: page.linkControls
                          .map(
                            (control) => _PageLinkButton(
                              control: control,
                              onPressed: () => _controller.handleControl(control),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  if (page.audio != null) ...[
                    const SizedBox(height: 24),
                    Card(
                      child: ListTile(
                        leading: Icon(
                          _controller.isPlayingCurrentPageAudio
                              ? Icons.stop_circle_outlined
                              : Icons.play_circle_outline,
                        ),
                        title: Text(page.audio!.displayName),
                        subtitle: Text(page.audio!.autoplay ? 'Autoplay enabled' : 'Tap to play'),
                        onTap: _controller.toggleCurrentPageAudio,
                      ),
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

class _PageLinkButton extends StatelessWidget {
  const _PageLinkButton({
    required this.control,
    required this.onPressed,
  });

  final ControlInfo control;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final asset = control.highlightedImageAsset ?? control.imageAsset;
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.brown.shade200),
        ),
        child: asset == null
            ? Center(
                child: Text(
                  'Page ${control.targetPageIndex! + 1}',
                  textAlign: TextAlign.center,
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(8),
                child: Image.asset(
                  asset,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => Center(
                    child: Text(
                      'Page ${control.targetPageIndex! + 1}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

