import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/src/adapters/io_adapter.dart';
import 'package:flutter/cupertino.dart';

import '../../app.dart';
import '../../network/jm_network/jm_config.dart';
import '../log_manager.dart';
import 'image_recombine.dart';

@immutable
class DownloadProgress {
  final int currentBytes;
  final int totalBytes;
  final String url;
  final String savePath;

  bool get finished => currentBytes == totalBytes;

  File getFile() => File(savePath);

  const DownloadProgress(
      this.currentBytes, this.totalBytes, this.url, this.savePath);
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

  static void createFolder() async {
    imageCachePath = '${App.cachePath}${App.separator}imageCache';
    var folder = Directory(imageCachePath);
    if (!folder.existsSync()) folder.createSync(recursive: true);
  }

  // 防止重复执行加载操作
  static Map<String, DownloadProgress> loadingItems = {};
  // 缓存已加载的图片路径
  static Map<String, DownloadProgress> loadedItems = {};

  static bool get hasTask => loadingItems.isNotEmpty;

  Stream<DownloadProgress> getImage(String url,
      [Map<String, String>? headers]) async* {
    if (loadedItems[url] != null) {
      yield loadedItems[url]!;
      return;
    }
    while (loadingItems[url] != null) {
      var progress = loadingItems[url]!;
      yield progress;
      if (progress.finished) return;
      await Future.delayed(const Duration(milliseconds: 520));
    }
    loadingItems[url] = DownloadProgress(0, 100, url, '');
    try {
      var fileName = md5.convert(utf8.encode(url)).toString().substring(0, 15);
      fileName = '$fileName.jpg';
      final savePath = '$imageCachePath${App.separator}$fileName';
      yield loadingItems[url]!;
      var dio = Dio();
      dio.httpClientAdapter = IOHttpClientAdapter();
      var res = await dio.get<ResponseBody>(url,
          options:
              Options(responseType: ResponseType.stream, headers: headers));
      if (res.data == null) throw Exception('Empty Data');
      int currentBytes = 0;
      int totalBytes = int.parse(res.data!.headers['Content-Length']![0]);
      var file = File(savePath);
      if (file.existsSync()) file.deleteSync();
      file.createSync();
      await for (var chunk in res.data!.stream) {
        currentBytes += chunk.length;
        file.writeAsBytesSync(chunk, mode: FileMode.append);
        var progress =
            DownloadProgress(currentBytes, totalBytes, url, savePath);
        yield progress;
        loadedItems[url] = progress;
      }
    } catch (e, s) {
      log('$e/$s', 'Network', LogLevel.error);
      rethrow;
    } finally {
      loadingItems.remove(url);
    }
  }

  Stream<DownloadProgress> getJmImage(String url,
      {required String ep,
      required String scrambleId,
      required String bookId}) async* {
    while (loadingItems[url] != null) {
      var progress = loadingItems[url]!;
      yield progress;
      if (progress.finished) {
        return;
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }
    loadingItems[url] = DownloadProgress(0, 100, url, '');
    try {
      var fileName = md5.convert(utf8.encode(url)).toString().substring(0, 15);
      int l;
      int r = url.length;
      for (l = url.length - 1; l >= 0; l--) {
        if (url[l] == '.') {
          break;
        }
        if (url[l] == '?') {
          r = l;
        }
      }
      fileName += url.substring(l, r);
      fileName = fileName.replaceAll(RegExp(r'\?.+'), '');
      final savePath = '$imageCachePath${App.separator}$fileName';
      yield loadingItems[url]!;
      var bytes = <int>[];
      try {
        var dio = Dio();
        dio.httpClientAdapter = IOHttpClientAdapter();
        // 不加<ResponseBody>泛型修饰无法获取到stream属性
        var res = await dio.get<ResponseBody>(url,
            options: Options(responseType: ResponseType.stream, headers: {
              'User-Agent': JmConfig.jmUA,
              'x-requested-with': 'com.jiaohua_browser',
              'referer': 'https://www.jmapibranch2.cc/'
            }));
        var stream = res.data!.stream;
        int i = 0;
        await for (var b in stream) {
          bytes.addAll(b.toList());
          i += 5;
          if (i > 90) {
            i = 90;
          }
          var progress = DownloadProgress(i, 100, url, savePath);
          yield progress;
          loadingItems[url] = progress;
        }
      } catch (e) {
        rethrow;
      }
      var progress = DownloadProgress(90, 100, url, savePath);
      yield progress;
      loadingItems[url] = progress;
      var file = File(savePath);
      if (!file.existsSync()) {
        file.create();
      }
      if (url.substring(l, r) != '.gif') {
        bytes = await startRecombineAndWriteImage(
            Uint8List.fromList(bytes), ep, scrambleId, bookId, savePath);
      } else {
        await File(savePath).writeAsBytes(bytes);
      }
      progress = DownloadProgress(1, 1, url, savePath);
      yield progress;
      loadedItems[url] = progress;
    } catch (e) {
      rethrow;
    } finally {
      await Future.delayed(const Duration(milliseconds: 100));
      loadingItems.remove(url);
    }
  }
}
