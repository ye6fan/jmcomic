import 'package:plagiarize/network/jm_network/jm_config.dart';

import '../base_comic.dart';

class JmComicCategoryInfo {
  String id;
  String title;

  JmComicCategoryInfo(this.id, this.title);
}

class JmComicBrief extends BaseComic {
  List<JmComicCategoryInfo> categories;

  String get image => getJmCoverUrl(id);

  bool get liked => false;

  bool get isFavorite => false;

  JmComicBrief(
      super.name, super.author, super.id, super.description, this.categories);
}
