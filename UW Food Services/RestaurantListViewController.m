//
//  MasterViewController.m
//  UW Food Services
//
//  Created by Frank Li on 12/14/2013.
//  Copyright (c) 2013 Xuefei Li. All rights reserved.
//

#import "RestaurantListViewController.h"

#import "RestaurantDetailViewController.h"
#import "Restaurant.h"
#import "AFNetworking.h"
#import "FoodServer.h"
#import "RestaurantCollectionViewCell.h"
#import "RestaurantListSectionHeaderView.h"
#import "UIColor+HexColor.h"
#import "OpeningHours.h"
#import "FoodNull.h"
#import "NSString+HTML.h"
#import "RestaurantMapViewController.h"
#import "NSDate+dateToHHmmString.h"
#import <UIKit/UIKit.h>
#import "UINavigationController+NoAutorotate.h"

enum State {Grid = 0, SmallList, DetailedList, TotalNumLayouts};

enum RestaurantsTableSection {
    RestaurantsTableWithMenuSection = 0,
    RestaurantsTableWithoutMenuSection,
    RestaurantsTableTotalSections
};

@interface RestaurantListViewController ()
@property (readwrite, nonatomic, strong) NSArray *restaurantsWithMenu;
@property (readwrite, nonatomic, strong) NSArray *restaurantsWithoutMenu;
@property (readwrite, nonatomic, strong) NSArray *restaurantsMenu;
@property (readwrite, nonatomic, strong) NSArray *menuDate;
@property (readwrite, nonatomic) enum State nextLayoutState;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

- (void)configureCell:(RestaurantCollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)reload:(__unused id)sender;
- (void)didEndReload;
- (void)initBasicUI;
- (void)changeLayout:(__unused id)sender;
- (void)mapThem:(__unused id)sender;
- (void)handleSubviewsLayoutForCell:(RestaurantCollectionViewCell *)cell animated:(BOOL)animated;
- (void)handleShadowAndCornerRadiusForCell:(RestaurantCollectionViewCell *)cell animated:(BOOL)animated;
@end

@implementation RestaurantListViewController {
    NSMutableArray *_cells;
    UIImage *_listLayout;
    UIImage *_gridLayout;
    UIImage *_gridDetailLayout;
    enum State _currentLayoutState;
    BOOL _layoutAnimating;
    CGRect _cellImageViewFrame;
//    UIActivityIndicatorView *_indicator;
}

@synthesize restaurantsWithMenu = _restaurantsWithMenu;
@synthesize restaurantsWithoutMenu = _restaurantsWithoutMenu;
@synthesize restaurantsMenu = _restaurantsMenu;
@synthesize menuDate = _menuDate;
@synthesize nextLayoutState = _nextLayoutState;
@synthesize refreshControl = _refreshControl;

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)reload:(__unused id)sender {
    self.navigationItem.leftBarButtonItem.enabled = NO;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [[FoodServer defaultServer] restaurantsInfoWithTypeArray:@[API_OUTLETS_TYPE, API_LOCATIONS_TYPE, API_MENU_TYPE] andProgressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
        
    } andSuccessBlock:^(NSDictionary *parsedData) {
        NSLog(@"parsedData: %@", parsedData);
        NSArray *restaurants_menu = [parsedData valueForKey:RESTA_MENU];
        NSArray *restaurants_with_menu = [parsedData valueForKey:RESTA_WTIH_MENU];
        NSArray *restaurants_without_menu = [parsedData valueForKey:RESTA_WTIHOUT_MENU];
        NSDictionary *restaurants_menu_date_info = [parsedData valueForKey:RESTA_MENU_DATE_INFO];
        NSMutableArray *mutableRestaurantsWithMenu = [NSMutableArray arrayWithCapacity:[restaurants_with_menu count]];
        NSMutableArray *mutableRestaurantsWithoutMenu = [NSMutableArray arrayWithCapacity:[restaurants_without_menu count]];
        for (NSDictionary *restaurant_info in restaurants_with_menu) {
            Restaurant *restaurant = [[Restaurant alloc] initWithAttributes:restaurant_info];
            [mutableRestaurantsWithMenu addObject:restaurant];
        }
        self.restaurantsWithMenu = [NSArray arrayWithArray:mutableRestaurantsWithMenu];
        for (NSDictionary *restaurant_info in restaurants_without_menu) {
            Restaurant *restaurant = [[Restaurant alloc] initWithAttributes:restaurant_info];
            [mutableRestaurantsWithoutMenu addObject:restaurant];
        }
        self.restaurantsWithoutMenu = [NSArray arrayWithArray:mutableRestaurantsWithoutMenu];
        
        // TODO: initiate Menu objects.
        [_cells removeAllObjects];
        for (int i = 0; i < [_restaurantsWithMenu count] + [_restaurantsWithoutMenu count]; ++i) {
            CGSize currentSize = CGSizeZero;
            switch (_currentLayoutState) {
                case Grid:
                    currentSize = RESTAURANT_COLLECTION_VIEW_CELL_SIZE_GRID;
                    break;
                case SmallList:
                    currentSize = RESTAURANT_COLLECTION_VIEW_CELL_SIZE_LIST;
                    break;
                case DetailedList:
                    currentSize = RESTAURANT_COLLECTION_VIEW_CELL_SIZE_DETAILED_LIST;
                    break;
                default:
                    break;
            }
            [_cells addObject:[NSValue valueWithCGSize:currentSize]]; // grid layout by default.
        }
        
        dispatch_async(dispatch_get_main_queue(), ^
                       {
                           [self.collectionView reloadData];
                       });
        [self didEndReload];
        
    } andFailureBlock:^(NSError *error) {
        NSLog(@"error: %@, with type: (see the following line) ", error);
        if (error) {
            // show error messages according to the following error types
            switch (error.code) {
                case NSURLErrorNetworkConnectionLost:
                    NSLog(@"NSURLErrorNetworkConnectionLost");
                    break;
                case NSURLErrorNotConnectedToInternet:
                    NSLog(@"NSURLErrorNotConnectedToInternet");
                    break;
                case NSURLErrorTimedOut:
                    NSLog(@"NSURLErrorTimedOut");
                    break;
                case NSURLErrorCancelled:
                    NSLog(@"NSURLErrorCancelled");
                    break;
                default: // unknown error
                    NSLog(@"NSURLError - unknown with code %ld", (long)error.code);
                    break;
            }
        } else { // All operations completed with error.
            NSLog(@"All operations completed with error");
            [self didEndReload];
        }
    }];
    
}

- (void)didEndReload
{
    self.navigationItem.leftBarButtonItem.enabled = YES;
    self.navigationItem.rightBarButtonItem.enabled = YES;
    [_refreshControl performSelector:@selector(endRefreshing) withObject:nil afterDelay:1.0f];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    _cells = [NSMutableArray array];
    _layoutAnimating = NO;
    UINib *cellNib = [UINib nibWithNibName:@"RestaurantCollectionViewCell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:RESTAURANT_COLLECTION_VIEW_CELL_ID];
    [self initBasicUI];
//    self.detailViewController = (RestaurantDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];

    [self reload:nil];
}

- (void)initBasicUI
{
    _listLayout = [[UIImage imageNamed:@"listlayout"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _gridLayout = [[UIImage imageNamed:@"gridlayout"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _gridDetailLayout = [[UIImage imageNamed:@"griddetaillayout"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _nextLayoutState = SmallList;
    _currentLayoutState = Grid;
    
    // init navigation controller
    UIBarButtonItem *layoutButton = [[UIBarButtonItem alloc] initWithImage:_listLayout style:UIBarButtonItemStylePlain target:self action:@selector(changeLayout:)];
    self.navigationItem.rightBarButtonItem = layoutButton;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    UIBarButtonItem *mapThemButton = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"mapthem"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(mapThem:)];
    [layoutButton setImageInsets:BAR_BUTTON_ITEM_INSETS];
    [mapThemButton setImageInsets:BAR_BUTTON_ITEM_INSETS];
//    _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//    _indicator.hidesWhenStopped = YES;
//    UIBarButtonItem *indicatorItem = [[UIBarButtonItem alloc] initWithCustomView:_indicator];
    self.navigationItem.leftBarButtonItems = @[mapThemButton/*, indicatorItem*/];
    self.navigationItem.leftBarButtonItem.enabled = NO;
    self.collectionView.backgroundColor = [UIColor colorWithHexValue:0xdddddd andAlpha:1];
    self.title = SCREEN_NAME_RESTAURANT_LIST;
    self.navigationItem.title = SCREEN_NAME_RESTAURANT_LIST;
    
    // init refresh control
    if (!_refreshControl) { // init refresh control
        _refreshControl = [[UIRefreshControl alloc] init];
        [_refreshControl addTarget:self action:@selector(reload:) forControlEvents:UIControlEventValueChanged];
        [self.collectionView addSubview:_refreshControl];
    }
    [_refreshControl beginRefreshing];
    
    // init background view
    UIImage *bgImage = [UIImage imageNamed:@"delicious_food.jpg"];
    self.collectionView.backgroundView = [[UIImageView alloc] initWithImage:bgImage];
    self.collectionView.backgroundView.layer.opacity = 0.6f;
    self.collectionView.backgroundView.autoresizingMask =UIViewAutoresizingNone;
    self.collectionView.backgroundView.contentMode = UIViewContentModeCenter;
    
}

- (void)setNextLayoutState:(enum State)nextLayoutState
{
    _nextLayoutState = nextLayoutState;
    switch (_nextLayoutState) {
        case Grid:
            [self.navigationItem.rightBarButtonItem setImage:_gridLayout];
            break;
        case SmallList:
            [self.navigationItem.rightBarButtonItem setImage:_listLayout];
            break;
        case DetailedList:
            [self.navigationItem.rightBarButtonItem setImage:_gridDetailLayout];
            break;
        default:
            break;
    }
}

- (void)changeLayout:(id)sender
{
    if (_layoutAnimating) return;
    [self.collectionView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    NSLog(@"change layout button pressed.");
    _currentLayoutState = _nextLayoutState;
    [self.collectionView performBatchUpdates:^{
        for (int i = 0; i < [_cells count]; ++i) { // reset cell size corresponding to current layout
            switch (_currentLayoutState) {
                case Grid:
                    [_cells setObject:[NSValue valueWithCGSize:RESTAURANT_COLLECTION_VIEW_CELL_SIZE_GRID] atIndexedSubscript:i];
                    break;
                case DetailedList:
                    [_cells setObject:[NSValue valueWithCGSize:RESTAURANT_COLLECTION_VIEW_CELL_SIZE_DETAILED_LIST] atIndexedSubscript:i];
                    break;
                case SmallList:
                    [_cells setObject:[NSValue valueWithCGSize:RESTAURANT_COLLECTION_VIEW_CELL_SIZE_LIST] atIndexedSubscript:i];
                    break;
                default:
                    break;
            }
        }
        _layoutAnimating = YES;

        for (RestaurantCollectionViewCell *cell in self.collectionView.visibleCells) {
            cell.layer.shadowOpacity = 0.0f;
            [self handleSubviewsLayoutForCell:cell animated:YES];
            [self handleShadowAndCornerRadiusForCell:cell animated:YES];
        }
        
    } completion:^(BOOL finished) {
        _layoutAnimating = NO;
        for (RestaurantCollectionViewCell *cell in self.collectionView.visibleCells) {
            [self handleShadowAndCornerRadiusForCell:cell animated:NO];
        }
    }];
    self.nextLayoutState = (_nextLayoutState + 1) % TotalNumLayouts;
    
}

#pragma mark - core method for layout animation
- (void)handleSubviewsLayoutForCell:(RestaurantCollectionViewCell *)cell animated:(BOOL)animated
{
    CGRect newLogoFrame = CGRectZero;
    CGRect newSeparatorFrame = CGRectZero;
    CGFloat separatorAlpha = 0.0f;
    CGRect newTitleFrame = CGRectZero;
    CGFloat titleAlpha = 0.0f;
    CGRect newBuildingIconFrame = CGRectZero;
    CGRect newBuildingFrame = CGRectZero;
    CGRect newHourIconFrame = CGRectZero;
    CGRect newHourFrame = CGRectZero;
    CGRect newDotFrame = CGRectZero;
    CGRect newQuoteFrame = CGRectZero;
    CGFloat quoteAlpha = 0.0f;
    CGRect newDescriptionFrame = CGRectZero;
    CGFloat descriptionAlpha = 0.0f;
    switch (_currentLayoutState) {
        case Grid:
            newLogoFrame = GRID_LAYOUT_LOGO_FRAME;
            newSeparatorFrame = GRID_LAYOUT_SEPARATOR_FRAME;
            separatorAlpha = 0.0f;
            newTitleFrame = GRID_LAYOUT_TITLE_FRAME;
            titleAlpha = 0.0f;
            newBuildingFrame = GRID_LAYOUT_BUILDING_FRAME;
            newBuildingIconFrame = GRID_LAYOUT_BUILDING_ICON_FRAME;
            newHourFrame = GRID_LAYOUT_HOURS_FRAME;
            newHourIconFrame = GRID_LAYOUT_HOURS_ICON_FRAME;
            newDotFrame = GRID_LAYOUT_DOT_FRAME;
            newQuoteFrame = GRID_LAYOUT_QUOTE_FRAME;
            quoteAlpha = 0.0f;
            newDescriptionFrame = GRID_LAYOUT_DESCRIPTION_FRAME;
            descriptionAlpha = 0.0f;
            break;
        case SmallList:
            newLogoFrame = LIST_LAYOUT_LOGO_FRAME;
            newSeparatorFrame = LIST_LAYOUT_SEPARATOR_FRAME;
            separatorAlpha = 1.0f;
            newTitleFrame = LIST_LAYOUT_TITLE_FRAME;
            titleAlpha = 1.0f;
            newBuildingFrame = LIST_LAYOUT_BUILDING_FRAME;
            newBuildingIconFrame = LIST_LAYOUT_BUILDING_ICON_FRAME;
            newHourFrame = LIST_LAYOUT_HOURS_FRAME;
            newHourIconFrame = LIST_LAYOUT_HOURS_ICON_FRAME;
            newDotFrame = LIST_LAYOUT_DOT_FRAME;
            newQuoteFrame = LIST_LAYOUT_QUOTE_FRAME;
            quoteAlpha = 0.0f;
            newDescriptionFrame = LIST_LAYOUT_DESCRIPTION_FRAME;
            descriptionAlpha = 0.0f;
            break;
        case DetailedList:
            newLogoFrame = DETAIL_LAYOUT_LOGO_FRAME;
            newSeparatorFrame = DETAIL_LAYOUT_SEPARATOR_FRAME;
            separatorAlpha = 1.0f;
            newTitleFrame = DETAIL_LAYOUT_TITLE_FRAME;
            titleAlpha = 1.0f;
            newBuildingFrame = DETAIL_LAYOUT_BUILDING_FRAME;
            newBuildingIconFrame = DETAIL_LAYOUT_BUILDING_ICON_FRAME;
            newHourFrame = DETAIL_LAYOUT_HOURS_FRAME;
            newHourIconFrame = DETAIL_LAYOUT_HOURS_ICON_FRAME;
            newDotFrame = DETAIL_LAYOUT_DOT_FRAME;
            newQuoteFrame = DETAIL_LAYOUT_QUOTE_FRAME;
            quoteAlpha = 1.0f;
            newDescriptionFrame = DETAIL_LAYOUT_DESCRIPTION_FRAME;
            descriptionAlpha = 1.0f;
            break;
        default:
            break;
    }
    [UIView animateWithDuration:animated?0.3f:0 animations:^{
        cell.restaurantImageView.frame = newLogoFrame;
        cell.separator.frame = newSeparatorFrame;
        cell.separator.alpha = separatorAlpha;
        cell.titleLabel.frame = newTitleFrame;
        cell.titleLabel.alpha = titleAlpha;
        cell.buildingLabel.frame = newBuildingFrame;
        cell.buildingIcon.frame = newBuildingIconFrame;
        cell.hoursLabel.frame = newHourFrame;
        cell.hoursIcon.frame = newHourIconFrame;
        cell.openCloseLabel.frame = newDotFrame;
        cell.quote.frame = newQuoteFrame;
        cell.quote.alpha = quoteAlpha;
        cell.descriptionLabel.frame = newDescriptionFrame;
        cell.descriptionLabel.alpha = descriptionAlpha;
    }];
}

- (void)handleShadowAndCornerRadiusForCell:(RestaurantCollectionViewCell *)cell animated:(BOOL)animated
{
    cell.layer.shadowPath = [UIBezierPath bezierPathWithRect:cell.bounds].CGPath;
    [UIView animateWithDuration:animated?0.3f:0 animations:^{
        
        if (_layoutAnimating) {
            cell.layer.shadowOpacity = 0.0f;
            cell.layer.cornerRadius = 2.0f;
        } else if (_currentLayoutState != SmallList) {
            cell.layer.shadowOpacity = 0.8f;
            cell.layer.cornerRadius = 2.0f;
        } else {
            cell.layer.cornerRadius = 0.0f;
        }
        
        if (_currentLayoutState == SmallList) {
            cell.restaurantImageView.layer.cornerRadius = 2.0f;
        } else {
            cell.restaurantImageView.layer.cornerRadius = 0.0f;
        }
        
    }];
}


- (void)mapThem:(id)sender
{
    NSLog(@"mapThem button pressed.");
//    [_indicator startAnimating];

    
    /* First way */
//    RestaurantMapViewController *mapController = [self.storyboard instantiateViewControllerWithIdentifier:@"showMap"];
//	[self.navigationController popToRootViewControllerAnimated:NO];
//	[self.navigationController pushViewController:mapController animated:YES];
    
    /* Second way */
    [self performSegueWithIdentifier:@"showMap" sender:sender];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)insertNewObject:(id)sender
//{
//    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
//    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
//    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
//    
//    // If appropriate, configure the new managed object.
//    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
//    [newManagedObject setValue:[NSDate date] forKey:@"timeStamp"];
//    
//    // Save the context.
//    NSError *error = nil;
//    if (![context save:&error]) {
//         // Replace this implementation with code to handle the error appropriately.
//         // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
//        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//        abort();
//    }
//}


#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"collectionView: %@ didSelectItemAtIndexPath: %@", collectionView, indexPath);
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"collectionView: %@ didDeselectItemAtIndexPath: %@", collectionView, indexPath);
}


#pragma mark - toggle highlight
- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    [UIView animateWithDuration:0.05f animations:^{
        cell.transform = CGAffineTransformMakeScale(0.95f, 0.95f);
    }];
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    [UIView animateWithDuration:0.05f animations:^{
        cell.transform = CGAffineTransformIdentity;
    }];
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger numItems = 0;
    switch (section) {
        case RestaurantsTableWithMenuSection:
            numItems = [_restaurantsWithMenu count];
            break;
        case RestaurantsTableWithoutMenuSection:
            numItems = [_restaurantsWithoutMenu count];
            break;
        default:
            break;
    }
    return numItems;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return RestaurantsTableTotalSections;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
//        NSLog(@"collectionView subviews: %@", self.collectionView.subviews);
    [_refreshControl removeFromSuperview];
    [self.collectionView insertSubview:_refreshControl atIndex:0];
    RestaurantCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:RESTAURANT_COLLECTION_VIEW_CELL_ID forIndexPath:indexPath];
    [self handleSubviewsLayoutForCell:cell animated:NO];
    [self handleShadowAndCornerRadiusForCell:cell animated:YES];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        RestaurantListSectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:RESTAURANT_COLLECTION_VIEW_HEADER_ID forIndexPath:indexPath];
        [headerView.header_title setFont:[UIFont fontWithName:@"Cookie" size:20.0f]];
        if (indexPath.section == 0) { // restaurants with menu
            headerView.header_title.text = @"Restaurants with menu";
        } else if (indexPath.section == 1) { // without menu
            headerView.header_title.text = @"Other restaurants";
        }
        
        reusableview = headerView;
    }
    if (kind == UICollectionElementKindSectionFooter) {
        UICollectionReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:RESTAURANT_COLLECTION_VIEW_FOOTER_ID forIndexPath:indexPath];
        reusableview = footerView;
    } 
    return reusableview;
}



#pragma mark - Configure Cell

- (void)configureCell:(RestaurantCollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        Restaurant *r = nil;
        switch (indexPath.section) {
            case RestaurantsTableWithMenuSection:
                r = [_restaurantsWithMenu objectAtIndex:indexPath.item];
                break;
            case RestaurantsTableWithoutMenuSection:
                r = [_restaurantsWithoutMenu objectAtIndex:indexPath.item];
                break;
            default:
                break;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [cell setImageURL:r.logoURL];
            [cell.buildingLabel setText:[NSString stringWithFormat:@"Today @ %@", r.building]];
            [cell.hoursLabel setTextColor:[UIColor blackColor]];
            [cell.hoursLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:12.0f]];
            [cell.titleLabel setText:r.outletName];
            [cell.openCloseLabel setTextColor:r.is_open_now?[UIColor greenColor]:[UIColor lightGrayColor]];
            [cell.descriptionLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f]];
            [cell.descriptionLabel setTextColor:[UIColor darkGrayColor]];
            if ([FoodNull isNSNullOrNil:r.outletDescription]) {
                [cell.descriptionLabel setText:[NSString stringWithFormat:@"There is no description available for %@.", r.outletName]];
                [cell.descriptionLabel setFont:[UIFont fontWithName:@"HelveticaNeue-LightItalic" size:12.0f]];
                [cell.descriptionLabel setTextColor:[UIColor lightGrayColor]];
            } else {
                [cell.descriptionLabel setText:[r.outletDescription stringByDecodingHTMLEntities]];
            }
            if (!r.opening_hours.today.is_closed) {
                [cell.hoursLabel setText:[NSString stringWithFormat:@"%@ - %@", r.opening_hours.today.opening_hour.dateToStringWithHHmmFormat, r.opening_hours.today.closing_hour.dateToStringWithHHmmFormat]];
            } else {
                [cell.hoursLabel setText:@"Closed today"];
                [cell.hoursLabel setFont:[UIFont fontWithName:@"HelveticaNeue-LightItalic" size:12.0f]];
                [cell.hoursLabel setTextColor:[UIColor lightGrayColor]];
            }

        });
    });
    
    
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSValue *sizeValue = [_cells objectAtIndex:indexPath.item];
    return [sizeValue CGSizeValue];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    UIEdgeInsets insets;
    switch (_currentLayoutState) {
        case Grid:
            insets = RESTAURANT_COLLECTION_VIEW_INSETS_GRID;
            break;
        case DetailedList:
            insets = RESTAURANT_COLLECTION_VIEW_INSETS_DETAILED_LIST;
            break;
        case SmallList:
            insets = RESTAURANT_COLLECTION_VIEW_INSETS_LIST;
            break;
        default:
            break;
    }
    return insets;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    CGFloat minLineSpacing = 0;
    switch (_currentLayoutState) {
        case Grid:
            minLineSpacing = RESTAURANT_COLLECTION_VIEW_MIN_LINE_SPACING_GRID;
            break;
        case DetailedList:
            minLineSpacing = RESTAURANT_COLLECTION_VIEW_MIN_LINE_SPACING_DETAILED_LIST;
            break;
        case SmallList:
            minLineSpacing = RESTAURANT_COLLECTION_VIEW_MIN_LINE_SPACING_LIST;
            break;
        default:
            break;
    }
    return minLineSpacing;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return RESTAURANT_COLLECTION_VIEW_MIN_CELL_SPACING;
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showMap"]) {
        RestaurantMapViewController *mapViewController = [segue destinationViewController];
        mapViewController.delegate = self;
        mapViewController.restaurantsInfo = [_restaurantsWithMenu arrayByAddingObjectsFromArray:_restaurantsWithoutMenu];
    }
}

#pragma mark - RestaurantMapViewControllerDelegate methods

- (void)restaurantMapViewDidAppear
{
//    [_indicator stopAnimating];
}

//-(void) performSegueWithIdentifier:(NSString *)identifier sender:(id)sender
//{
//    
//}

//
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
//{
//    
//}
//
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
//{
//    
//}


#pragma mark - Table View

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
////    return [[self.fetchedResultsController sections] count];
//    return RestaurantsTableTotalSections;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    NSInteger numRows = 0;
//    switch (section) {
//        case RestaurantsTableWithMenuSection:
//            numRows = [_restaurantsWithMenu count];
//            break;
//        case RestaurantsTableWithoutMenuSection:
//            numRows = [_restaurantsWithoutMenu count];
//            break;
//        default:
//            break;
//    }
////    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
////    return [sectionInfo numberOfObjects];
//    return numRows;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
//    [self configureCell:cell atIndexPath:indexPath];
//    return cell;
//}
//
//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    // Return NO if you do not want the specified item to be editable.
//    return YES;
//}
//
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
//        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
//        
//        NSError *error = nil;
//        if (![context save:&error]) {
//             // Replace this implementation with code to handle the error appropriately.
//             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
//            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//            abort();
//        }
//    }   
//}
//
//- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    // The table view should not be re-orderable.
//    return NO;
//}
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
//        NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
//        self.detailViewController.detailItem = object;
//    }
//}
//
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    if ([[segue identifier] isEqualToString:@"showDetail"]) {
//        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
//        NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
//        [[segue destinationViewController] setDetailItem:object];
//    }
//}
//
//#pragma mark - Fetched results controller
//
//- (NSFetchedResultsController *)fetchedResultsController
//{
//    if (_fetchedResultsController != nil) {
//        return _fetchedResultsController;
//    }
//    
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    // Edit the entity name as appropriate.
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
//    [fetchRequest setEntity:entity];
//    
//    // Set the batch size to a suitable number.
//    [fetchRequest setFetchBatchSize:20];
//    
//    // Edit the sort key as appropriate.
//    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:NO];
//    NSArray *sortDescriptors = @[sortDescriptor];
//    
//    [fetchRequest setSortDescriptors:sortDescriptors];
//    
//    // Edit the section name key path and cache name if appropriate.
//    // nil for section name key path means "no sections".
//    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
//    aFetchedResultsController.delegate = self;
//    self.fetchedResultsController = aFetchedResultsController;
//    
//	NSError *error = nil;
//	if (![self.fetchedResultsController performFetch:&error]) {
//	     // Replace this implementation with code to handle the error appropriately.
//	     // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
//	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//	    abort();
//	}
//    
//    return _fetchedResultsController;
//}    
//
//- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
//{
//    [self.tableView beginUpdates];
//}
//
//- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
//           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
//{
//    switch(type) {
//        case NSFetchedResultsChangeInsert:
//            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//            
//        case NSFetchedResultsChangeDelete:
//            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//    }
//}
//
//- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
//       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
//      newIndexPath:(NSIndexPath *)newIndexPath
//{
//    UITableView *tableView = self.tableView;
//    
//    switch(type) {
//        case NSFetchedResultsChangeInsert:
//            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//            
//        case NSFetchedResultsChangeDelete:
//            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//            
//        case NSFetchedResultsChangeUpdate:
//            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
//            break;
//            
//        case NSFetchedResultsChangeMove:
//            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//    }
//}
//
//- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
//{
//    [self.tableView endUpdates];
//}

/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 */



@end
