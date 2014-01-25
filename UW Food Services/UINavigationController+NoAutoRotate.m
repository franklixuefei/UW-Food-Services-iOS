//
//  UINavigationController+NoAutoRotate.m
//  UW Food Services
//
//  Created by Frank Li on 1/8/2014.
//  Copyright (c) 2014 Xuefei Li. All rights reserved.
//

#import "UINavigationController+NoAutoRotate.h"

@implementation UINavigationController (NoAutoRotate)

-(BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
@end
