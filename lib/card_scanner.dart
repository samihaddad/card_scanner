import 'dart:async';

import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:card_scanner/card_info.dart';
import 'package:card_scanner/card_number_validator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:card_scanner/card_extension.dart';

class CardScanner {
  static const _channel =
      const MethodChannel('plugins.samihaddad.dev/card_scanner');

  static Uint8List _concatenatePlanes(List<Plane> planes) {
    final WriteBuffer allBytes = WriteBuffer();
    planes.forEach((plane) => allBytes.putUint8List(plane.bytes));
    return allBytes.done().buffer.asUint8List();
  }

  // TODO: will be called on dispose
  static Future<void> close() {}

  static Future<CardInfo> processImage(CameraImage image, int rotation) async {
    final Map<String, dynamic> result = await _channel
        .invokeMapMethod<String, dynamic>('scanCard', <String, dynamic>{
      'bytes': _concatenatePlanes(image.planes),
      'width': image.width,
      'height': image.height,
      'rotation': rotation,
      'rawFormat': image.format.raw,
      'planeData': image.planes
          .map((p) => {
                'bytesPerRow': p.bytesPerRow,
                'height': p.height,
                'width': p.width,
              })
          .toList()
    });
    final String text = result['text'];
    var words = text.split('\n');
    CardInfo card = CardInfo();
    for (String word in words) {
      print(word);
      var validator = CardInfoValidator(word);
      if (validator.isValidCardNumber()) {
        card.cardNumber = validator.sanitized;
      } else if (validator.isValidExpiryDate()) {
        card.expiry = word;
      } else if (validator.isValidCardholderName()) {
        card.cardholderName = word;
      }
    }
    return card;
  }
}
