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
  Future<Res<List<String>>> loadEpNetwork(int ep) {
    var res = JmNetwork().getChapter(epIds.elementAtOrNull(ep - 1) ?? id);
    return res;
  }

  // 这里也有很多要处理的细节问题，再说
  @override
  Stream<DownloadProgress> loadImageNetwork(String ep, int page, String url) {
    var bookId = '';
    for (int i = url.length - 1; i >= 0; i--) {
      if (url[i] == '/') {
        bookId = url.substring(i + 1, url.length - 5);
        break;
      }
    }
    var index = int.parse(ep);
    return ImageManager().getJmImage(url,
        ep: epIds.elementAtOrNull(index - 1) ?? id,
        scrambleId: JmConfig.scrambleId,
        bookId: bookId);
  }
}
