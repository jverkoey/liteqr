/**
 * Copyright 2009 Jeff Verkoeyen
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "DecoderController.h"

#import "OverlayView.h"
#import "QRImagePickerController.h"

#import "Decoder.h"


static const NSTimeInterval kTakePictureTimeInterval = 5;


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation DecoderController


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) dealloc {
  [_imagePicker release];
  _imagePicker = nil;
  [_overlayView release];
  _overlayView = nil;
  [_decoder release];
  _decoder = nil;

  [super dealloc];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) loadView {
  [super loadView];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) viewDidAppear:(BOOL)animated {
  if( nil != _imagePicker ) {
    return;
  }

  UIImagePickerControllerSourceType type = UIImagePickerControllerSourceTypeCamera;

  if( ![UIImagePickerController isSourceTypeAvailable:type] ) {
    UIAlertView* alertView = [[UIAlertView alloc]
          initWithTitle:@"Not a supported device"
                message:@"You need a camera to run this app"
               delegate:self
      cancelButtonTitle:@"Darn"
      otherButtonTitles:nil];

    [alertView show];

  } else {
    _imagePicker = [[QRImagePickerController alloc] init];

    _overlayView = [[OverlayView alloc] initWithFrame:[UIScreen mainScreen].bounds];

    _imagePicker.delegate = self;
    _imagePicker.allowsEditing = NO;
    _imagePicker.showsCameraControls = NO;
    _imagePicker.cameraOverlayView = _overlayView;

    [self presentModalViewController:_imagePicker animated:YES];

    _timer = [NSTimer
      scheduledTimerWithTimeInterval: kTakePictureTimeInterval
                              target: self
                            selector: @selector(takePicture:)
                            userInfo: nil
                             repeats: YES];
  }
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[self dismissModalViewControllerAnimated:YES];
}



////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIAlertViewDelegate


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  // Bail out.
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIImagePickerControllerDelegate


////////////////////////////////////////////////////////////////////////////////////////////////////
- (UIImage*) scaledImage:(UIImage*)baseImage {
	CGSize targetSize = CGSizeMake(320, 480);	
	CGRect scaledRect = CGRectZero;

	CGFloat scaledX = 480 * baseImage.size.width / baseImage.size.height;
	CGFloat offsetX = (scaledX - 320) / -2;

	scaledRect.origin = CGPointMake(0, 0.0);
	scaledRect.size.width  = scaledX;
	scaledRect.size.height = 480;

	UIGraphicsBeginImageContext(targetSize);	
	[baseImage drawInRect:scaledRect];
	UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

  return result;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) imagePickerController:(UIImagePickerController*)picker 
         didFinishPickingMediaWithInfo:(NSDictionary*)info {
  UIImage* image = [info objectForKey:UIImagePickerControllerOriginalImage];

  UIImage* scaled = [self scaledImage:image];

  _overlayView.image = scaled;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) imagePickerController: (UIImagePickerController*)picker
         didFinishPickingImage: (UIImage*)image
                   editingInfo: (NSDictionary*)editingInfo {
  NSLog(@"hi");
/*
  UIImage *imageToDecode = image;
	CGSize size = [image size];
	CGRect cropRect = CGRectMake(0.0, 0.0, size.width, size.height);
	
#ifdef DEBUG
  NSLog(@"picked image size = (%f, %f)", size.width, size.height);
#endif
  NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
  
  if (editingInfo) {
    UIImage *originalImage = [editingInfo objectForKey:UIImagePickerControllerOriginalImage];
    if (originalImage) {
#ifdef DEBUG
      NSLog(@"original image size = (%f, %f)", originalImage.size.width, originalImage.size.height);
#endif
      NSValue *cropRectValue = [editingInfo objectForKey:UIImagePickerControllerCropRect];
      if (cropRectValue) {
        cropRect = [cropRectValue CGRectValue];
#ifdef DEBUG
        NSLog(@"crop rect = (%f, %f) x (%f, %f)", CGRectGetMinX(cropRect), CGRectGetMinY(cropRect), CGRectGetWidth(cropRect), CGRectGetHeight(cropRect));
#endif
        if (([picker sourceType] == UIImagePickerControllerSourceTypeSavedPhotosAlbum) &&
						[@"2.1" isEqualToString:systemVersion]) {
          // adjust crop rect to work around bug in iPhone OS 2.1 when selecting from the photo roll
          cropRect.origin.x *= 2.5;
          cropRect.origin.y *= 2.5;
          cropRect.size.width *= 2.5;
          cropRect.size.height *= 2.5;
#ifdef DEBUG
          NSLog(@"2.1-adjusted crop rect = (%f, %f) x (%f, %f)", CGRectGetMinX(cropRect), CGRectGetMinY(cropRect), CGRectGetWidth(cropRect), CGRectGetHeight(cropRect));
#endif
        }
				
				imageToDecode = originalImage;
      }
    }
  }
  
  [[picker parentViewController] dismissModalViewControllerAnimated:YES];
  [imageToDecode retain];
  [picker release];
  [self.decoder decodeImage:imageToDecode cropRect:cropRect];
  [imageToDecode release];
  [self updateToolbar];*/
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSTimer


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)takePicture:(NSTimer*)theTimer {
  [_imagePicker takePicture];
}



////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark DecoderDelegate


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)decoder:(Decoder *)decoder willDecodeImage:(UIImage *)image usingSubset:(UIImage *)subset {
  NSLog(@"willDecodeImage");
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)decoder:(Decoder *)decoder decodingImage:(UIImage *)image usingSubset:(UIImage *)subset progress:(NSString *)message {
  NSLog(@"decodingImage %@", message);
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)decoder:(Decoder *)decoder didDecodeImage:(UIImage *)image usingSubset:(UIImage *)subset withResult:(TwoDDecoderResult *)result {
  NSLog(@"didDecodeImage");
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)decoder:(Decoder *)decoder failedToDecodeImage:(UIImage *)image usingSubset:(UIImage *)subset reason:(NSString *)reason {
  NSLog(@"failedToDecodeImage %@", reason);
}




@end

