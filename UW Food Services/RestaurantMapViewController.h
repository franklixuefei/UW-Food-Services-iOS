//
//  RestaurantMapViewController.h
//  UW Food Services
//
//  Created by Frank Li on 1/5/2014.
//  Copyright (c) 2014 Xuefei Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>

@interface RestaurantMapViewController : UIViewController<GMSMapViewDelegate>
    @property (nonatomic, strong) NSArray *restaurantsInfo;
@end
