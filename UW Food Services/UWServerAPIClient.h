//
//  UWServerAPIClient.h
//  UW Food Services
//
//  Created by Frank Li on 12/22/2013.
//  Copyright (c) 2013 Xuefei Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"

@interface UWServerAPIClient : AFHTTPSessionManager

+ (instancetype)sharedClient;

@end
