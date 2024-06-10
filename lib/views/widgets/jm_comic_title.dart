import 'package:flutter/cupertino.dart';
import 'package:plagiarize/network/jm_network/jm_models.dart';
import 'package:plagiarize/views/widgets/comic_tile.dart';

class JmComicTile extends ComicTile {
  final JmComicBrief comic;

  const JmComicTile(this.comic, {super.key});

  @override
  Widget get image => const Center(child: Text('image'));

  @override
  String get tags => () {
        var categories = '';
        for (final category in comic.categories) {
          categories += category.title;
        }
        return categories;
      }();

  @override
  String get author => comic.author;

  @override
  String get name => comic.name;
}
