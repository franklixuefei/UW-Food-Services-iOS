//
//  NSDate+dateToHHmmString.m
//  UW Food Services
//
//  Created by Frank Li on 1/6/2014.
//  Copyright (c) 2014 Xuefei Li. All rights reserved.
//

#import "NSDate+dateToHHmmString.h"

@implementation NSDate (dateToHHmmString)

- (NSString *)dateToStringWithHHmmFormat
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [formatter setDateFormat:@"HH:mm"];
    return [formatter stringFromDate:self];
}

@end
