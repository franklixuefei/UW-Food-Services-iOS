//
//  OpeningHours.h
//  UW Food Services
//
//  Created by Frank Li on 12/23/2013.
//  Copyright (c) 2013 Xuefei Li. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DailyOpeningHours;

@interface OpeningHours : NSObject

@property (nonatomic, strong) DailyOpeningHours *monday;
@property (nonatomic, strong) DailyOpeningHours *tuesday;
@property (nonatomic, strong) DailyOpeningHours *wednesday;
@property (nonatomic, strong) DailyOpeningHours *thursday;
@property (nonatomic, strong) DailyOpeningHours *friday;
@property (nonatomic, strong) DailyOpeningHours *saturday;
@property (nonatomic, strong) DailyOpeningHours *sunday;

- (instancetype)initOpeningHours:(NSDictionary *)openingHours;

@end
