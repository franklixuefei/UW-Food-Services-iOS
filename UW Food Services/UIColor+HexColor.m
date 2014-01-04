//
//  UIColor+HexColor.m
//  UW Food Services
//
//  Created by Frank Li on 1/3/2014.
//  Copyright (c) 2014 Xuefei Li. All rights reserved.
//

#import "UIColor+HexColor.h"

@implementation UIColor (HexColor)

+ (UIColor *)colorWithHexValue:(NSUInteger)hexVal andAlpha:(NSUInteger)a
{
    return [UIColor colorWithRed:((float)((hexVal & 0xFF0000) >> 16))/255.0 green:((float)((hexVal & 0xFF00) >> 8))/255.0 blue:((float)(hexVal & 0xFF))/255.0 alpha:a];
}

@end
