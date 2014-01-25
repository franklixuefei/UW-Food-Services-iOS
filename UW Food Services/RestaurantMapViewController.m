//
//  RestaurantMapViewController.m
//  UW Food Services
//
//  Created by Frank Li on 1/5/2014.
//  Copyright (c) 2014 Xuefei Li. All rights reserved.
//

#import "RestaurantMapViewController.h"
#import "Restaurant.h"
#import "OpeningHours.h"
#import "NSDate+dateToHHmmString.h"
#import "UINavigationController+Autorotate.h"

#define kOverlayHeightTop (SYSTEM_VERSION_LESS_THAN(@"7.0") ? 44.0f : 64.0f)

@interface RestaurantMapViewController ()
@property(nonatomic) BOOL hybridEnabled;
- (void)initialize;
- (void)showMarkers;
- (void)fitBoundWithSender:(UIBarButtonItem *)sender;
- (void)resignFitBound;
- (void)addTopOverlay;
- (void)hybridModePressed:(UIBarButtonItem *)sender;
- (void)fitBoundPressed:(id)sender;

@end

@implementation RestaurantMapViewController {
    GMSMapView * mapView_;
    UIView *overlayTop_;
    NSMutableArray *markers_;
    UIImage *satellite_;
    UIImage *satellite_deseleted_;
    UIImage *fit_;
    UIImage *fit_deselected_;
    BOOL marker_tapped_;
}
@synthesize restaurantsInfo = _restaurantsInfo;
@synthesize hybridEnabled = _hybridEnabled;
@synthesize delegate = _delegate;


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight || toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    } else {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}

#pragma mark - ViewController Life Cycle

- (void)viewDidLoad
{
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self initialize];
    
    _hybridEnabled = NO;
    marker_tapped_ = NO;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([_delegate respondsToSelector:@selector(restaurantMapViewWillAppear)]) {
        [_delegate restaurantMapViewWillAppear];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:43.4749848
                                                            longitude:-80.5523327
                                                                 zoom:14];
    
    mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapView_.delegate = self;
    mapView_.settings.myLocationButton = YES;
    mapView_.myLocationEnabled = YES;
    mapView_.settings.compassButton = YES;
    [self showMarkers];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.view = mapView_;
    [self performSelector:@selector(fitBoundWithSender:) withObject:[self.navigationItem.rightBarButtonItems lastObject] afterDelay:0.3f];
    [self addTopOverlay];
    if ([_delegate respondsToSelector:@selector(restaurantMapViewDidAppear)]) {
        [_delegate restaurantMapViewDidAppear];
    }
}

- (void)initialize
{
    satellite_ = [UIImage imageNamed:@"satellite"];
    satellite_deseleted_ = [[UIImage imageNamed:@"satellite"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    fit_ = [UIImage imageNamed:@"fitBound"];
    fit_deselected_ = [[UIImage imageNamed:@"fitBound"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.title = SCREEN_NAME_MAP;
    self.navigationItem.title = SCREEN_NAME_MAP;
    UIBarButtonItem *satellite = [[UIBarButtonItem alloc] initWithImage:satellite_deseleted_ style:UIBarButtonItemStylePlain target:self action:@selector(hybridModePressed:)];
    UIBarButtonItem *fit = [[UIBarButtonItem alloc] initWithImage:fit_deselected_ style:UIBarButtonItemStylePlain target:self action:@selector(fitBoundPressed:)];
    [satellite setImageInsets:BAR_BUTTON_ITEM_INSETS];
    [fit setImageInsets:BAR_BUTTON_ITEM_INSETS];
    NSArray *rightItemsArray = @[satellite, fit];
    self.navigationItem.rightBarButtonItems = rightItemsArray;
}

- (void)showMarkers
{
    markers_ = [NSMutableArray arrayWithCapacity:[_restaurantsInfo count]];
    for (Restaurant *restaurant in _restaurantsInfo) {
        GMSMarker *restaLocation = [[GMSMarker alloc] init];
        restaLocation.title = restaurant.outletName;
        if (!restaurant.opening_hours.today.is_closed) {
            restaLocation.snippet = [NSString stringWithFormat:@"Today: %@ - %@", restaurant.opening_hours.today.opening_hour.dateToStringWithHHmmFormat, restaurant.opening_hours.today.closing_hour.dateToStringWithHHmmFormat];
        } else {
            restaLocation.snippet = @"Closed today";
        }
        restaLocation.appearAnimation = kGMSMarkerAnimationPop;
        restaLocation.position = restaurant.coordinate;
        restaLocation.map = mapView_;
        [markers_ addObject:restaLocation];
    }
}

- (void)fitBoundWithSender:(id)sender
{
    [(UIBarButtonItem *)(sender) setImage:fit_];
    GMSCoordinateBounds *bounds;
    for (GMSMarker *marker in markers_) {
        if (bounds == nil) {
            bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:marker.position coordinate:marker.position];
        }
        bounds = [bounds includingCoordinate:marker.position];
    }
    GMSCameraUpdate *update = [GMSCameraUpdate fitBounds:bounds
                                             withPadding:30.0f];
    [mapView_ animateWithCameraUpdate:update];
}

- (void)resignFitBound
{
    UIBarButtonItem *fitItem = [self.navigationItem.rightBarButtonItems lastObject];
    [fitItem setImage:fit_deselected_];
}

- (void)addTopOverlay
{
    mapView_.padding = UIEdgeInsetsMake(kOverlayHeightTop, 0, 0, 0);
    CGRect overlayFrameBottom = CGRectMake(0, 0, 0, kOverlayHeightTop);
    overlayTop_ = [[UIView alloc] initWithFrame:overlayFrameBottom];
    overlayTop_.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:overlayTop_];
}

- (void)setHybridEnabled:(BOOL)hybridEnabled
{
    _hybridEnabled = hybridEnabled;
    if (_hybridEnabled) {
        mapView_.mapType = kGMSTypeHybrid;
    } else {
        mapView_.mapType = kGMSTypeNormal;
    }
}

- (void)hybridModePressed:(UIBarButtonItem *)sender
{
    self.hybridEnabled = !_hybridEnabled;
    [sender setImage:_hybridEnabled?satellite_:satellite_deseleted_];
}

- (void)fitBoundPressed:(UIBarButtonItem *)sender
{
    [self fitBoundWithSender:sender];
}

#pragma mark - GMSMapViewDelegate


- (void)mapView:(GMSMapView *)mapView willMove:(BOOL)gesture
{
    if (gesture || marker_tapped_) {
        [self resignFitBound];
        marker_tapped_ = NO;
    }
}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker
{
    NSLog(@"Tapped Info Window of Marker: %@", marker);
}

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker
{
    NSLog(@"Tapped Marker: %@", marker);
    marker_tapped_ = YES;
    return NO;
}


@end
