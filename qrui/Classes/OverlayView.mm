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

@synthesize points = _points;


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
  [_points release];
  _points = nil;

  [super dealloc];
}


- (void)drawRect:(CGRect)rect inContext:(CGContextRef)context {
  CGContextBeginPath(context);
  CGContextMoveToPoint(context, rect.origin.x, rect.origin.y);
  CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y);
  CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
  CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y + rect.size.height);
  CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y);
  CGContextStrokePath(context);
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)drawRect:(CGRect)rect {
  CGContextRef c = UIGraphicsGetCurrentContext();

  CGRect cropRect = [self cropRect];

  if( nil != _points ) {
    [_imageView.image drawAtPoint:cropRect.origin];
  }

  CGFloat white[4] = {1.0f, 1.0f, 1.0f, 1.0f};
  CGContextSetStrokeColor(c, white);
  [self drawRect:cropRect inContext:c];

  CGFloat blue[4] = {0.0f, 1.0f, 0.0f, 1.0f};
  CGContextSetStrokeColor(c, blue);
  CGRect smallSquare = CGRectMake(0, 0, 10, 10);
  if( nil != _points ) {
    for( NSValue* value in _points ) {
      CGPoint point = [value CGPointValue];
      smallSquare.origin = CGPointMake(
        cropRect.origin.x + point.x - smallSquare.size.width / 2,
        cropRect.origin.y + point.y - smallSquare.size.height / 2);
      [self drawRect:smallSquare inContext:c];
    }
  }
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setImage:(UIImage*)image {
  if( nil == _imageView ) {
    _imageView = [[UIImageView alloc] initWithImage:image];
    _imageView.alpha = 0.5;
  } else {
    _imageView.image = image;
  }

  CGRect frame = _imageView.frame;
  frame.origin.x = self.cropRect.origin.x;
  frame.origin.y = self.cropRect.origin.y;
  _imageView.frame = frame;

  [_points release];
  _points = nil;
  self.backgroundColor = [UIColor clearColor];

  [self setNeedsDisplay];
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


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setPoints:(NSArray*)points {
  [points retain];
  [_points release];
  _points = points;

  self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];

  [self setNeedsDisplay];
}


@end
