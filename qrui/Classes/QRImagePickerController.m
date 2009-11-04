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

#import "QRImagePickerController.h"

#define CAMERA_SCALAR 1.12412 // scalar = (480 / (2048 / 480))

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation QRImagePickerController


////////////////////////////////////////////////////////////////////////////////////////////////////
- (id) init {
  if( self = [super init] ) {
    self.wantsFullScreenLayout = YES;
    self.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.cameraViewTransform = CGAffineTransformScale(
      self.cameraViewTransform, CAMERA_SCALAR, CAMERA_SCALAR);
  }

  return self;
}


@end
