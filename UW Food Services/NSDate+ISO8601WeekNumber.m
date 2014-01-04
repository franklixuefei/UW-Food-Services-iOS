//
//  NSDate+ISO8601WeekNumber.m
//  UW Food Services
//
//  Created by Frank Li on 12/22/2013.
//  Copyright (c) 2013 Xuefei Li. All rights reserved.
//

#import "NSDate+ISO8601WeekNumber.h"

@implementation NSDate (ISO8601WeekNumber)

- (NSUInteger)iso8601WeeksForYear:(NSUInteger)year {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *firstThursdayOfYearComponents = [[NSDateComponents alloc] init];
    [firstThursdayOfYearComponents setWeekday:5]; // Thursday
    [firstThursdayOfYearComponents setWeekdayOrdinal:1]; // The first Thursday of the month
    [firstThursdayOfYearComponents setMonth:1]; // January
    [firstThursdayOfYearComponents setYear:year];
    NSDate *firstThursday = [calendar dateFromComponents:firstThursdayOfYearComponents];
    
    NSDateComponents *lastDayOfYearComponents = [[NSDateComponents alloc] init];
    [lastDayOfYearComponents setDay:31];
    [lastDayOfYearComponents setMonth:12];
    [lastDayOfYearComponents setYear:year];
    NSDate *lastDayOfYear = [calendar dateFromComponents:lastDayOfYearComponents];
    
    NSDateComponents *result = [calendar components:NSWeekCalendarUnit fromDate:firstThursday toDate:lastDayOfYear options:0];
    
    return result.week + 1;
}

@end
