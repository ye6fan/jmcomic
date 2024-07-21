import 'package:flutter/cupertino.dart';
import 'package:jmcomic/foundation/image_loader/cached_image_provider.dart';
import 'package:jmcomic/views/main_page.dart';
import 'package:jmcomic/views/widgets/comic_tile.dart';

import '../../foundation/image_loader/animated_image.dart';
import '../../network/jm_network/jm_config.dart';
import '../../network/jm_network/jm_models.dart';
import '../jm_comic/jm_comic_page.dart';

class JmComicTile extends ComicTile {
  final JmComicBrief comic;

  const JmComicTile(this.comic, {super.key});

  @override
  Widget get cover => AnimatedImage(
        image: CachedImageProvider(
          comic.image,
          headers: {'User-Agent': JmConfig.webUA, 'Connection': 'keep-alive'},
        ),
        height: double.infinity,
        width: double.infinity,
      );

  // 分类标签，感觉用labels也挺合适的
  @override
  String get labels => () {
        var labels = '';
        for (final category in comic.categories) {
          labels += category.title;
        }
        return labels;
      }();

  @override
  String get author => comic.author;

  @override
  String get name => comic.name;

  @override
  void onTap() {
    MainPage.to(() => JmComicPage(comic.id));
  }
}
