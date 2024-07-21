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

  Future<Res<List<String>>> loadEp(int ep) async => await loadEpNetwork(ep);

  Future<Res<List<String>>> loadEpNetwork(int ep);

  ImageProvider createImageProvider(String ep, int page, String url) {
    // 在这里使用了StreamImageProvider，并通过传递streamBuilder参数达到内部方法调用
    return StreamImageProvider(() => loadImage(ep, page, url), '$id$ep$page');
  }

  Stream<DownloadProgress> loadImage(String ep, int page, String url) async* {
    // 这里应该实现一个从下载中获取的方法
    yield* loadImageNetwork(ep, page, url);
  }

  Stream<DownloadProgress> loadImageNetwork(String ep, int page, String url);
}
