import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as image;

int getSegmentationNum(String epId, String scrambleId, String bookId) {
  int scrambleID = int.parse(scrambleId);
  int epID = int.parse(epId);
  int num = 0;

  if (epID < scrambleID) {
    num = 0;
  } else if (epID < 268850) {
    num = 10;
  } else if (epID < 421927) {
    String key = epId + bookId;
    List<int> bytes = utf8.encode(key);
    String hash = md5.convert(bytes).toString();
    // 获取其最后一个字符的Unicode码点值
    int charCode = hash.codeUnitAt(hash.length - 1);
    int remainder = charCode % 10;
    num = remainder * 2 + 2;
  } else {
    String key = epId + bookId;
    List<int> bytes = utf8.encode(key);
    String hash = md5.convert(bytes).toString();
    int charCode = hash.codeUnitAt(hash.length - 1);
    int remainder = charCode % 8;
    num = remainder * 2 + 2;
  }

  return num;
}

Future<Uint8List> segmentationPicture(RecombinationData data) async {
  int num = getSegmentationNum(data.epId, data.scrambleId, data.bookId);

  if (num <= 1) {
    return data.imgData;
  }
  image.Image srcImg;
  try {
    srcImg = image.decodeImage(data.imgData)!;
  } catch (e) {
    rethrow;
  }
  // floor地板，向下取整；remainder余数
  int blockSize = (srcImg.height / num).floor();
  int remainder = srcImg.height % num;

  List<Map<String, int>> blocks = [];

  for (int i = 0; i < num; i++) {
    int start = i * blockSize;
    int end = start + blockSize + ((i != num - 1) ? 0 : remainder);
    blocks.add({'start': start, 'end': end});
  }

  image.Image desImg = image.Image(width: srcImg.width, height: srcImg.height);

  int y = 0;
  for (int i = blocks.length - 1; i >= 0; i--) {
    var block = blocks[i];
    int currBlockHeight = block['end']! - block['start']!;
    var range =
        srcImg.getRange(0, block['start']!, srcImg.width, currBlockHeight);
    var desRange = desImg.getRange(0, y, srcImg.width, currBlockHeight);
    while (range.moveNext() && desRange.moveNext()) {
      desRange.current.r = range.current.r;
      desRange.current.g = range.current.g;
      desRange.current.b = range.current.b;
      desRange.current.a = range.current.a;
    }
    y += currBlockHeight;
  }

  return image.encodeJpg(desImg);
}

class RecombinationData {
  Uint8List imgData;
  String epId;
  String scrambleId;
  String bookId;
  String? savePath;

  RecombinationData(this.imgData, this.epId, this.scrambleId, this.bookId,
      [this.savePath]);
}

Future<Uint8List> recombineImageAndWriteFile(RecombinationData data) async {
  // segmentation分割
  var bytes = await segmentationPicture(data);
  var file = File(data.savePath!);
  if (file.existsSync()) {
    file.deleteSync();
  }
  file.writeAsBytesSync(bytes);
  return bytes;
}

int loadingItems = 0;

final maxLoadingItems = Platform.isAndroid || Platform.isIOS ? 3 : 5;

Future<Uint8List> startRecombineAndWriteImage(Uint8List imgData, String epId,
    String scrambleId, String bookId, String savePath) async {
  while (loadingItems >= maxLoadingItems) {
    await Future.delayed(const Duration(milliseconds: 150));
  }
  loadingItems++;
  try {
    return await compute(recombineImageAndWriteFile,
        RecombinationData(imgData, epId, scrambleId, bookId, savePath));
  } catch (e) {
    rethrow;
  } finally {
    loadingItems--;
  }
}
