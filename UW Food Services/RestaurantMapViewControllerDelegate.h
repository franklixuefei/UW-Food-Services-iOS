//
//  RestaurantMapViewControllerDelegate.h
//  UW Food Services
//
//  Created by Frank Li on 1/8/2014.
//  Copyright (c) 2014 Xuefei Li. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RestaurantMapViewControllerDelegate <NSObject>
@optional
- (void)restaurantMapViewWillAppear;
- (void)restaurantMapViewDidAppear;
@end
