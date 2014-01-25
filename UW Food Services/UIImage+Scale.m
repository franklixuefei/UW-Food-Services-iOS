//
//  UIImage+Scale.m
//  UW Food Services
//
//  Created by Frank Li on 1/8/2014.
//  Copyright (c) 2014 Xuefei Li. All rights reserved.
//

#import "UIImage+Scale.h"

@implementation UIImage (Scale)

- (UIImage *)resizeToWidth:(float)_width height:(float)_height
{
    CGImageRef imgRef = self.CGImage;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(_width, _height), NO, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(context, _width / self.size.width, -_height / self.size.height);
    CGContextTranslateCTM(context, 0, -self.size.height);
    CGContextConcatCTM(context, transform);
    CGContextSetAllowsAntialiasing(context, true);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, self.size.width, self.size.height), imgRef);
    
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}

- (UIImage *)scaleToMaxWidth:(float) maxWidth maxHeight:(float) maxHeight
{
    CGFloat width = self.size.width;
    CGFloat height = self.size.height;
    
    if (width <= maxWidth && height <= maxHeight)
    {
        return self;
    }
    
    CGSize bounds = CGSizeMake(width, height);
    
    if (width > maxWidth || height > maxHeight)
    {
        CGFloat ratio = width/height;
        
        if (ratio > 1)
        {
            bounds.width = maxWidth;
            bounds.height = bounds.width / ratio;
        }
        else
        {
            bounds.height = maxHeight;
            bounds.width = bounds.height * ratio;
        }
    }
    
    return [self resizeToWidth:bounds.width height:bounds.height];
}


@end
