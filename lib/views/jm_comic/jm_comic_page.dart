import 'package:plagiarize/network/jm_network/jm_config.dart';
import 'package:plagiarize/network/jm_network/jm_network.dart';
import 'package:plagiarize/network/res.dart';
import 'package:plagiarize/views/comic_page.dart';

import '../../network/jm_network/jm_models.dart';

class JmComicPage extends ComicPage<JmComicInfo> {
  final String id;

  const JmComicPage(this.id, {super.key});

  @override
  String get tag => 'jm_comic_page';

  @override
  Future<Res<JmComicInfo>> loadData() => JmNetwork().getComicInfo(id);

  @override
  String get name => data!.name;

  @override
  Map<String, List<String>> get labels => {
        'ID': [id],
        '作者': data!.author,
        '标签': data!.tags
      };

  @override
  EpsData? get epsData => EpsData(data!.epNames, (i) {});

  @override
  String get cover => getJmCoverUrl(id); // 此方法是为了寻找常量图片信息，不是重新网络请求

  @override
  void read() {}
}
