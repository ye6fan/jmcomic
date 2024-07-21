import 'package:jmcomic/views/comics_page.dart';

import '../../network/base_models.dart';
import '../../network/jm_network/jm_models.dart';
import '../../network/jm_network/jm_network.dart';

class JmLatestPage extends ComicsPage<JmComicBrief> {
  const JmLatestPage({super.key});

  @override
  String get tag => 'jm_latest_page';

  @override
  Future<Res<List<JmComicBrief>>> getComics(int i) {
    return JmNetwork().getLatest(i);
  }
}
