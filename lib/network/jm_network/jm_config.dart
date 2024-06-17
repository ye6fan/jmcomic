import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:plagiarize/network/jm_network/jm_network.dart';

const _jmUA =
    'Mozilla/5.0 (Linux; Android 13; 012345678 Build/TQ1A.230305.002; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/114.0.5735.196 Safari/537.36';

const _jmVersion = '1.6.8';

const _jmAuthKey = '18comicAPPContent';

const kJmSecret = '185Hcomic3PAPP7R';

const String webUA =
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36";

const baseUrls = [
  'https://www.jmapinodeudzn.xyz',
  'https://www.jmapinode.vip',
  'https://www.jmapinode.biz',
  'https://www.jmapinode.xyz',
];

const imagesUrls = [
  'https://cdn-msp.jmapiproxy1.monster',
  'https://cdn-msp2.jmapiproxy3.cc',
  'https://cdn-msp.jmapiproxy2.cc',
  'https://cdn-msp2.jmapiproxy1.cc',
  'https://cdn-msp2.jmapiproxy4.cc',
  'https://cdn-msp.jmapiproxy3.cc',
];

String getImagesUrl() {
  return imagesUrls[0];
}

String getJmCoverUrl(String id) {
  return '${getImagesUrl()}/media/albums/${id}_3x4.jpg';
}

BaseOptions getHeader(int time,
    {bool post = false, Map<String, String>? headers, bool byte = true}) {
  var token = md5.convert(utf8.encode('$time$_jmAuthKey'));
  return BaseOptions(
      receiveDataWhenStatusError: true,
      connectTimeout: const Duration(seconds: 8),
      responseType: byte ? ResponseType.bytes : null,
      headers: {
        'token': token.toString(),
        'tokenparam': '$time,$_jmVersion',
        'use-agent': _jmUA,
        'accpet-encoding': 'gzip',
        'Host': JmNetwork().baseUrl.replaceFirst('https://', ''),
        ...headers ?? {},
        if (post) 'Content-Type': 'application/x-www-form-urlencoded',
      });
}
