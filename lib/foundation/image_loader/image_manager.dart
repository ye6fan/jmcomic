import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:plagiarize/foundation/app.dart';

import '../log.dart';

@immutable
class DownloadProgress {
  final int currentBytes;
  final int totalBytes;
  final String url;
  final String savePath;
  final Uint8List? data;

  bool get finished => currentBytes == totalBytes;

  File getFile() => File(savePath);

  const DownloadProgress(
      this.currentBytes, this.totalBytes, this.url, this.savePath,
      [this.data]);
}

class ImageManager {
  static ImageManager? cache;

  ImageManager._create();

  factory ImageManager() {
    createFolder();
    return cache ?? (cache = ImageManager._create());
  }

  // static需要在late前面，静态方法没有对象，访问的数据也要是静态
  // final修饰的必须在构造函数中，但是用late就可以不用了
  static late final String imageCachePath;
  final dio = Dio();

  static void createFolder() async {
    imageCachePath = '${App.cachePath}${App.separator}imageCache';
    var folder = Directory(imageCachePath);
    if (!folder.existsSync()) folder.createSync(recursive: true);
  }

  static Map<String, DownloadProgress> loadingItems = {};

  Stream<DownloadProgress> getImage(String url,
      [Map<String, String>? headers]) async* {
    while (loadingItems[url] != null) {
      var progress = loadingItems[url]!;
      yield progress;
      if (progress.finished) return;
      await Future.delayed(const Duration(milliseconds: 520));
    }
    loadingItems[url] = DownloadProgress(0, 100, url, '');
    try {
      var fileName = md5.convert(utf8.encode(url)).toString().substring(0, 10);
      fileName = '$fileName.jpg';
      final savePath = '$imageCachePath${App.separator}$fileName';
      yield loadingItems[url]!;
      var res = await dio.get<ResponseBody>(url,
          options:
              Options(responseType: ResponseType.stream, headers: headers));
      if (res.data == null) throw Exception('Empty Data');
      List<int> imageData = [];
      int totalBytes = int.parse(res.data!.headers['Content-Length']![0]);
      var file = File(savePath);
      if (file.existsSync()) file.deleteSync();
      file.createSync();
      await for (var chunk in res.data!.stream) {
        imageData.addAll(chunk);
        file.writeAsBytesSync(chunk, mode: FileMode.append);
        var progress =
            DownloadProgress(imageData.length, totalBytes, url, savePath);
        yield progress;
        loadingItems[url] = progress;
      }
    } catch (e, s) {
      log('$e/$s', 'Network', LogLevel.error);
      rethrow;
    } finally {
      loadingItems.remove(url);
    }
  }
}
