import 'package:jmcomic/views/comic_page.dart';
import 'package:jmcomic/views/comic_read_page.dart';
import 'package:jmcomic/views/main_page.dart';

import '../../network/base_models.dart';
import '../../network/jm_network/jm_config.dart';
import '../../network/jm_network/jm_models.dart';
import '../../network/jm_network/jm_network.dart';

class JmComicPage extends ComicPage<JmComicInfo> {
  final String id;

  const JmComicPage(this.id, {super.key});

  @override
  String get tag => 'jm_comic_page';

  @override
  Future<Res<JmComicInfo>> loadComicInfo() => JmNetwork().getComicInfo(id);

  @override
  String get name => data.name;

  @override
  Map<String, List<String>> get labels => {
        'ID': [id],
        '作者': data.author,
        '标签': data.tags
      };

  @override
  EpsData? get epsData => EpsData(data.epNames, (index) async {
        MainPage.to(() => ComicReadPage.jmComic(
            data.id, data.name, data.epIds, data.epNames, index + 1));
      });

  @override
  String get coverUrl => JmConfig.getJmCoverUrl(id);

  @override
  void read() => readJmComic();

  void readJmComic() {
    MainPage.to(() =>
        ComicReadPage.jmComic(data.id, data.name, data.epIds, data.epNames, 1));
  }
}
