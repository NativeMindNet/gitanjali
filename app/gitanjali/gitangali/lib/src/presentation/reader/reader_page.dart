import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/audio_service.dart';
import '../../data/book_repository.dart';
import '../../data/reader_store.dart';
import '../../domain/models.dart';
import 'reader_controller.dart';

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
          bottomNavigationBar:
              _controller.book == null ? null : _ReaderToolbar(controller: _controller),
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
            child: _BackgroundImage(assetPath: page.backgroundAsset),
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

class _ReaderToolbar extends StatelessWidget {
  const _ReaderToolbar({required this.controller});

  final ReaderController controller;

  @override
  Widget build(BuildContext context) {
    final bookmarked = controller.isCurrentPageBookmarked;
    return SafeArea(
      child: BottomAppBar(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              IconButton(
                onPressed: controller.canGoPrevious ? controller.previousPage : null,
                icon: const Icon(Icons.chevron_left),
                tooltip: 'Previous',
              ),
              IconButton(
                onPressed: controller.toggleBookmark,
                icon: Icon(bookmarked ? Icons.bookmark : Icons.bookmark_add_outlined),
                tooltip: bookmarked ? 'Remove bookmark' : 'Add bookmark',
              ),
              IconButton(
                onPressed: () => _showBookmarks(context, controller),
                icon: const Icon(Icons.bookmarks_outlined),
                tooltip: 'Bookmarks',
              ),
              IconButton(
                onPressed: controller.goHome,
                icon: const Icon(Icons.home_outlined),
                tooltip: 'Home',
              ),
              IconButton(
                onPressed: () => _showSearch(context, controller),
                icon: const Icon(Icons.search),
                tooltip: 'Search',
              ),
              IconButton(
                onPressed: controller.currentPage?.audio == null
                    ? null
                    : controller.toggleCurrentPageAudio,
                icon: Icon(
                  controller.isPlayingCurrentPageAudio
                      ? Icons.stop_circle_outlined
                      : Icons.play_circle_outline,
                ),
                tooltip: 'Play / stop audio',
              ),
              IconButton(
                onPressed: controller.canGoNext ? controller.nextPage : null,
                icon: const Icon(Icons.chevron_right),
                tooltip: 'Next',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showBookmarks(BuildContext context, ReaderController controller) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final bookmarks = controller.bookmarkedPages;
        if (bookmarks.isEmpty) {
          return const SizedBox(
            height: 160,
            child: Center(child: Text('No bookmarks yet')),
          );
        }
        return ListView.builder(
          itemCount: bookmarks.length,
          itemBuilder: (context, index) {
            final page = bookmarks[index];
            return ListTile(
              leading: const Icon(Icons.bookmark),
              title: Text(page.contentTitle ?? page.title),
              subtitle: Text('Page ${page.index + 1}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  controller.removeBookmark(page.index);
                  Navigator.of(context).pop();
                },
              ),
              onTap: () {
                controller.goToPage(page.index);
                Navigator.of(context).pop();
              },
            );
          },
        );
      },
    );
  }

  Future<void> _showSearch(BuildContext context, ReaderController controller) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _SearchSheet(controller: controller),
    );
  }
}

class _SearchSheet extends StatefulWidget {
  const _SearchSheet({required this.controller});

  final ReaderController controller;

  @override
  State<_SearchSheet> createState() => _SearchSheetState();
}

class _SearchSheetState extends State<_SearchSheet> {
  late final TextEditingController _textController;
  SearchScope _scope = SearchScope.content;
  List<SearchResult> _results = const [];

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _textController.addListener(_updateResults);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _updateResults() {
    setState(() {
      _results = widget.controller.search(_textController.text, _scope);
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
      child: SizedBox(
        height: mediaQuery.size.height * 0.75,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  labelText: 'Search Gitanjali',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DropdownButtonFormField<SearchScope>(
                initialValue: _scope,
                decoration: const InputDecoration(
                  labelText: 'Scope',
                  border: OutlineInputBorder(),
                ),
                items: SearchScope.values
                    .map(
                      (scope) => DropdownMenuItem(
                        value: scope,
                        child: Text(scope.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _scope = value;
                    _results = widget.controller.search(_textController.text, _scope);
                  });
                },
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _textController.text.trim().isEmpty
                  ? const Center(child: Text('Type to search content, comments, or titles'))
                  : ListView.separated(
                      itemCount: _results.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final result = _results[index];
                        return ListTile(
                          title: Text(result.title),
                          subtitle: Text(result.excerpt),
                          trailing: Text('P${result.pageIndex + 1}'),
                          onTap: () {
                            widget.controller.goToPage(result.pageIndex);
                            Navigator.of(context).pop();
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
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

class _BackgroundImage extends StatelessWidget {
  const _BackgroundImage({required this.assetPath});

  final String? assetPath;

  @override
  Widget build(BuildContext context) {
    if (assetPath == null) {
      return const DecoratedBox(
        decoration: BoxDecoration(
          color: Color(0xFFF1E7D3),
        ),
      );
    }

    return Image.asset(
      assetPath!,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const DecoratedBox(
        decoration: BoxDecoration(
          color: Color(0xFFF1E7D3),
        ),
      ),
    );
  }
}

