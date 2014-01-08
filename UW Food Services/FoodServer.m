//
//  FoodServer.m
//  UW Food Services
//
//  Created by Frank Li on 12/23/2013.
//  Copyright (c) 2013 Xuefei Li. All rights reserved.
//

#import "FoodServer.h"
#import "AFNetworking.h"
#import "NSDate+ISO8601WeekNumber.h"
#import "FoodNull.h"

@interface FoodServer ()

- (AFHTTPRequestOperation *)createOperationWithType:(NSString *)type andSuccessBlock:(void (^)(AFHTTPRequestOperation *operation, id responseObject))successBlock andFailureBlock:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;
- (NSDictionary *)parseData:(NSMutableDictionary *)dataDict;

@end

@implementation FoodServer {
    BOOL _errorOccurred;
}

#pragma mark - defaultServer - singleton
+ (FoodServer *)defaultServer
{
    @synchronized([UIApplication sharedApplication]) {
		static FoodServer *s_pFoodServer = nil;
		if (!s_pFoodServer) {
			s_pFoodServer = [[FoodServer alloc] init];
		}
		return s_pFoodServer;
	}
}

#pragma mark - initialization
- (FoodServer *)init
{
    if (self = [super init]) {
        // initialization code here ...
        _errorOccurred = NO;
    }
    return self;
}

#pragma mark - Restaurant Server Call Helper Methods
- (AFHTTPRequestOperation *)createOperationWithType:(NSString *)type andSuccessBlock:(void (^)(AFHTTPRequestOperation *operation, id responseObject))successBlock andFailureBlock:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock {
    AFHTTPRequestOperation *operation = nil;
    NSURLRequest *request = nil;
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:API_KEY, @"key", nil];
    if ([type isEqualToString:API_OUTLETS_TYPE]) {
        request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:[API_BASE_URL stringByAppendingString:API_OUTLETS_URL] parameters:params];
        
    } else if ([type isEqualToString:API_MENU_TYPE]) {
        NSDate *today = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy"];
        NSUInteger currentYear = [[formatter stringFromDate:today] integerValue];
        NSUInteger weekNumber = [today iso8601WeeksForYear:currentYear];
        request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:[API_BASE_URL stringByAppendingString:[NSString stringWithFormat:@"%lu/%lu/%@", (unsigned long)currentYear, (unsigned long)weekNumber, API_MENU_URL]] parameters:params]; // FIXME: change to weekNumber
        
    } else if ([type isEqualToString:API_LOCATIONS_TYPE]) {
        request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:[API_BASE_URL stringByAppendingString:API_LOCATIONS_URL] parameters:params];
        
    } else {
        // should not get here
        abort();
    }
    operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:successBlock failure:failureBlock];
    return operation;
}


- (NSDictionary *)parseData:(NSMutableDictionary *)dataDict {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:4];
    
    NSMutableArray *restaurantsWithMenu = [NSMutableArray array];
    NSMutableArray *restaurantsWithoutMenu = [NSMutableArray array];
    NSArray *outlets = [[dataDict valueForKey:API_OUTLETS_TYPE] valueForKey:@"data"];
    NSArray *menuDate = [[[dataDict valueForKey:API_MENU_TYPE] valueForKey:@"data"] valueForKey:@"date"];
    NSArray *menuOutlets = [[[dataDict valueForKey:API_MENU_TYPE] valueForKey:@"data"] valueForKey:@"outlets"];
    NSArray *locations = [[dataDict valueForKey:API_LOCATIONS_TYPE] valueForKey:@"data"];
    
    for (NSDictionary *location in locations) {
        bool found = false;
        for (NSDictionary *menuOutlet in menuOutlets) {
            if (![FoodNull isNSNullOrNil:[location valueForKey:@"outlet_id"]] && ![FoodNull isNSNullOrNil:[menuOutlet valueForKey:@"outlet_id"]] && [[location valueForKey:@"outlet_id"] intValue] == [[menuOutlet valueForKey:@"outlet_id"] intValue]) {
                found = true;
                break;
            }
        }
        if (found) {
            if ([restaurantsWithMenu indexOfObject:location] == NSNotFound) {
                if (![[location valueForKey:@"outlet_name"] isEqualToString:@"UW Food Services Administrative Office"]) {
                    [restaurantsWithMenu addObject:location];
                }
            }
        } else {
            if ([restaurantsWithoutMenu indexOfObject:location] == NSNotFound) {
                if (![[location valueForKey:@"outlet_name"] isEqualToString:@"UW Food Services Administrative Office"]) {
                    [restaurantsWithoutMenu addObject:location];
                }
            }
        }
        
    }
    
    NSMutableArray *mutableRestaurantsWithMenu = [NSMutableArray array];
    NSMutableArray *mutableRestaurantsWithoutMenu = [NSMutableArray array];
    
    for (NSDictionary *restWithMenu in restaurantsWithMenu) {
        NSMutableDictionary *mutableRestWithMenu = [restWithMenu mutableCopy];
        for (NSDictionary *outlet in outlets) {
            if ([restWithMenu valueForKey:@"outlet_id"] == [outlet valueForKey:@"outlet_id"]) {
                [mutableRestWithMenu setObject:[outlet valueForKey:@"has_breakfast"] forKey:@"has_breakfast"];
                [mutableRestWithMenu setObject:[outlet valueForKey:@"has_lunch"] forKey:@"has_lunch"];
                [mutableRestWithMenu setObject:[outlet valueForKey:@"has_dinner"] forKey:@"has_dinner"];
            }
        }
        [mutableRestaurantsWithMenu addObject:mutableRestWithMenu];
    }
    for (NSDictionary *restWithoutMenu in restaurantsWithoutMenu) {
        NSMutableDictionary *mutableRestWithoutMenu = [restWithoutMenu mutableCopy];
        for (NSDictionary *outlet in outlets) {
            if ([restWithoutMenu valueForKey:@"outlet_id"] == [outlet valueForKey:@"outlet_id"]) {
                [mutableRestWithoutMenu setObject:[outlet valueForKey:@"has_breakfast"] forKey:@"has_breakfast"];
                [mutableRestWithoutMenu setObject:[outlet valueForKey:@"has_lunch"] forKey:@"has_lunch"];
                [mutableRestWithoutMenu setObject:[outlet valueForKey:@"has_dinner"] forKey:@"has_dinner"];
            }
        }
        [mutableRestaurantsWithoutMenu addObject:mutableRestWithoutMenu];
    }
    
    [dict setObject:[NSArray arrayWithArray:mutableRestaurantsWithMenu] forKey:RESTA_WTIH_MENU];
    [dict setObject:[NSArray arrayWithArray:mutableRestaurantsWithoutMenu] forKey:RESTA_WTIHOUT_MENU];
    [dict setObject:menuDate forKey:RESTA_MENU_DATE_INFO];
    [dict setObject:menuOutlets forKey:RESTA_MENU];
    return [NSDictionary dictionaryWithDictionary:dict];
}


#pragma mark - Restaurant Server Call

- (void)restaurantsInfoWithTypeArray:(NSArray *)typeArray andProgressBlock:(void (^)(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations))progressBlock andSuccessBlock:(void (^)(NSDictionary *parsedData))successBlock andFailureBlock:(void (^)(NSError *error))failureBlock {
    NSMutableArray *mutableOperations = [NSMutableArray array];
    NSMutableDictionary *responseDict = [NSMutableDictionary dictionaryWithCapacity:[typeArray count]];
    for (NSString *type in typeArray) {
        AFHTTPRequestOperation *operation = [self createOperationWithType:type andSuccessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
            operation.responseSerializer = [AFJSONResponseSerializer serializer];
            NSLog(@"Request URL: %@", operation.response.URL);
            //            NSLog(@"operation.responseObject %@", (NSDictionary *)operation.responseObject);
            [responseDict setObject:(NSDictionary *)operation.responseObject forKey:type];
        } andFailureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"failure operation: %@", operation);
            NSOperationQueue *q = [NSOperationQueue mainQueue];
            // the following block of code cancels rest of the operations.
            [[q.operations filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
                if ([evaluatedObject isKindOfClass:[AFHTTPRequestOperation class]]) {
                    AFHTTPRequestOperation *op = evaluatedObject;
                    return op.isExecuting;
                }
                return NO;
            }]] makeObjectsPerformSelector:@selector(cancel)];
            if (!_errorOccurred) { // only run failureBlock(error) once
                _errorOccurred = YES;
                failureBlock(error);
            }
        }];
        [mutableOperations addObject:operation];
    }
    
    NSArray *operations = [AFURLConnectionOperation batchOfRequestOperations:mutableOperations progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
        NSLog(@"%lu of %lu complete", (unsigned long)numberOfFinishedOperations, (unsigned long)totalNumberOfOperations);
        progressBlock(numberOfFinishedOperations, totalNumberOfOperations);
    } completionBlock:^(NSArray *operations) {

        NSLog(@"All operations in batch complete (maybe with errors)");
        NSLog(@"With operations: %@", operations);
        //        NSLog(@"response dict: %@", responseDict);
        if (_errorOccurred) {
            NSLog(@"Error(s) or cancellation(s) occurred with operations");
            failureBlock(nil);
            _errorOccurred = NO;
            return;
        }
        @try { // fail safe
            NSDictionary *parsedData = [self parseData:responseDict];
            successBlock(parsedData);
        }
        @catch (NSException *exception) {
            NSLog(@"Exception catched with reason: %@", exception.reason);
            failureBlock(nil);
        }
    }];
    [[NSOperationQueue mainQueue] addOperations:operations waitUntilFinished:NO];
}



@end
