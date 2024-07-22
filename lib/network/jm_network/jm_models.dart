import 'package:jmcomic/foundation/image_loader/image_manager.dart';

import '../base_models.dart';
import 'jm_config.dart';
import 'jm_network.dart';

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

  String get imageUrl => JmConfig.getJmCoverUrl(id);

  bool get liked => false;

  bool get isFavorite => false;

  JmComicBrief(
      this.name, this.author, this.id, this.description, this.categories);
}

class JmComicInfo {
  String id;
  String name;
  String totalViews; // 总的浏览量
  String likes; // 喜欢的人数
  List<String> author;
  String description;
  List<String> epIds;
  List<String> epNames;
  List<String> tags;
  bool liked;
  bool isFavorite;

  JmComicInfo(
      this.id,
      this.name,
      this.totalViews,
      this.likes,
      this.author,
      this.description,
      this.epIds,
      this.epNames,
      this.tags,
      this.liked,
      this.isFavorite);
}

class JmReadData extends ReadData {
  @override
  String id;

  @override
  String name;

  @override
  List<String> epIds;

  @override
  List<String> epNames;

  JmReadData(this.id, this.name, this.epIds, this.epNames);

  @override
  Future<Res<List<String>>> loadEpNetwork(int epIndex) {
    return JmNetwork().getChapter(epIds.elementAtOrNull(epIndex - 1) ?? id);
  }

  @override
  Stream<DownloadProgress> loadImageNetwork(String epId, int page, String url) {
    var l = url.lastIndexOf('/');
    var r = url.lastIndexOf('.');
    var bookId = url.substring(l + 1, r);
    var index = int.parse(epId);
    return ImageManager().getJmImage(url,
        epId: epIds.elementAtOrNull(index - 1) ?? id,
        scrambleId: JmConfig.scrambleId,
        bookId: bookId);
  }
}
