//
//  SpecialHours.h
//  UW Food Services
//
//  Created by Frank Li on 12/24/2013.
//  Copyright (c) 2013 Xuefei Li. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SpecialHours : NSObject

@property (nonatomic, strong) NSDate    *opening_hour;
@property (nonatomic, strong) NSDate    *closing_hour;
@property (nonatomic, strong) NSDate    *special_date;

- (instancetype)initWithSpecialHoursAttributes:(NSDictionary *)attributes;

@end
