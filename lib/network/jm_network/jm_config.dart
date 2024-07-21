import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';

import 'jm_network.dart';

class JmConfig {
  static const jmUA =
      'Mozilla/5.0 (Linux; Android 13; 012345678 Build/TQ1A.230305.002; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/114.0.5735.196 Safari/537.36';

  static const String webUA =
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36";

  static const jmImgUA =
      'Mozilla/5.0 (Linux; Android 13; WD5DDE5 Build/TQ1A.230205.002; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/114.0.5735.196 Safari/537.36';

  static const _jmVersion = '1.7.0';

  static const _jmAuthKey = '18comicAPPContent';

  static const scrambleId = '220980';

  static const kJmSecret = '185Hcomic3PAPP7R';

  static const baseUrls = [
    'https://www.jmapinodeudzn.xyz',
    'https://www.jmapinode.vip',
    'https://www.jmapinode.biz',
    'https://www.jmapinode.xyz',
  ];

  static const imagesUrls = [
    'https://cdn-msp.jmapiproxy1.monster',
    'https://cdn-msp2.jmapiproxy3.cc',
    'https://cdn-msp.jmapiproxy2.cc',
    'https://cdn-msp2.jmapiproxy1.cc',
    'https://cdn-msp2.jmapiproxy4.cc',
    'https://cdn-msp.jmapiproxy3.cc',
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
