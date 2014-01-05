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
@property (strong, nonatomic) IBOutlet UIImageView *restaurantImageView;
@property (strong, nonatomic) IBOutlet UILabel *buildingLabel;
@property (strong, nonatomic) IBOutlet UILabel *hoursLabel;
@property (strong, nonatomic) IBOutlet UILabel *openCloseLabel;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIView *separator;
@property (strong, nonatomic) IBOutlet UIImageView *quote;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UIImageView *buildingIcon;
@property (strong, nonatomic) IBOutlet UIImageView *hoursIcon;

@end
