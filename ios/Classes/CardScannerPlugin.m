#import "CardScannerPlugin.h"


@implementation CardScannerPlugin

MLKTextRecognizer *textRecognizer;

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"plugins.samihaddad.dev/card_scanner"
                                     binaryMessenger:[registrar messenger]];
    CardScannerPlugin* instance = [[CardScannerPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
    textRecognizer = [MLKTextRecognizer textRecognizer];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"scanCard" isEqualToString:call.method]) {
        [self handleDetection:call result:result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)handleDetection:(FlutterMethodCall *)call result:(FlutterResult)result {
    UIImage *image = [self bytesToImage:call.arguments];
    MLKVisionImage *visionImage = [[MLKVisionImage alloc] initWithImage:image];
    visionImage.orientation = image.imageOrientation;
    
//    MLKTextRecognizer *textRecognizer = [MLKTextRecognizer textRecognizer];

    [textRecognizer processImage:visionImage
                      completion:^(MLKText *_Nullable visionText,
                                   NSError *_Nullable error) {
      if (error != nil || result == nil) {
        // Error handling
        result(@{@"text" : @""});
          //return
      }
      result(@{@"text" : visionText.text});
    }];

}


- (UIImage *)bytesToImage:(NSDictionary *)imageData {
    FlutterStandardTypedData *byteData = imageData[@"bytes"];
    NSData *imageBytes = byteData.data;
    
    NSArray *planeData = imageData[@"planeData"];
    size_t planeCount = planeData.count;
    
    NSNumber *width = imageData[@"width"];
    NSNumber *height = imageData[@"height"];
    
    NSNumber *rawFormat = imageData[@"rawFormat"];
    FourCharCode format = FOUR_CHAR_CODE(rawFormat.unsignedIntValue);
    
    CVPixelBufferRef pxBuffer = NULL;
    if (planeCount == 0) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"Can't create image buffer with 0 planes."
                                     userInfo:nil];
    } else if (planeCount == 1) {
        NSDictionary *plane = planeData[0];
        NSNumber *bytesPerRow = plane[@"bytesPerRow"];
        
        pxBuffer = [self bytesToPixelBuffer:width.unsignedLongValue
                                     height:height.unsignedLongValue
                                     format:format
                                baseAddress:(void *)imageBytes.bytes
                                bytesPerRow:bytesPerRow.unsignedLongValue];
    } else {
        pxBuffer = [self planarBytesToPixelBuffer:width.unsignedLongValue
                                           height:height.unsignedLongValue
                                           format:format
                                      baseAddress:(void *)imageBytes.bytes
                                         dataSize:imageBytes.length
                                       planeCount:planeCount
                                        planeData:planeData];
    }
    
    return [self pixelBufferToImage:pxBuffer];
}

- (CVPixelBufferRef)bytesToPixelBuffer:(size_t)width
                                height:(size_t)height
                                format:(FourCharCode)format
                           baseAddress:(void *)baseAddress
                           bytesPerRow:(size_t)bytesPerRow {
  CVPixelBufferRef pxBuffer = NULL;
  CVPixelBufferCreateWithBytes(kCFAllocatorDefault, width, height, format, baseAddress, bytesPerRow,
                               NULL, NULL, NULL, &pxBuffer);
  return pxBuffer;
}

- (CVPixelBufferRef)planarBytesToPixelBuffer:(size_t)width
                                      height:(size_t)height
                                      format:(FourCharCode)format
                                 baseAddress:(void *)baseAddress
                                    dataSize:(size_t)dataSize
                                  planeCount:(size_t)planeCount
                                   planeData:(NSArray *)planeData {
  size_t widths[planeCount];
  size_t heights[planeCount];
  size_t bytesPerRows[planeCount];

  void *baseAddresses[planeCount];
  baseAddresses[0] = baseAddress;

  size_t lastAddressIndex = 0;  // Used to get base address for each plane
  for (int i = 0; i < planeCount; i++) {
    NSDictionary *plane = planeData[i];

    NSNumber *width = plane[@"width"];
    NSNumber *height = plane[@"height"];
    NSNumber *bytesPerRow = plane[@"bytesPerRow"];

    widths[i] = width.unsignedLongValue;
    heights[i] = height.unsignedLongValue;
    bytesPerRows[i] = bytesPerRow.unsignedLongValue;

    if (i > 0) {
      size_t addressIndex = lastAddressIndex + heights[i - 1] * bytesPerRows[i - 1];
      baseAddresses[i] = baseAddress + addressIndex;
      lastAddressIndex = addressIndex;
    }
  }

  CVPixelBufferRef pxBuffer = NULL;
  CVPixelBufferCreateWithPlanarBytes(kCFAllocatorDefault, width, height, format, NULL, dataSize,
                                     planeCount, baseAddresses, widths, heights, bytesPerRows, NULL,
                                     NULL, NULL, &pxBuffer);

  return pxBuffer;
}


- (UIImage *)pixelBufferToImage:(CVPixelBufferRef)pixelBufferRef {
  CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pixelBufferRef];

  CIContext *temporaryContext = [CIContext contextWithOptions:nil];
  CGImageRef videoImage =
      [temporaryContext createCGImage:ciImage
                             fromRect:CGRectMake(0, 0, CVPixelBufferGetWidth(pixelBufferRef),
                                                 CVPixelBufferGetHeight(pixelBufferRef))];

  return [UIImage imageWithCGImage:videoImage];
}

@end
