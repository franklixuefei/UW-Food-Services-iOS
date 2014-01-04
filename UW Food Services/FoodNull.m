//
//  FoodNull.m
//  UW Food Services
//
//  Created by Frank Li on 12/24/2013.
//  Copyright (c) 2013 Xuefei Li. All rights reserved.
//

#import "FoodNull.h"

@implementation FoodNull

+ (BOOL) isNSNullOrNil:(id)target {
    return ([target isKindOfClass:[NSNull class]] || target == nil);
}

@end
