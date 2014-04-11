//
//  RestaurantListSectionHeaderView.m
//  UW Food Services
//
//  Created by Frank Li on 1/8/2014.
//  Copyright (c) 2014 Xuefei Li. All rights reserved.
//

#import "RestaurantListSectionHeaderView.h"
@interface RestaurantListSectionHeaderView()
- (void)initialize;
@end

@implementation RestaurantListSectionHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        // Initialization code
        [self initialize];
    }
    return self;
}

#warning never do frame/alpha initialization here. dequeueReusableCell method will reset these two properties.
- (void)initialize
{
    CGRect headerFrame = self.frame;
    headerFrame.size.height = kHeaderFrameHeight;
    [self setFrame:headerFrame];
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(10, 15, 300, 1)];
    separator.backgroundColor = [UIColor colorWithHexValue:0xcccccc andAlpha:1];
    [self addSubview:separator];
    UILabel *sectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 0, 80, 30)];
    
}



@end
