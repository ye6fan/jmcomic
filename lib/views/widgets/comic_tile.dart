import 'package:flutter/material.dart';

class _ComicDescription extends StatelessWidget {
  final String name;
  final String author;
  final String labels;
  final int maxLines;

  const _ComicDescription(
      {required this.name,
      required this.author,
      required this.labels,
      required this.maxLines});

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(name,
              style:
                  const TextStyle(fontWeight: FontWeight.w500, fontSize: 14.0),
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 5),
          Text(author, style: const TextStyle(fontSize: 10.0), maxLines: 1),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                Text(labels, style: const TextStyle(fontSize: 12.0))
              ]))
        ]);
  }
}

abstract class ComicTile extends StatelessWidget {
  const ComicTile({super.key});

  Widget get cover;

  String get name;

  String get author;

  String get labels;

  int get maxLines => 3;

  int? get pages => null;

  void onTap();

  @override
  Widget build(BuildContext context) {
    Widget child = _buildDetailedMode(context);
    return Stack(children: [Positioned.fill(child: child)]);
  }

  Widget _buildDetailedMode(BuildContext context) {
    return LayoutBuilder(builder: (context, constrains) {
      // 子树中的Padding上下都要填充8像素
      final height = constrains.maxHeight - 16;
      return Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onTap,
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 24, 8),
                  child: Row(children: [
                    Container(
                        width: height * 0.75,
                        height: double.infinity,
                        decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(8)),
                        clipBehavior: Clip.antiAlias,
                        child: cover),
                    const SizedBox(width: 16),
                    Expanded(
                        child: _ComicDescription(
                            name: name,
                            author: author,
                            labels: labels,
                            maxLines: maxLines))
                  ]))));
    });
  }
}
