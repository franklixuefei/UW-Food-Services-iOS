//
//  RestaurantCollectionViewCell.h
//  UW Food Services
//
//  Created by Frank Li on 1/2/2014.
//  Copyright (c) 2014 Xuefei Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RestaurantCollectionViewCell : UICollectionViewCell

@property (nonatomic) BOOL expanded;
@property (strong, nonatomic) NSURL *imageURL;

@end
