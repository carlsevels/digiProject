class BarcodeResponse {
  String? name;
  List<BarcodeItem>? data;
  ImageInfoData? image;

  BarcodeResponse({
    this.name,
    this.data,
    this.image,
  });

  factory BarcodeResponse.fromJson(Map<String, dynamic> json) {
    return BarcodeResponse(
      name: json['name'],
      data: json['data'] != null
          ? (json['data'] as List)
              .map((v) => BarcodeItem.fromJson(v))
              .toList()
          : null,
      image: json['image'] != null ? ImageInfoData.fromJson(json['image']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'data': data?.map((v) => v.toJson()).toList(),
      'image': image?.toJson(),
    };
  }
}

class BarcodeItem {
  String? calendarEvent;
  String? contactInfo;
  List<CornerPoint>? corners;
  String? displayValue;
  String? driverLicense;
  String? email;
  int? format;
  String? geoPoint;
  String? phone;
  List<int>? rawBytes;
  String? rawValue;
  BarcodeSize? size;
  String? sms;
  int? type;
  String? url;
  String? wifi;

  BarcodeItem({
    this.calendarEvent,
    this.contactInfo,
    this.corners,
    this.displayValue,
    this.driverLicense,
    this.email,
    this.format,
    this.geoPoint,
    this.phone,
    this.rawBytes,
    this.rawValue,
    this.size,
    this.sms,
    this.type,
    this.url,
    this.wifi,
  });

  factory BarcodeItem.fromJson(Map<String, dynamic> json) {
    return BarcodeItem(
      calendarEvent: json['calendarEvent'],
      contactInfo: json['contactInfo'],
      corners: json['corners'] != null
          ? (json['corners'] as List)
              .map((v) => CornerPoint.fromJson(v))
              .toList()
          : null,
      displayValue: json['displayValue'],
      driverLicense: json['driverLicense'],
      email: json['email'],
      format: (json['format'] is String)
          ? int.tryParse(json['format'] ?? '')
          : json['format'],
      geoPoint: json['geoPoint'],
      phone: json['phone'],
      rawBytes: json['rawBytes'] != null
          ? List<int>.from(json['rawBytes'])
          : null,
      rawValue: json['rawValue'],
      size: json['size'] != null ? BarcodeSize.fromJson(json['size']) : null,
      sms: json['sms'],
      type: (json['type'] is String)
          ? int.tryParse(json['type'] ?? '')
          : json['type'],
      url: json['url'],
      wifi: json['wifi'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calendarEvent': calendarEvent,
      'contactInfo': contactInfo,
      'corners': corners?.map((v) => v.toJson()).toList(),
      'displayValue': displayValue,
      'driverLicense': driverLicense,
      'email': email,
      'format': format,
      'geoPoint': geoPoint,
      'phone': phone,
      'rawBytes': rawBytes,
      'rawValue': rawValue,
      'size': size?.toJson(),
      'sms': sms,
      'type': type,
      'url': url,
      'wifi': wifi,
    };
  }
}

class CornerPoint {
  double? x;
  double? y;

  CornerPoint({
    this.x,
    this.y,
  });

  factory CornerPoint.fromJson(Map<String, dynamic> json) {
    return CornerPoint(
      x: (json['x'] is int) ? (json['x'] as int).toDouble() : json['x'],
      y: (json['y'] is int) ? (json['y'] as int).toDouble() : json['y'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
    };
  }
}

class BarcodeSize {
  double? width;
  double? height;

  BarcodeSize({
    this.width,
    this.height,
  });

  factory BarcodeSize.fromJson(Map<String, dynamic> json) {
    return BarcodeSize(
      width: (json['width'] is int) ? (json['width'] as int).toDouble() : json['width'],
      height: (json['height'] is int) ? (json['height'] as int).toDouble() : json['height'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'width': width,
      'height': height,
    };
  }
}

class ImageInfoData {
  List<int>? bytes;
  double? width;
  double? height;

  ImageInfoData({
    this.bytes,
    this.width,
    this.height,
  });

  factory ImageInfoData.fromJson(Map<String, dynamic> json) {
    return ImageInfoData(
      bytes: json['bytes'] != null ? List<int>.from(json['bytes']) : null,
      width: (json['width'] is int) ? (json['width'] as int).toDouble() : json['width'],
      height: (json['height'] is int) ? (json['height'] as int).toDouble() : json['height'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bytes': bytes,
      'width': width,
      'height': height,
    };
  }
}