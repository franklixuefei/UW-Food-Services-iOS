//
//  UIImage+Scale.h
//  UW Food Services
//
//  Created by Frank Li on 1/8/2014.
//  Copyright (c) 2014 Xuefei Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Scale)
- (UIImage *)resizeToWidth:(float)_width height:(float)_height;
- (UIImage *)scaleToMaxWidth:(float) maxWidth maxHeight:(float) maxHeight;
@end
