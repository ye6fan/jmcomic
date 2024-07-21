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
  String get name => data!.name;

  @override
  Map<String, List<String>> get labels => {
        'ID': [id],
        '作者': data!.author,
        '标签': data!.tags
      };

  @override
  EpsData? get epsData => EpsData(data!.epNames, (ep) async {
        MainPage.to(() => ComicReadPage.jmComic(
            data!.id, data!.name, data!.epIds, data!.epNames, ep + 1));
      });

  @override
  String get cover => JmConfig.getJmCoverUrl(id); // 此方法是为了寻找常量图片信息，不是重新网络请求

  @override
  void read() => readJmComic();

  void readJmComic() {
    // byd用它导航，无法返回
    /*AppController.globalTo(() => ComicReadPage.jmComic(
        data!.id, data!.name, data!.epIds, data!.epNames, 1));*/
    MainPage.to(() => ComicReadPage.jmComic(
        data!.id, data!.name, data!.epIds, data!.epNames, 1));
  }
}
