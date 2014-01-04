//
//  SpecialHours.m
//  UW Food Services
//
//  Created by Frank Li on 12/24/2013.
//  Copyright (c) 2013 Xuefei Li. All rights reserved.
//

#import "SpecialHours.h"

@implementation SpecialHours

@synthesize opening_hour = _opening_hour;
@synthesize closing_hour = _closing_hour;
@synthesize special_date = _special_date;

- (instancetype)initWithSpecialHoursAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    NSString *opening_hour_str = [attributes valueForKey:@"opening_hour"];
    NSString *closing_hour_str = [attributes valueForKey:@"closing_hour"];
    NSString *special_date_str = [attributes valueForKey:@"date"];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc]
                          initWithLocaleIdentifier:@"en_US"]];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    _special_date = [formatter dateFromString:special_date_str];
    [formatter setDateFormat:@"HH:mm"];
    _opening_hour = [formatter dateFromString:opening_hour_str];
    _closing_hour = [formatter dateFromString:closing_hour_str];
    
    return self;
}

@end
