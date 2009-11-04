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


static const NSTimeInterval kTakePictureTimeInterval = 10;


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation DecoderController


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) dealloc {
  [super dealloc];

  [_imagePicker release];
  _imagePicker = nil;
  [_overlayView release];
  _overlayView = nil;
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
- (void) imagePickerController:(UIImagePickerController*)picker 
         didFinishPickingMediaWithInfo:(NSDictionary*)info {
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
- (void) imagePickerController: (UIImagePickerController*)picker
         didFinishPickingImage: (UIImage*)image
                   editingInfo: (NSDictionary*)editingInfo {
  [[picker parentViewController] dismissModalViewControllerAnimated:YES];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSTimer


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)takePicture:(NSTimer*)theTimer {
  [_imagePicker takePicture];
}


@end

