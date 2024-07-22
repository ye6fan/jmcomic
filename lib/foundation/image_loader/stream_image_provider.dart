import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/src/painting/image_provider.dart';
import 'package:flutter/src/painting/image_stream.dart';
import 'package:jmcomic/foundation/image_loader/base_image_provider.dart';

import 'image_manager.dart';

class StreamImageProvider extends BaseImageProvider<StreamImageProvider> {
  final String url;
  final Map<String, String>? headers;
  final Stream<DownloadProgress> Function() streamBuilder;

  StreamImageProvider(this.url, this.streamBuilder, {this.headers});

  @override
  String get key => url;

  @override
  Future<Uint8List> load(StreamController<ImageChunkEvent> chunkEvents) async {
    chunkEvents.add(const ImageChunkEvent(
        cumulativeBytesLoaded: 0, expectedTotalBytes: 100));
    DownloadProgress? finishProgress;
    await for (var progress in streamBuilder()) {
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
  Future<StreamImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture(this); // obtain获得，立即返回当前实例
  }
}
