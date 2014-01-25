//
//  RestaurantListCollectionView.m
//  UW Food Services
//
//  Created by Frank Li on 1/8/2014.
//  Copyright (c) 2014 Xuefei Li. All rights reserved.
//

#import "RestaurantListCollectionView.h"

@implementation RestaurantListCollectionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
    }
    return self;
}
/*
 * This overriden method is a hack around for avoiding abrupt jump
 * when user tries to hold-pull to refresh
 */
- (void) setContentInset:(UIEdgeInsets)contentInset
{
    if (self.tracking) {
        CGFloat diff = contentInset.top - self.contentInset.top;
        CGPoint translation = [self.panGestureRecognizer translationInView:self];
        translation.y -= diff * (self.bounds.size.height < 568.0f ? 3.0 : 3.0) / 2.0;
        [self.panGestureRecognizer setTranslation:translation inView:self];
    }
    [super setContentInset:contentInset];
}

@end
