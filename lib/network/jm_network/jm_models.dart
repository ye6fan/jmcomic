import 'package:plagiarize/network/jm_network/jm_config.dart';

class JmComicCategoryInfo {
  String id;
  String title;

  JmComicCategoryInfo(this.id, this.title);
}

class JmComicBrief {
  String name;
  String author;
  String id;
  String description;
  List<JmComicCategoryInfo> categories;

  String get image => getJmCoverUrl(id); // cover封面

  bool get liked => false;

  bool get isFavorite => false;

  JmComicBrief(
      this.name, this.author, this.id, this.description, this.categories);
}

class JmComicInfo {
  String id;
  String name;
  List<String> author;
  String description;
  Map<int, String> series;
  List<String> epNames;
  List<String> tags;
  bool liked;
  bool is_favorite;

  JmComicInfo(this.id, this.name, this.author, this.description, this.series,
      this.epNames, this.tags, this.liked, this.is_favorite);
}
