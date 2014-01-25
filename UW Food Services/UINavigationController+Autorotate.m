//
//  UINavigationController+Autorotate.m
//  UW Food Services
//
//  Created by Frank Li on 1/8/2014.
//  Copyright (c) 2014 Xuefei Li. All rights reserved.
//

#import "UINavigationController+Autorotate.h"

@implementation UINavigationController (Autorotate)
-(BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}
@end
