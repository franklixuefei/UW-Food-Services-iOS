//
//  DailyOpeningHours.h
//  UW Food Services
//
//  Created by Frank Li on 12/24/2013.
//  Copyright (c) 2013 Xuefei Li. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DailyOpeningHours : NSObject

@property (nonatomic, strong) NSDate    *opening_hour;
@property (nonatomic, strong) NSDate    *closing_hour;
@property (nonatomic, assign) BOOL      is_closed;

- (instancetype)initWithOpeningHourString:(NSString *)opening_hour_str
                        closingHourString:(NSString *)closing_hour_str
                              andIsClosed:(BOOL)is_closed;

@end
