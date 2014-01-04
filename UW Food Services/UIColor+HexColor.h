//
//  UIColor+HexColor.h
//  UW Food Services
//
//  Created by Frank Li on 1/3/2014.
//  Copyright (c) 2014 Xuefei Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (HexColor)
+ (UIColor *)colorWithHexValue:(NSUInteger)hexVal andAlpha:(NSUInteger)a;
@end
