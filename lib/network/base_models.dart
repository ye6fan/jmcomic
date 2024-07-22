import 'package:flutter/cupertino.dart';

import '../foundation/image_loader/image_manager.dart';
import '../foundation/image_loader/stream_image_provider.dart';

@immutable
class Res<T> {
  final T? data;
  final String? errorMessage;

  @override
  String toString() => data.toString();

  const Res(this.data, [this.errorMessage]);
}

abstract class ReadData {
  String get id;

  String get name;

  List<String> get epIds;

  List<String> get epNames;

  Future<Res<List<String>>> loadEp(int epIndex) async {
    // 这里应该实现一个从下载中获取的方法
    return await loadEpNetwork(epIndex);
  }

  Future<Res<List<String>>> loadEpNetwork(int epIndex);

  Stream<DownloadProgress> loadImage(String epId, int page, String url) async* {
    // 这里应该实现一个从下载中获取的方法
    yield* loadImageNetwork(epId, page, url);
  }

  Stream<DownloadProgress> loadImageNetwork(String epId, int page, String url);

  ImageProvider createImageProvider(String epId, int page, String url) {
    return StreamImageProvider(url, () => loadImage(epId, page, url));
  }
}
