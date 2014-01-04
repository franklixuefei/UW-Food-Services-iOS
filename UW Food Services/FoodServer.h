//
//  FoodServer.h
//  UW Food Services
//
//  Created by Frank Li on 12/23/2013.
//  Copyright (c) 2013 Xuefei Li. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FoodServer : NSObject

+ (void)restaurantsInfoWithTypeArray:(NSArray *)URLArray andProgressBlock:(void (^)(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations))progressBlock andSuccessBlock:(void (^)(NSDictionary *parsedData))successBlock andFailureBlock:(void (^)(NSError *error))failureBlock;

@end
