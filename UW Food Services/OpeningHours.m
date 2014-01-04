//
//  OpeningHours.m
//  UW Food Services
//
//  Created by Frank Li on 12/23/2013.
//  Copyright (c) 2013 Xuefei Li. All rights reserved.
//

#import "OpeningHours.h"
#import "DailyOpeningHours.h"
#import "GlobalConstants.h"

@interface OpeningHours ()

- (DailyOpeningHours *)createDailyOpeningHoursWithDay:(NSDictionary *)day;

@end

@implementation OpeningHours

@synthesize monday = _monday;
@synthesize tuesday = _tuesday;
@synthesize wednesday = _wednesday;
@synthesize thursday = _thursday;
@synthesize friday = _friday;
@synthesize saturday = _saturday;
@synthesize sunday = _sunday;

- (DailyOpeningHours *)createDailyOpeningHoursWithDay:(NSDictionary *)day {
    return [[DailyOpeningHours alloc] initWithOpeningHourString:[day valueForKey:@"opening_hour"] closingHourString:[day valueForKey:@"closing_hour"] andIsClosed:[[day valueForKey:@"is_closed"] boolValue]];
}

- (instancetype)initOpeningHours:(NSDictionary *)openingHours {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    NSDictionary *mon = [openingHours valueForKey:MONDAY];
    NSDictionary *tue = [openingHours valueForKey:TUESDAY];
    NSDictionary *wed = [openingHours valueForKey:WEDNESDAY];
    NSDictionary *thu = [openingHours valueForKey:THURSDAY];
    NSDictionary *fri = [openingHours valueForKey:FRIDAY];
    NSDictionary *sat = [openingHours valueForKey:SATURDAY];
    NSDictionary *sun = [openingHours valueForKey:SUNDAY];
    _monday = [self createDailyOpeningHoursWithDay:mon];
    _tuesday = [self createDailyOpeningHoursWithDay:tue];
    _wednesday = [self createDailyOpeningHoursWithDay:wed];
    _thursday = [self createDailyOpeningHoursWithDay:thu];
    _friday = [self createDailyOpeningHoursWithDay:fri];
    _saturday = [self createDailyOpeningHoursWithDay:sat];
    _sunday = [self createDailyOpeningHoursWithDay:sun];
    return self;
}

@end
