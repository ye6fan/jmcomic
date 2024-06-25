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
  String? get name => data?.name;

  @override
  void read() {
    // TODO: implement read
  }

  @override
  Map<String, List<String>> get labels => {
        'ID': [id],
        '作者': data!.author,
        '标签': data!.tags
      };
}
