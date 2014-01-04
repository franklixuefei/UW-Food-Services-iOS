//
//  DailyOpeningHours.m
//  UW Food Services
//
//  Created by Frank Li on 12/24/2013.
//  Copyright (c) 2013 Xuefei Li. All rights reserved.
//

#import "DailyOpeningHours.h"

@implementation DailyOpeningHours

@synthesize opening_hour = _opening_hour;
@synthesize closing_hour = _closing_hour;
@synthesize is_closed = _is_closed;

- (instancetype)initWithOpeningHourString:(NSString *)opening_hour_str
                        closingHourString:(NSString *)closing_hour_str
                              andIsClosed:(BOOL)is_closed {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc]
                          initWithLocaleIdentifier:@"en_US"]];
    [formatter setDateFormat:@"HH:mm"];
    if (!is_closed) {
        _opening_hour = [formatter dateFromString:opening_hour_str];
        _closing_hour = [formatter dateFromString:closing_hour_str];
    } else {
        _opening_hour = nil;
        _closing_hour = nil;
    }
    //    NSLog(@"opening at:%@", [formatter stringFromDate:_opening_hour]);
    //    NSLog(@"closing at:%@", [formatter stringFromDate:_closing_hour]);
    _is_closed = is_closed;
    return self;
}

@end
