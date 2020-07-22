// import 'package:flutter/material.dart';

// class FirebaseVisionImageMetadata {
//   FirebaseVisionImageMetadata({
//     @required this.size,
//     @required this.rawFormat,
//     @required this.planeData,
//     this.rotation = ImageRotation.rotation0,
//   })  : assert(size != null),
//         assert(defaultTargetPlatform == TargetPlatform.iOS
//             ? rawFormat != null
//             : true),
//         assert(defaultTargetPlatform == TargetPlatform.iOS
//             ? planeData != null
//             : true),
//         assert(defaultTargetPlatform == TargetPlatform.iOS
//             ? planeData.isNotEmpty
//             : true);

//   /// Size of the image in pixels.
//   final Size size;

//   /// Rotation of the image for Android.
//   ///
//   /// Not currently used on iOS.
//   final ImageRotation rotation;

//   /// Raw version of the format from the iOS platform.
//   ///
//   /// Since iOS can use any planar format, this format will be used to create
//   /// the image buffer on iOS.
//   ///
//   /// On iOS, this is a `FourCharCode` constant from Pixel Format Identifiers.
//   /// See https://developer.apple.com/documentation/corevideo/1563591-pixel_format_identifiers?language=objc
//   ///
//   /// Not used on Android.
//   final dynamic rawFormat;

//   /// The plane attributes to create the image buffer on iOS.
//   ///
//   /// Not used on Android.
//   final List<FirebaseVisionImagePlaneMetadata> planeData;

//   int _imageRotationToInt(ImageRotation rotation) {
//     switch (rotation) {
//       case ImageRotation.rotation90:
//         return 90;
//       case ImageRotation.rotation180:
//         return 180;
//       case ImageRotation.rotation270:
//         return 270;
//       default:
//         assert(rotation == ImageRotation.rotation0);
//         return 0;
//     }
//   }

//   Map<String, dynamic> _serialize() => <String, dynamic>{
//         'width': size.width,
//         'height': size.height,
//         'rotation': _imageRotationToInt(rotation),
//         'rawFormat': rawFormat,
//         'planeData': planeData
//             .map((FirebaseVisionImagePlaneMetadata plane) => plane._serialize())
//             .toList(),
//       };
// }

// String _enumToString(dynamic enumValue) {
//   final String enumString = enumValue.toString();
//   return enumString.substring(enumString.indexOf('.') + 1);
// }
