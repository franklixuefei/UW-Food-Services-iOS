//
//  UINavigationController+Autorotate.h
//  UW Food Services
//
//  Created by Frank Li on 1/8/2014.
//  Copyright (c) 2014 Xuefei Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (Autorotate)
-(BOOL)shouldAutorotate;
- (NSUInteger)supportedInterfaceOrientations;
@end
