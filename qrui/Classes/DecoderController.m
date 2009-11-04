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
#import "TwoDDecoderResult.h"


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
- (UIImage*) croppedImage:(UIImage*)baseImage {
	CGSize targetSize = _overlayView.cropRect.size;	

	UIGraphicsBeginImageContext(targetSize);
	[baseImage drawAtPoint:CGPointMake(-_overlayView.cropRect.origin.x, -_overlayView.cropRect.origin.y)];
	UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

  return result;
}



////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) imagePickerController:(UIImagePickerController*)picker 
         didFinishPickingMediaWithInfo:(NSDictionary*)info {
  UIImage* image = [info objectForKey:UIImagePickerControllerOriginalImage];

  UIImage* scaled = [self scaledImage:image];

  if( nil == _decoder ) {
    _decoder = [[Decoder alloc] init];
    _decoder.delegate = self;
  }
  [_decoder decodeImage:scaled cropRect:_overlayView.cropRect];

  _overlayView.image = [self croppedImage:scaled];
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
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)decoder:(Decoder *)decoder decodingImage:(UIImage *)image usingSubset:(UIImage *)subset progress:(NSString *)message {
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)decoder:(Decoder *)decoder didDecodeImage:(UIImage *)image usingSubset:(UIImage *)subset withResult:(TwoDDecoderResult *)result {
  NSLog(@"didDecodeImage");
  NSLog(@"%@", result.text);
  NSLog(@"%@", result.points);
  _overlayView.points = result.points;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)decoder:(Decoder *)decoder failedToDecodeImage:(UIImage *)image usingSubset:(UIImage *)subset reason:(NSString *)reason {
}




@end

