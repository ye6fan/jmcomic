import 'package:plagiarize/network/jm_network/jm_config.dart';

import '../base_model.dart';

class JmComicCategoryInfo {
  String id;
  String title;

  JmComicCategoryInfo(this.id, this.title);
}

class JmComicBrief extends BaseComic {
  List<JmComicCategoryInfo> categories;

  String get image => getJmCoverUrl(id); //cover封面

  bool get liked => false;

  bool get isFavorite => false;

  JmComicBrief(
      super.name, super.author, super.id, super.description, this.categories);
}
