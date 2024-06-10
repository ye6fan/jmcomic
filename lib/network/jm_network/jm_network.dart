import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:plagiarize/network/jm_network/jm_config.dart';
import 'package:plagiarize/network/jm_network/jm_models.dart';
import 'package:pointycastle/export.dart';

import '../res.dart';

class JmNetwork {
  static JmNetwork? cache;

  JmNetwork._create();

  factory JmNetwork() => cache == null ? (cache = JmNetwork._create()) : cache!;

  String get baseUrl => baseUrls[0];

  String convertData(String input, int time) {
    var key = md5.convert(utf8.encode('$time$kJmSecret'));
    BlockCipher cipher = ECBBlockCipher(AESEngine())
      ..init(false, KeyParameter(utf8.encode(key.toString())));
    final data = base64Decode(input);
    int offset = 0;
    var paddedPlainText = Uint8List(data.length);
    while (offset < data.length) {
      offset += cipher.processBlock(data, offset, paddedPlainText, offset);
    }
    var res = utf8.decode(paddedPlainText);
    int i = res.length - 1;
    for (; i >= 0; i--) {
      if (res[i] == '}' || res[i] == ']') break;
    }
    return res.substring(0, i + 1);
  }

  Future<Res<dynamic>> get(String url, {Map<String, String>? header}) async {
    int time = DateTime.now().microsecondsSinceEpoch ~/ 1000;
    var options = getHeader(time);
    var dio = Dio(options);
    var res = await dio.get(url);
    var body = utf8.decode(res.data);
    var json = jsonDecode(body);
    var data = json['data'];
    var decodeData = convertData(data, time);
    return Res<dynamic>(const JsonDecoder().convert(decodeData));
  }

  Future<Res<List<JmComicBrief>>> getLatest(int page) async {
    try {
      var res = await get('$baseUrl/latest?&page=$page');
      var comics = <JmComicBrief>[];
      for (var comic in (res.data)) {
        var categories = <JmComicCategoryInfo>[];
        if (comic['category']['id'] != null &&
            comic['category']['title'] != null) {
          categories.add(JmComicCategoryInfo(
              comic['category']['id'], comic['category']['title']));
        }
        if (comic['category_sub']['id'] != null &&
            comic['category_sub']['title'] != null) {
          categories.add(JmComicCategoryInfo(
              comic['category_sub']['id'], comic['category_sub']['title']));
        }
        comics.add(JmComicBrief(comic['name'], comic['author'], comic['id'],
            comic['description'] ?? '', categories));
      }
      return Res(comics);
    } catch (e) {
      return Res(null, errorMessage: e.toString());
    }
  }
}
