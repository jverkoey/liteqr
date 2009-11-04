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
- (void)drawRect:(CGRect)rect {
  CGContextRef c = UIGraphicsGetCurrentContext();

  CGFloat rectSize = rect.size.width - kPadding * 2;

  CGFloat white[4] = {1.0f, 1.0f, 1.0f, 1.0f};
  CGContextSetStrokeColor(c, white);
  CGContextBeginPath(c);
  CGContextMoveToPoint(c, kPadding, (rect.size.height - rectSize) / 2);
  CGContextAddLineToPoint(c, rect.size.width - kPadding, (rect.size.height - rectSize) / 2);
  CGContextAddLineToPoint(c, rect.size.width - kPadding, (rect.size.height + rectSize) / 2);
  CGContextAddLineToPoint(c, kPadding, (rect.size.height + rectSize) / 2);
  CGContextAddLineToPoint(c, kPadding, (rect.size.height - rectSize) / 2);
  CGContextStrokePath(c);
}

@end
