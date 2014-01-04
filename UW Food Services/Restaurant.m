//
//  Restaurant.m
//  UW Food Services
//
//  Created by Frank Li on 12/22/2013.
//  Copyright (c) 2013 Xuefei Li. All rights reserved.
//

#import "Restaurant.h"
#import "GlobalConstants.h"
#import "AFNetworking.h"
#import "NSDate+ISO8601WeekNumber.h"
#import "OpeningHours.h"
#import "SpecialHours.h"
#import "FoodNull.h"

@interface Restaurant ()

- (NSArray *)createDatesClosedWithDates:(NSArray *)dates;
- (NSArray *)createSpecialHoursWithHours:(NSArray *)hours;

@end

@implementation Restaurant

@synthesize outletID = _outletID;
@synthesize outletName = _outletName;
@synthesize description = _description;
@synthesize building = _building;
@synthesize notice = _notice;
@synthesize latitude = _latitude;
@synthesize longitude = _longitude;
@synthesize logoURL = _logoURL;
@synthesize has_breakfast = _has_breakfast;
@synthesize has_lunch = _has_lunch;
@synthesize has_dinner = _has_dinner;
@synthesize is_open_now = _is_open_now;
@synthesize dates_closed = _dates_closed;
@synthesize opening_hours = _opening_hours;
@synthesize special_hours = _special_hours;

#pragma mark - initialization

- (NSArray *)createDatesClosedWithDates:(NSArray *)dates {
    NSMutableArray *mutableDates = [NSMutableArray arrayWithCapacity:[dates count]];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc]
                          initWithLocaleIdentifier:@"en_US"]];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    for (NSString *dateClosed in dates) {
        NSDate *generatedDate = [formatter dateFromString:dateClosed];
        [mutableDates addObject:generatedDate];
    }
    return [NSArray arrayWithArray:mutableDates];
}

- (NSArray *)createSpecialHoursWithHours:(NSArray *)hours {
    NSMutableArray *mutableHours = [NSMutableArray arrayWithCapacity:[hours count]];
    for (NSDictionary *hour in hours) {
        SpecialHours *special_hour = [[SpecialHours alloc] initWithSpecialHoursAttributes:hour];
        [mutableHours addObject:special_hour];
    }
    return [NSArray arrayWithArray:mutableHours];
}

- (instancetype)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _building = [attributes valueForKey:@"building"];
    _dates_closed = [self createDatesClosedWithDates:[attributes valueForKey:@"dates_closed"]];
    _description = [attributes valueForKey:@"description"];
    _has_breakfast = [[attributes valueForKey:@"has_breakfast"] boolValue];
    _has_lunch = [[attributes valueForKey:@"has_lunch"] boolValue];
    _has_dinner = [[attributes valueForKey:@"has_dinner"] boolValue];
    _is_open_now = [[attributes valueForKey:@"is_open_now"] boolValue];
    _latitude = [attributes valueForKey:@"latitude"];
    _longitude = [attributes valueForKey:@"longitude"];
    _notice = [attributes valueForKey:@"notice"];
    _opening_hours = [[OpeningHours alloc] initOpeningHours:[attributes valueForKey:@"opening_hours"]];
    _outletID = [FoodNull isNSNullOrNil:[attributes valueForKey:@"outlet_id"]] ? 0 : [[attributes valueForKey:@"outlet_id"] unsignedIntValue];
    _outletName = [attributes valueForKey:@"outlet_name"];
    _special_hours = [self createSpecialHoursWithHours:[attributes valueForKey:@"special_hours"]];
    _logoURL = [NSURL URLWithString:[attributes valueForKey:@"logo"]];
    return self;
}


@end
