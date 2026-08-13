import 'package:flutter/foundation.dart';

class BarcodeResponse {
  final String? name;
  final List<BarcodeItem>? data;
  final ImageInfoData? image;

  BarcodeResponse({
    this.name,
    this.data,
    this.image,
  });
}

class BarcodeItem {
  final String? displayValue;
  final String? rawValue;
  final int? format;
  final int? type;
  final Uint8List? rawBytes;
  final List<CornerPoint>? corners;
  final BarcodeSize? size;

  BarcodeItem({
    this.displayValue,
    this.rawValue,
    this.format,
    this.type,
    this.rawBytes,
    this.corners,
    this.size,
  });
}

class CornerPoint {
  final double x;
  final double y;

  CornerPoint({
    required this.x,
    required this.y,
  });
}

class BarcodeSize {
  final double width;
  final double height;

  BarcodeSize({
    required this.width,
    required this.height,
  });
}

class ImageInfoData {
  final Uint8List bytes;
  final double width;
  final double height;

  ImageInfoData({
    required this.bytes,
    required this.width,
    required this.height,
  });
}