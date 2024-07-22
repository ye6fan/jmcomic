import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/cupertino.dart';

abstract class BaseImageProvider<T extends BaseImageProvider<T>>
    extends ImageProvider<T> {
  const BaseImageProvider();

  @override
  ImageStreamCompleter loadImage(T key, ImageDecoderCallback decode) {
    final chunkEvents = StreamController<ImageChunkEvent>();
    return MultiFrameImageStreamCompleter(
        codec: _loadBufferAsync(key, chunkEvents, decode),
        scale: 1.0,
        chunkEvents: chunkEvents.stream);
  }

  Future<Codec> _loadBufferAsync(
      T key,
      StreamController<ImageChunkEvent> chunkEvents,
      ImageDecoderCallback decode) async {
    int retryTime = 1;
    bool stop = false;
    chunkEvents.onCancel = () {
      stop = true;
    };
    Uint8List? data;
    try {
      while (data == null && !stop) {
        try {
          data = await load(chunkEvents);
        } catch (e) {
          retryTime <<= 1;
          if (retryTime > (1 << 5) || stop) rethrow;
          await Future.delayed(Duration(seconds: retryTime));
        }
      }

      final buffer = await ImmutableBuffer.fromUint8List(data!);
      return decode(buffer);
    } catch (e) {
      scheduleMicrotask(() {
        // evict驱逐
        PaintingBinding.instance.imageCache.evict(key);
      });
      rethrow;
    } finally {
      chunkEvents.close();
    }
  }

  Future<Uint8List> load(StreamController<ImageChunkEvent> chunkEvents);
  // 这个key是自己声明用来重用图片的
  String get key;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BaseImageProvider<T> && key == other.key;

  @override
  int get hashCode => key.hashCode;

  @override
  String toString() {
    return '$runtimeType($key)';
  }
}
