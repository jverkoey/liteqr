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

#import "OverlayView.h"

static const CGFloat kPadding = 10;


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation OverlayView


////////////////////////////////////////////////////////////////////////////////////////////////////
- (id) initWithFrame:(CGRect)frame {
  if( self = [super initWithFrame:frame] ) {
    self.backgroundColor = [UIColor clearColor];
  }

  return self;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) dealloc {
  [_imageView release];
  _imageView = nil;

  [super dealloc];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)drawRect:(CGRect)rect {
  CGContextRef c = UIGraphicsGetCurrentContext();

  CGRect cropRect = [self cropRect];

  CGFloat white[4] = {1.0f, 1.0f, 1.0f, 1.0f};
  CGContextSetStrokeColor(c, white);
  CGContextBeginPath(c);
  CGContextMoveToPoint(c, cropRect.origin.x, cropRect.origin.y);
  CGContextAddLineToPoint(c, cropRect.origin.x + cropRect.size.width, cropRect.origin.y);
  CGContextAddLineToPoint(c, cropRect.origin.x + cropRect.size.width, cropRect.origin.y + cropRect.size.height);
  CGContextAddLineToPoint(c, cropRect.origin.x, cropRect.origin.y + cropRect.size.height);
  CGContextAddLineToPoint(c, cropRect.origin.x, cropRect.origin.y);
  CGContextStrokePath(c);
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setImage:(UIImage*)image {
  if( nil == _imageView ) {
    _imageView = [[UIImageView alloc] initWithImage:image];
    _imageView.alpha = 0.5;
    [self addSubview:_imageView];
  } else {
    _imageView.image = image;
  }

  CGRect frame = _imageView.frame;
  frame.origin.x = 0;
  frame.origin.y = self.frame.size.height - _imageView.frame.size.height;
  _imageView.frame = frame;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (UIImage*) image {
  return _imageView.image;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (CGRect) cropRect {
  CGFloat rectSize = self.frame.size.width - kPadding * 2;

  return CGRectMake(kPadding, (self.frame.size.height - rectSize) / 2, rectSize, rectSize);
}


@end
