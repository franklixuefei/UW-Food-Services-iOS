//
//  DetailViewController.h
//  UW Food Services
//
//  Created by Frank Li on 12/14/2013.
//  Copyright (c) 2013 Xuefei Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Restaurant.h"

@interface RestaurantDetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) Restaurant* restaurant;
@end
