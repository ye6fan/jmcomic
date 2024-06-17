import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/src/painting/image_provider.dart';
import 'package:flutter/src/painting/image_stream.dart';
import 'package:plagiarize/foundation/image_loader/base_image_provider.dart';
import 'package:plagiarize/foundation/image_loader/image_manager.dart';

class CachedImageProvider extends BaseImageProvider<CachedImageProvider> {
  final String url;
  final Map<String, String>? headers;

  CachedImageProvider(this.url, {this.headers});

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
    if (finishProgress!.data != null) return finishProgress.data!;
    return await finishProgress.getFile().readAsBytes();
  }

  @override
  Future<CachedImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture(this);
  }

  @override
  String get key => url;
}
