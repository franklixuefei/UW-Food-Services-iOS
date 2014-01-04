//
//  UWServerAPIClient.m
//  UW Food Services
//
//  Created by Frank Li on 12/22/2013.
//  Copyright (c) 2013 Xuefei Li. All rights reserved.
//

#import "UWServerAPIClient.h"

static NSString * const UWServerAPIBaseURLString = @"https://api.uwaterloo.ca/v2/";

@implementation UWServerAPIClient

+ (instancetype)sharedClient {
    static UWServerAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[UWServerAPIClient alloc] initWithBaseURL:[NSURL URLWithString:UWServerAPIBaseURLString]];
    });
    return _sharedClient;
}



@end
