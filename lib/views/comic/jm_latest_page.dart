import 'package:plagiarize/network/jm_network/jm_models.dart';
import 'package:plagiarize/views/comics_page.dart';

import '../../network/jm_network/jm_network.dart';
import '../../network/res.dart';

class JmLatestPage extends ComicsPage<JmComicBrief> {
  const JmLatestPage({super.key});

  @override
  String? get tag => 'jm_latest_page';

  @override
  Future<Res<List<JmComicBrief>>> getComics(int i) {
    return JmNetwork().getLatest(i);
  }
}
