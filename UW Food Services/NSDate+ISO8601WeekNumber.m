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
    NSDate *currDate = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:NSWeekOfYearCalendarUnit fromDate:currDate];
    NSLog(@"current week of year: %ld", (long)components.weekOfYear);
    return components.weekOfYear;
}

@end
