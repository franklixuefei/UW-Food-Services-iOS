//
//  NSDate+ISO8601WeekNumber.h
//  UW Food Services
//
//  Created by Frank Li on 12/22/2013.
//  Copyright (c) 2013 Xuefei Li. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (ISO8601WeekNumber)

- (NSUInteger)iso8601WeeksForYear:(NSUInteger)year;

@end
