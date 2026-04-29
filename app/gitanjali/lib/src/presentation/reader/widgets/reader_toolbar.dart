import 'package:flutter/material.dart';

import '../reader_controller.dart';
import 'search_sheet.dart';

class ReaderToolbar extends StatelessWidget {
  const ReaderToolbar({super.key, required this.controller});

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
      builder: (context) => SearchSheet(controller: controller),
    );
  }
}
