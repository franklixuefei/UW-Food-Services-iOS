//
//  constants.h
//  UW Food Services
//
//  Created by Frank Li on 12/22/2013.
//  Copyright (c) 2013 Xuefei Li. All rights reserved.
//

#ifndef UW_Food_Services_constants_h
#define UW_Food_Services_constants_h

#define API_KEY             @"d47fe3afb19f506f5a95e89e99527595"
#define API_BASE_URL        @"https://api.uwaterloo.ca/v2/foodservices/"

#define API_OUTLETS_URL         @"outlets.json"
#define API_MENU_URL            @"menu.json"
#define API_LOCATIONS_URL       @"locations.json"

#define API_OUTLETS_TYPE        @"outlets"
#define API_MENU_TYPE           @"menu"
#define API_LOCATIONS_TYPE      @"locations"

#define RESTA_WTIH_MENU         @"restaurants_with_menu"
#define RESTA_WTIHOUT_MENU      @"restaurants_without_menu"
#define RESTA_MENU_DATE_INFO    @"restaurants_menu_date_info"
#define RESTA_MENU              @"restaurants_menu"

#define MONDAY                  @"monday"
#define TUESDAY                 @"tuesday"
#define WEDNESDAY               @"wednesday"
#define THURSDAY                @"thursday"
#define FRIDAY                  @"friday"
#define SATURDAY                @"saturday"
#define SUNDAY                  @"sunday"

#define RESTAURANT_COLLECTION_VIEW_CELL_ID  @"restaurant_collection_view_cell_id"

#define RESTAURANT_COLLECTION_VIEW_INSET                (UIEdgeInsetsMake(20, 10, 20, 10))
#define RESTAURANT_COLLECTION_VIEW_CELL_WIDTH           (144)
#define RESTAURANT_COLLECTION_VIEW_CELL_HEIGHT          (120)
#define RESTAURANT_COLLECTION_VIEW_MIN_LINE_SPACING     (14)
#define RESTAURANT_COLLECTION_VIEW_MIN_CELL_SPACING     (0)

#define SCREEN_NAME_RESTAURANT_LIST         @"UW Food Services"
#endif
