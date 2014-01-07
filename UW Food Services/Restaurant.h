//
//  Restaurant.h
//  UW Food Services
//
//  Created by Frank Li on 12/22/2013.
//  Copyright (c) 2013 Xuefei Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UWServerAPIClient.h"
#import "ModelProtocol.h"
#import <CoreLocation/CoreLocation.h>
@class OpeningHours;

@interface Restaurant : NSObject<ModelProtocol>

@property (nonatomic, assign) unsigned int              outletID;
@property (nonatomic, strong) NSString                  *outletName;
@property (nonatomic, strong) NSString                  *outletDescription;
@property (nonatomic, strong) NSString                  *building;
@property (nonatomic, strong) NSString                  *notice;
@property (nonatomic) CLLocationCoordinate2D            coordinate;
@property (nonatomic, strong) NSURL                     *logoURL;
@property (nonatomic, assign) BOOL                      has_breakfast;
@property (nonatomic, assign) BOOL                      has_lunch;
@property (nonatomic, assign) BOOL                      has_dinner;
@property (nonatomic, assign) BOOL                      is_open_now;
@property (nonatomic, strong) NSArray                   *dates_closed; // array of NSDate
@property (nonatomic, strong) OpeningHours              *opening_hours;
@property (nonatomic, strong) NSArray                   *special_hours; // array of SpecialHours


@end