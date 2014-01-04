//
//  UIColor+RGBColor.m
//  UW Food Services
//
//  Created by Frank Li on 1/3/2014.
//  Copyright (c) 2014 Xuefei Li. All rights reserved.
//

#import "UIColor+RGBColor.h"

@implementation UIColor (RGBColor)

+ (UIColor *)colorWithR:(NSUInteger)r g:(NSUInteger)g b:(NSUInteger)b andAlpha:(NSUInteger)a
{
    return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a];
}

@end
