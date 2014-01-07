//
//  RestaurantCollectionViewCell.m
//  UW Food Services
//
//  Created by Frank Li on 1/2/2014.
//  Copyright (c) 2014 Xuefei Li. All rights reserved.
//

#import "RestaurantCollectionViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+AFNetworking.h"
#import "UIColor+HexColor.h"

@interface RestaurantCollectionViewCell ()

- (void)initBasicUI;
- (void)initialize;

@end


@implementation RestaurantCollectionViewCell {

    UIImage *_placeholder;
}

@synthesize expanded = _expanded;
@synthesize imageURL = _imageURL;
@synthesize restaurantImageView = _restaurantImageView;
@synthesize buildingLabel = _buildingLabel;
@synthesize hoursLabel = _hoursLabel;
@synthesize openCloseLabel = _openCloseLabel;
@synthesize titleLabel = _titleLabel;
@synthesize separator = _separator;
@synthesize quote = _quote;
@synthesize descriptionLabel = _descriptionLabel;

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    // Initialization code
    _expanded = NO;
    [self initBasicUI];
}

- (void)initBasicUI
{
    self.clipsToBounds = YES;
    self.restaurantImageView.clipsToBounds = YES;
    self.descriptionLabel.textAlignment = NSTextAlignmentJustified;
    self.backgroundColor = [UIColor colorWithHexValue:0xfefefe andAlpha:1.0];
    self.layer.cornerRadius = 2.0f;
    self.layer.masksToBounds = NO;
    self.layer.shadowColor = [UIColor grayColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0.0f, 0.5f);
    self.layer.shadowOpacity = 0.8f;
    self.layer.shadowRadius = 1.0f;
    self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    if (_placeholder == nil) {
        _placeholder = [UIImage imageNamed:@"resta_placeholder"];
    }
}

- (void)setImageURL:(NSURL *)imageURL
{
    _imageURL = imageURL;
    __weak typeof(_restaurantImageView) weakSelf = _restaurantImageView;
    [_restaurantImageView setImageWithURLRequest:[NSURLRequest requestWithURL:_imageURL] placeholderImage:_placeholder success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        [weakSelf setImage:image];
        // TODO: maybe fade in the image
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"Image for request %@ not loaded. Response: %@", [request URL], response);
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
