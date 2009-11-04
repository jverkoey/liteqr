//
//  Decoder.m
//  ZXing
//
//  Created by Christian Brunschen on 31/03/2008.
//
/*
 * Copyright 2008 ZXing authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "Decoder.h"
#import "TwoDDecoderResult.h"

#include "QRCodeReader.h"
#include "ReaderException.h"
#include "IllegalArgumentException.h"
#include "GrayBytesMonochromeBitmapSource.h"

using namespace qrcode;

@implementation Decoder

@synthesize image;
@synthesize cropRect;
@synthesize subsetImage;
@synthesize subsetData;
@synthesize subsetWidth;
@synthesize subsetHeight;
@synthesize subsetBytesPerRow;
@synthesize delegate;

- (void)willDecodeImage {
  [self.delegate decoder:self willDecodeImage:self.image usingSubset:self.subsetImage];
}

- (void)progressDecodingImage:(NSString *)progress {
  [self.delegate decoder:self 
          decodingImage:self.image 
            usingSubset:self.subsetImage
               progress:progress];
}

- (void)didDecodeImage:(TwoDDecoderResult *)result {
  [self.delegate decoder:self didDecodeImage:self.image usingSubset:self.subsetImage withResult:result];
}

- (void)failedToDecodeImage:(NSString *)reason {
  [self.delegate decoder:self failedToDecodeImage:self.image usingSubset:self.subsetImage reason:reason];
}

#define SUBSET_SIZE 320.0
- (void) prepareSubset {
  CGSize size = [image size];

  float scale = fminf(1.0f, fmaxf(SUBSET_SIZE / cropRect.size.width, SUBSET_SIZE / cropRect.size.height));
	CGPoint offset = CGPointMake(-cropRect.origin.x, -cropRect.origin.y);

  subsetWidth = cropRect.size.width * scale;
  subsetHeight = cropRect.size.height * scale;
  
  subsetBytesPerRow = ((subsetWidth + 0xf) >> 4) << 4;
  subsetData = (unsigned char *)malloc(subsetBytesPerRow * subsetHeight);
  
  CGColorSpaceRef grayColorSpace = CGColorSpaceCreateDeviceGray();
  
  CGContextRef ctx = 
  CGBitmapContextCreate(subsetData, subsetWidth, subsetHeight, 
                        8, subsetBytesPerRow, grayColorSpace, 
                        kCGImageAlphaNone);
  CGColorSpaceRelease(grayColorSpace);
  CGContextSetInterpolationQuality(ctx, kCGInterpolationNone);
  CGContextSetAllowsAntialiasing(ctx, false);
	// adjust the coordinate system
	CGContextTranslateCTM(ctx, 0.0, subsetHeight);
	CGContextScaleCTM(ctx, 1.0, -1.0);	

	UIGraphicsPushContext(ctx);
	CGRect rect = CGRectMake(offset.x * scale, offset.y * scale, scale * size.width, scale * size.height);
	[image drawInRect:rect];
	UIGraphicsPopContext();
  
  CGContextFlush(ctx);
    
  CGImageRef subsetImageRef = CGBitmapContextCreateImage(ctx);

  self.subsetImage = [UIImage imageWithCGImage:subsetImageRef];
  CGImageRelease(subsetImageRef);
  
  CGContextRelease(ctx);
}  

- (void)decode:(id)arg {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  { 
    QRCodeReader reader;

    Ref<MonochromeBitmapSource> grayImage
    (new GrayBytesMonochromeBitmapSource(subsetData, subsetWidth, subsetHeight, subsetBytesPerRow));
    
    TwoDDecoderResult *decoderResult = nil;
    
#ifdef TRY_ROTATIONS
    for (int i = 0; !decoderResult && i < 4; i++) {
#endif

    try {
      Ref<Result> result(reader.decode(grayImage));
      
      Ref<String> resultText(result->getText());
      const char *cString = resultText->getText().c_str();
      ArrayRef<Ref<ResultPoint> > resultPoints = result->getResultPoints();
      NSMutableArray *points = 
        [NSMutableArray arrayWithCapacity:resultPoints->size()];
      
      for (size_t i = 0; i < resultPoints->size(); i++) {
        Ref<ResultPoint> rp(resultPoints[i]);
        CGPoint p = CGPointMake(rp->getX(), rp->getY());
        [points addObject:[NSValue valueWithCGPoint:p]];
      }
      
      NSString *resultString = [NSString stringWithCString:cString
                                        encoding:NSUTF8StringEncoding];
      
      decoderResult = [TwoDDecoderResult resultWithText:resultString
                                             points:points];
    } catch (ReaderException rex) {
      NSLog(@"failed to decode, caught ReaderException '%s'",
            rex.what());
    } catch (IllegalArgumentException iex) {
      NSLog(@"failed to decode, caught IllegalArgumentException '%s'", 
            iex.what());
    } catch (...) {
      NSLog(@"Caught unknown exception!");
    }

#ifdef TRY_ROTATIONS
      if (!decoderResult) {
        grayImage = grayImage->rotateCounterClockwise();
      }
    }
#endif
    
    if (decoderResult) {
      [self performSelectorOnMainThread:@selector(didDecodeImage:)
                             withObject:decoderResult
                          waitUntilDone:NO];
    } else {
      [self performSelectorOnMainThread:@selector(failedToDecodeImage:)
                             withObject:NSLocalizedString(@"Decoder BarcodeDetectionFailure", @"No barcode detected.")
                          waitUntilDone:NO];
    }

    free(subsetData);
    self.subsetData = NULL;
  }
  [pool release];
  
  // if this is not the main thread, then we end it
  if (![NSThread isMainThread]) {
    [NSThread exit];
  }
}

- (void) decodeImage:(UIImage *)i {
  [self decodeImage:i cropRect:CGRectMake(0.0f, 0.0f, image.size.width, image.size.height)];
}

- (void) decodeImage:(UIImage *)i cropRect:(CGRect)cr {
	self.image = i;
	self.cropRect = cr;
  
  [self prepareSubset];
	[self.delegate decoder:self willDecodeImage:i usingSubset:self.subsetImage];

  
  [self performSelectorOnMainThread:@selector(progressDecodingImage:)
                         withObject:NSLocalizedString(@"Decoder MessageWhileDecoding", @"Decoding ...")
                      waitUntilDone:NO];  
  
	[NSThread detachNewThreadSelector:@selector(decode:) 
                           toTarget:self 
                         withObject:nil];
}

- (void) dealloc {
	[image release];
  [subsetImage release];
  if (subsetData) free(subsetData);
	[super dealloc];
}

@end
