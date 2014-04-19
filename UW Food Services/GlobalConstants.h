//
//  constants.h
//  UW Food Services
//
//  Created by Frank Li on 12/22/2013.
//  Copyright (c) 2013 Xuefei Li. All rights reserved.
//

#ifndef UW_Food_Services_constants_h
#define UW_Food_Services_constants_h

#define BAR_BUTTON_ITEM_INSETS (UIEdgeInsetsMake(4, 0, 0, 0))

#define API_KEY             @"d47fe3afb19f506f5a95e89e99527595"
#define API_BASE_URL        @"https://api.uwaterloo.ca/v2/foodservices/"

#define GMAP_API_KEY        @"AIzaSyB-mvt342bSpu3pMbGoiRRoa8tu538ygUE"

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
#define RESTAURANT_COLLECTION_VIEW_HEADER_ID @"restaurant_list_header"
#define RESTAURANT_COLLECTION_VIEW_FOOTER_ID @"restaurant_list_footer"

#define RESTAURANT_COLLECTION_VIEW_INSETS_GRID              (UIEdgeInsetsMake(0, 10, 0, 10))
#define RESTAURANT_COLLECTION_VIEW_CELL_SIZE_GRID           (CGSizeMake(144, 120))
#define RESTAURANT_COLLECTION_VIEW_MIN_LINE_SPACING_GRID                (14)

#define RESTAURANT_COLLECTION_VIEW_INSETS_LIST              (UIEdgeInsetsMake(0, 0, 0, 0))
#define RESTAURANT_COLLECTION_VIEW_CELL_SIZE_LIST           (CGSizeMake(320, 96))
#define RESTAURANT_COLLECTION_VIEW_MIN_LINE_SPACING_LIST                (0)

#define RESTAURANT_COLLECTION_VIEW_INSETS_DETAILED_LIST     (UIEdgeInsetsMake(0, 10, 0, 10))
#define RESTAURANT_COLLECTION_VIEW_CELL_SIZE_DETAILED_LIST  (CGSizeMake(300, 338))
#define RESTAURANT_COLLECTION_VIEW_MIN_LINE_SPACING_DETAILED_LIST       (20)

#define RESTAURANT_COLLECTION_VIEW_MIN_CELL_SPACING         (0)

#define GRID_LAYOUT_LOGO_FRAME          (CGRectMake(2, 2, 140, 76))
#define GRID_LAYOUT_SEPARATOR_FRAME     (CGRectMake(4, 40, 136, 1))
#define GRID_LAYOUT_TITLE_FRAME         (CGRectMake(2, 12, 140, 20))
#define GRID_LAYOUT_BUILDING_FRAME      (CGRectMake(31, 80, 105, 16))
#define GRID_LAYOUT_HOURS_FRAME         (CGRectMake(31, 98, 105, 16))
#define GRID_LAYOUT_BUILDING_ICON_FRAME (CGRectMake(10, 81, 13, 13))
#define GRID_LAYOUT_HOURS_ICON_FRAME    (CGRectMake(10, 99, 13, 14))
#define GRID_LAYOUT_DOT_FRAME           (CGRectMake(116, 90, 20, 16))
#define GRID_LAYOUT_QUOTE_FRAME         (CGRectMake(10, 50, 24, 24))
#define GRID_LAYOUT_DESCRIPTION_FRAME   (CGRectMake(20, 12, 104, 60))

#define LIST_LAYOUT_LOGO_FRAME          (CGRectMake(2, 2, 92, 92))
#define LIST_LAYOUT_SEPARATOR_FRAME     (CGRectMake(0, 95, 320, 1))
#define LIST_LAYOUT_TITLE_FRAME         (CGRectMake(102, 12, 190, 20))
#define LIST_LAYOUT_BUILDING_FRAME      (CGRectMake(123, 40, 190, 16))
#define LIST_LAYOUT_HOURS_FRAME         (CGRectMake(123, 64, 190, 16))
#define LIST_LAYOUT_BUILDING_ICON_FRAME (CGRectMake(102, 41, 13, 13))
#define LIST_LAYOUT_HOURS_ICON_FRAME    (CGRectMake(102, 65, 13, 14))
#define LIST_LAYOUT_DOT_FRAME           (CGRectMake(292, 40, 20, 16))
#define LIST_LAYOUT_QUOTE_FRAME         (CGRectMake(30, 14, 24, 24))
#define LIST_LAYOUT_DESCRIPTION_FRAME   (CGRectMake(57, 21, 225, 60))

#define DETAIL_LAYOUT_LOGO_FRAME            (CGRectMake(4, 4, 292, 180))
#define DETAIL_LAYOUT_SEPARATOR_FRAME       (CGRectMake(20, 220, 260, 1))
#define DETAIL_LAYOUT_TITLE_FRAME           (CGRectMake(20, 192, 260, 20))
#define DETAIL_LAYOUT_BUILDING_FRAME        (CGRectMake(41, 229, 116, 16))
#define DETAIL_LAYOUT_HOURS_FRAME           (CGRectMake(184, 229, 100, 16))
#define DETAIL_LAYOUT_BUILDING_ICON_FRAME   (CGRectMake(20, 230, 13, 13))
#define DETAIL_LAYOUT_HOURS_ICON_FRAME      (CGRectMake(163, 230, 13, 14))
#define DETAIL_LAYOUT_DOT_FRAME             (CGRectMake(264, 229, 20, 16))
#define DETAIL_LAYOUT_QUOTE_FRAME           (CGRectMake(14, 251, 24, 24))
#define DETAIL_LAYOUT_DESCRIPTION_FRAME     (CGRectMake(41, 258, 225, 60))

#define SCREEN_NAME_RESTAURANT_LIST         @"Restaurants"
#define SCREEN_NAME_MAP                     @"MapThem!"

#endif
