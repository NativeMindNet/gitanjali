import 'package:flutter/material.dart';

import '../../../domain/models.dart';
import '../reader_controller.dart';

class SearchSheet extends StatefulWidget {
  const SearchSheet({super.key, required this.controller});

  final ReaderController controller;

  @override
  State<SearchSheet> createState() => _SearchSheetState();
}

class _SearchSheetState extends State<SearchSheet> {
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
