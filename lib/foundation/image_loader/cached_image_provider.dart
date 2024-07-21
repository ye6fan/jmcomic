import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/src/painting/image_provider.dart';
import 'package:flutter/src/painting/image_stream.dart';
import 'package:jmcomic/foundation/image_loader/base_image_provider.dart';
import 'package:jmcomic/foundation/image_loader/image_manager.dart';

class CachedImageProvider extends BaseImageProvider<CachedImageProvider> {
  final String url;
  final Map<String, String>? headers;

  // 感觉声不声明常量差不多，唉，毕竟‘有性能’优化就声明吧
  const CachedImageProvider(this.url, {this.headers});

  @override
  Future<Uint8List> load(StreamController<ImageChunkEvent> chunkEvents) async {
    chunkEvents.add(const ImageChunkEvent(
        cumulativeBytesLoaded: 0, expectedTotalBytes: 100));
    var manager = ImageManager();
    DownloadProgress? finishProgress;
    var stream = manager.getImage(url, headers);
    await for (var progress in stream) {
      if (progress.currentBytes == progress.totalBytes) {
        finishProgress = progress;
      }
      chunkEvents.add(ImageChunkEvent(
          cumulativeBytesLoaded: progress.currentBytes,
          expectedTotalBytes: progress.totalBytes));
    }
    return await finishProgress!.getFile().readAsBytes();
  }

  @override
  Future<CachedImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture(this);
  }

  // 缓存就在这里设置的
  @override
  String get key => url;
}
