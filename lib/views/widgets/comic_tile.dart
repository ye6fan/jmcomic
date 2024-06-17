import 'package:flutter/material.dart';

abstract class ComicTile extends StatelessWidget {
  const ComicTile({super.key});

  Widget get cover;

  String get name;

  String get author;

  String get labels;

  int get maxLines => 3; //名字占据最多行

  int? get pages => null;

  void _onTap();

  @override
  Widget build(BuildContext context) {
    Widget child = _buildDetailedMode(context);
    return Stack(children: [
      Positioned.fill(child: child),
      Positioned(
        left: 16,
        top: 8,
        child: Container(
          height: 24,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
          clipBehavior: Clip.antiAlias,
          child: const Row(),
        ),
      )
    ]);
  }

  Widget _buildDetailedMode(BuildContext context) {
    return LayoutBuilder(builder: (context, constrains) {
      final height = constrains.maxHeight - 16;
      return Material(
        color: Colors.transparent,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 24, 8),
            child: Row(
              children: [
                Container(
                    width: height * 0.68,
                    height: double.infinity,
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(8)),
                    clipBehavior: Clip.antiAlias,
                    child: cover),
                SizedBox.fromSize(
                  size: const Size(16, 5),
                ),
                Expanded(
                  child: _ComicDescription(
                    name: name,
                    author: author,
                    labels: labels,
                    maxLines: maxLines,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _ComicDescription extends StatelessWidget {
  final String name;
  final String author;
  final String labels;
  final int? maxLines;

  const _ComicDescription({
    required this.name,
    required this.author,
    required this.labels,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(1, 0, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14.0,
            ),
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 1.0)),
          Column(
            children: [
              Text(
                author,
                style: const TextStyle(fontSize: 10.0),
                maxLines: 1,
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 1.0))
            ],
          ),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              const SizedBox(
                height: 5,
              ),
              const SizedBox(height: 2),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          labels,
                          style: const TextStyle(
                            fontSize: 12.0,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              )
            ],
          ))
        ],
      ),
    );
  }
}
