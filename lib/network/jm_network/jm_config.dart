import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';

import 'jm_network.dart';

// 这个类中的所有配置，我都不知道原作者是如何获取到的
class JmConfig {
  static var _device = '';

  static String get jmUA {
    if (_device.isEmpty) {
      var chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
      var random = Random();
      for (var i = 0; i < 9; i++) {
        _device += chars[random.nextInt(chars.length)];
      }
    }
    return 'Mozilla/5.0 (Linux; Android 13; $_device Build/TQ1A.230305.002; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/114.0.5735.196 Safari/537.36';
  }

  static const webUA =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36';

  static const _jmVersion = '1.7.2';

  static const _jmAuthKey = '18comicAPPContent';

  static const scrambleId = '220980';

  static const kJmSecret = '185Hcomic3PAPP7R';

  static const baseUrls = [
    'https://www.jmeadpoolcdn.one',
    'https://www.jmeadpoolcdn.life',
    'https://www.jmapiproxyxxx.one',
    'https://www.jmfreedomproxy.xyz'
  ];

  static const imagesUrls = [
    'https://cdn-msp.jmapiproxy3.cc',
    'https://cdn-msp3.jmapiproxy3.cc',
    'https://cdn-msp2.jmapiproxy1.cc',
    'https://cdn-msp3.jmapiproxy3.cc',
    'https://cdn-msp2.jmapiproxy4.cc',
    'https://cdn-msp2.jmapiproxy3.cc',
  ];

  static String getBaseUrl() {
    return imagesUrls[0];
  }

  static String getJmCoverUrl(String id) {
    return '${getBaseUrl()}/media/albums/${id}_3x4.jpg';
  }

  static String getJmImagesUrl(String id, String imageName) {
    return '${getBaseUrl()}/media/photos/$id/$imageName';
  }

  static BaseOptions getHeader(int time,
      {bool post = false, Map<String, String>? headers, bool byte = true}) {
    var token = md5.convert(utf8.encode('$time$_jmAuthKey'));
    return BaseOptions(
        receiveDataWhenStatusError: true,
        connectTimeout: const Duration(seconds: 8),
        responseType: byte ? ResponseType.bytes : null,
        headers: {
          'token': token.toString(),
          'tokenparam': '$time,$_jmVersion',
          'use-agent': jmUA,
          'accpet-encoding': 'gzip',
          'Host': JmNetwork().baseUrl.replaceFirst('https://', ''),
          ...headers ?? {},
          if (post) 'Content-Type': 'application/x-www-form-urlencoded',
        });
  }
}
