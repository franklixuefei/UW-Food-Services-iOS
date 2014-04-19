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
#import "TLTransitionLayout.h"
enum State {Grid = 0, SmallList, DetailedList, TotalNumLayouts};

enum RestaurantsTableSection {
    RestaurantsTableWithMenuSection = 0,
    RestaurantsTableWithoutMenuSection,
    RestaurantsTableTotalSections
};

@interface RestaurantListViewController ()
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (nonatomic) enum State nextLayoutState;
@property (strong, nonatomic) UICollectionViewFlowLayout *gridLayout;
@property (strong, nonatomic) UICollectionViewFlowLayout *listLayout;
@property (strong, nonatomic) UICollectionViewFlowLayout *detailLayout;

- (void)configureCell:(RestaurantCollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)reload:(__unused id)sender;
- (void)didEndReload;
- (void)initBasicUI;
- (void)changeLayout:(__unused id)sender;
- (void)mapThem:(__unused id)sender;
- (void)handleSubviewsLayoutForCell:(RestaurantCollectionViewCell *)cell withProgress:(CGFloat)progress;
- (void)handleShadowAndCornerRadiusForCells:(NSArray *)cells;
@end

@implementation RestaurantListViewController {
    NSArray *_restaurantsWithMenu;
    NSArray *_restaurantsWithoutMenu;
    NSArray *_restaurantsMenu;
    NSArray *_menuDate;
    NSMutableArray *_cells;
    UIImage *_listLayoutImg;
    UIImage *_gridLayoutImg;
    UIImage *_gridDetailLayoutImg;
    enum State _currentLayoutState;
    BOOL _layoutAnimating;
    CGRect _cellImageViewFrame;
    NSIndexPath *_indexPathForFirstVisibleItem;
/*    UIActivityIndicatorView *_indicator; */
}


/*
- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}
 */

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
        _restaurantsWithMenu = [NSArray arrayWithArray:mutableRestaurantsWithMenu];
        for (NSDictionary *restaurant_info in restaurants_without_menu) {
            Restaurant *restaurant = [[Restaurant alloc] initWithAttributes:restaurant_info];
            [mutableRestaurantsWithoutMenu addObject:restaurant];
        }
        _restaurantsWithoutMenu = [NSArray arrayWithArray:mutableRestaurantsWithoutMenu];
        
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
    self.gridLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    self.listLayout = [[UICollectionViewFlowLayout alloc] init];
    self.detailLayout = [[UICollectionViewFlowLayout alloc] init];
    
    // initialize all layouts
    self.gridLayout.itemSize = RESTAURANT_COLLECTION_VIEW_CELL_SIZE_GRID;
    self.gridLayout.sectionInset = RESTAURANT_COLLECTION_VIEW_INSETS_GRID;
    self.gridLayout.minimumLineSpacing = RESTAURANT_COLLECTION_VIEW_MIN_LINE_SPACING_GRID;
    
    self.listLayout.itemSize = RESTAURANT_COLLECTION_VIEW_CELL_SIZE_LIST;
    self.listLayout.sectionInset = RESTAURANT_COLLECTION_VIEW_INSETS_LIST;
    self.listLayout.minimumLineSpacing = RESTAURANT_COLLECTION_VIEW_MIN_LINE_SPACING_LIST;
    
    self.detailLayout.itemSize = RESTAURANT_COLLECTION_VIEW_CELL_SIZE_DETAILED_LIST;
    self.detailLayout.sectionInset = RESTAURANT_COLLECTION_VIEW_INSETS_DETAILED_LIST;
    self.detailLayout.minimumLineSpacing = RESTAURANT_COLLECTION_VIEW_MIN_LINE_SPACING_DETAILED_LIST;
    
    self.gridLayout.minimumInteritemSpacing = self.listLayout.minimumInteritemSpacing = self.detailLayout.minimumInteritemSpacing = RESTAURANT_COLLECTION_VIEW_MIN_CELL_SPACING;
    self.listLayout.headerReferenceSize = self.detailLayout.headerReferenceSize = _gridLayout.headerReferenceSize;
    self.listLayout.footerReferenceSize = self.detailLayout.footerReferenceSize = _gridLayout.footerReferenceSize;
    
    self.listLayout.scrollDirection = self.detailLayout.scrollDirection = _gridLayout.scrollDirection;
    
    
    _cells = [NSMutableArray array];
    _layoutAnimating = NO;
    UINib *cellNib = [UINib nibWithNibName:@"RestaurantCollectionViewCell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:RESTAURANT_COLLECTION_VIEW_CELL_ID];
    [self initBasicUI];
    /* // for ipad version.
    self.detailViewController = (RestaurantDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
     */

    [self reload:nil];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    _indexPathForFirstVisibleItem = [self findMinIndexPathForArray:self.collectionView.indexPathsForVisibleItems];
}

- (void)initBasicUI
{
    _listLayoutImg = [[UIImage imageNamed:@"listlayout"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _gridLayoutImg = [[UIImage imageNamed:@"gridlayout"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _gridDetailLayoutImg = [[UIImage imageNamed:@"griddetaillayout"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _nextLayoutState = SmallList;
    _currentLayoutState = Grid;
    
    // init navigation controller
    UIBarButtonItem *layoutButton = [[UIBarButtonItem alloc] initWithImage:_listLayoutImg style:UIBarButtonItemStylePlain target:self action:@selector(changeLayout:)];
    self.navigationItem.rightBarButtonItem = layoutButton;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    UIBarButtonItem *mapThemButton = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"mapthem"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(mapThem:)];
    [layoutButton setImageInsets:BAR_BUTTON_ITEM_INSETS];
    [mapThemButton setImageInsets:BAR_BUTTON_ITEM_INSETS];
    /*
    _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _indicator.hidesWhenStopped = YES;
    UIBarButtonItem *indicatorItem = [[UIBarButtonItem alloc] initWithCustomView:_indicator];
     */
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
            [self.navigationItem.rightBarButtonItem setImage:_gridLayoutImg];
            break;
        case SmallList:
            [self.navigationItem.rightBarButtonItem setImage:_listLayoutImg];
            break;
        case DetailedList:
            [self.navigationItem.rightBarButtonItem setImage:_gridDetailLayoutImg];
            break;
        default:
            break;
    }
}

- (NSIndexPath*)findMinIndexPathForArray:(NSArray*)indexPaths
{
    if ([indexPaths count] <= 1) {
        return indexPaths.firstObject;
    }
    NSIndexPath *minIndexPath = indexPaths.firstObject;
    for (NSIndexPath *indexPath in indexPaths) {
        if ([indexPath compare:minIndexPath] == NSOrderedAscending) {
            minIndexPath = indexPath;
        }
    }
    return minIndexPath;
}

- (void)changeLayout:(id)sender
{
    if (_layoutAnimating) return;
    NSLog(@"change layout button pressed.");
    _currentLayoutState = _nextLayoutState;
    _indexPathForFirstVisibleItem = [self findMinIndexPathForArray:self.collectionView.indexPathsForVisibleItems];
    
    UICollectionViewLayout *toLayout = nil;
    switch (_currentLayoutState) {
        case Grid:
            toLayout = _gridLayout;
            break;
        case SmallList:
            toLayout = _listLayout;
            break;
        case DetailedList:
            toLayout = _detailLayout;
            break;
        default:
            break;
    }
    _layoutAnimating = YES;
    [self handleShadowAndCornerRadiusForCells:self.collectionView.visibleCells];
    TLTransitionLayout *layout = (TLTransitionLayout *)[self.collectionView transitionToCollectionViewLayout:toLayout duration:0.3f easing:CubicEaseInOut completion:^(BOOL completed, BOOL finish) {
        _layoutAnimating = NO;
        [self handleShadowAndCornerRadiusForCells:self.collectionView.visibleCells];
        if (completed && finish) {
            _indexPathForFirstVisibleItem = [self findMinIndexPathForArray:self.collectionView.indexPathsForVisibleItems];
        }
    }];
    
    CGPoint toOffset = [self.collectionView toContentOffsetForLayout:layout indexPaths:@[_indexPathForFirstVisibleItem] placement:TLTransitionLayoutIndexPathPlacementMinimal placementAnchor:kTLPlacementAnchorDefault placementInset:UIEdgeInsetsZero toSize:self.collectionView.bounds.size toContentInset:self.collectionView.contentInset];
    
    layout.toContentOffset = toOffset;
    [layout setUpdateLayoutAttributes:^UICollectionViewLayoutAttributes *(UICollectionViewLayoutAttributes *pose, UICollectionViewLayoutAttributes *fromPose, UICollectionViewLayoutAttributes *toPose, CGFloat progress) {

        RestaurantCollectionViewCell *cell = (RestaurantCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:pose.indexPath];
        if (cell) {
            [self handleSubviewsLayoutForCell:cell withProgress:progress];
            
        }
        return nil;
    }];
    /*
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
     */
    self.nextLayoutState = (_nextLayoutState + 1) % TotalNumLayouts;
    
}

#pragma mark - core method for layout animation

- (CGRect)calculateIntermediateFrameForCurrentFrame:(CGRect)currentFrame
                                          nextFrame:(CGRect)nextFrame
                                        andProgress:(CGFloat)progress
{
    return CGRectMake(
                      currentFrame.origin.x + (nextFrame.origin.x - currentFrame.origin.x) * progress,
                      currentFrame.origin.y + (nextFrame.origin.y - currentFrame.origin.y) * progress,
                      currentFrame.size.width + (nextFrame.size.width - currentFrame.size.width) * progress ,
                      currentFrame.size.height + (nextFrame.size.height - currentFrame.size.height) * progress);
}

- (CGFloat)calculateIntermediateAlphaForCurrentAlpha:(CGFloat)currentAlpha
                                           nextAlpha:(CGFloat)nextAlpha
                                         andProgress:(CGFloat)progress
{
    return currentAlpha + (nextAlpha - currentAlpha) * progress;
}

- (void)handleSubviewsLayoutForCell:(RestaurantCollectionViewCell *)cell withProgress:(CGFloat)progress
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
        
    cell.restaurantImageView.frame = [self calculateIntermediateFrameForCurrentFrame:cell.restaurantImageView.frame nextFrame:newLogoFrame andProgress:progress];
    cell.separator.frame = [self calculateIntermediateFrameForCurrentFrame:cell.separator.frame nextFrame:newSeparatorFrame andProgress:progress];
    cell.separator.alpha = [self calculateIntermediateAlphaForCurrentAlpha:cell.separator.alpha nextAlpha:separatorAlpha andProgress:progress];
    cell.titleLabel.frame = [self calculateIntermediateFrameForCurrentFrame:cell.titleLabel.frame nextFrame:newTitleFrame andProgress:progress];
    cell.titleLabel.alpha = [self calculateIntermediateAlphaForCurrentAlpha:cell.titleLabel.alpha nextAlpha:titleAlpha andProgress:progress];
    cell.buildingLabel.frame = [self calculateIntermediateFrameForCurrentFrame:cell.buildingLabel.frame nextFrame:newBuildingFrame andProgress:progress];
    cell.buildingIcon.frame = [self calculateIntermediateFrameForCurrentFrame:cell.buildingIcon.frame nextFrame:newBuildingIconFrame andProgress:progress];
    cell.hoursLabel.frame = [self calculateIntermediateFrameForCurrentFrame:cell.hoursLabel.frame nextFrame:newHourFrame andProgress:progress];
    cell.hoursIcon.frame = [self calculateIntermediateFrameForCurrentFrame:cell.hoursIcon.frame nextFrame:newHourIconFrame andProgress:progress];
    cell.openCloseLabel.frame = [self calculateIntermediateFrameForCurrentFrame:cell.openCloseLabel.frame nextFrame:newDotFrame andProgress:progress];
    cell.quote.frame = [self calculateIntermediateFrameForCurrentFrame:cell.quote.frame nextFrame:newQuoteFrame andProgress:progress];
    cell.quote.alpha = [self calculateIntermediateAlphaForCurrentAlpha:cell.quote.alpha nextAlpha:quoteAlpha andProgress:progress];
    cell.descriptionLabel.frame = [self calculateIntermediateFrameForCurrentFrame:cell.descriptionLabel.frame nextFrame:newDescriptionFrame andProgress:progress];
    cell.descriptionLabel.alpha = [self calculateIntermediateAlphaForCurrentAlpha:cell.descriptionLabel.alpha nextAlpha:descriptionAlpha andProgress:progress];
}

- (void)handleShadowAndCornerRadiusForCells:(NSArray *)cells
{
    for (RestaurantCollectionViewCell *cell in cells) {
        cell.layer.shadowPath = [UIBezierPath bezierPathWithRect:cell.bounds].CGPath;
        if (!_layoutAnimating) {
            cell.layer.shadowOpacity = 0.8f;
        } else {
            cell.layer.shadowOpacity = 0.0f;
        }
        if (_currentLayoutState != SmallList) {
            cell.layer.cornerRadius = 2.0f;
            cell.restaurantImageView.layer.cornerRadius = 2.0f;
        } else {
            cell.layer.cornerRadius = 0.0f;
            cell.restaurantImageView.layer.cornerRadius = 0.0f;
        }
    }
    
}


- (void)mapThem:(id)sender
{
    NSLog(@"mapThem button pressed.");
/*    
    [_indicator startAnimating];
 */
    
/* // First way - pushViewController
    RestaurantMapViewController *mapController = [self.storyboard instantiateViewControllerWithIdentifier:@"showMap"];
	[self.navigationController popToRootViewControllerAnimated:NO];
	[self.navigationController pushViewController:mapController animated:YES];
 */
    
/* // Second way - performSegueWithIdentifier */
    [self performSegueWithIdentifier:@"showMap" sender:sender];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"collectionView: %@ didSelectItemAtIndexPath: %@", collectionView, indexPath);
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"collectionView: %@ didDeselectItemAtIndexPath: %@", collectionView, indexPath);
}

- (UICollectionViewTransitionLayout *)collectionView:(UICollectionView *)collectionView transitionLayoutForOldLayout:(UICollectionViewLayout *)fromLayout newLayout:(UICollectionViewLayout *)toLayout
{
    TLTransitionLayout *layout = [[TLTransitionLayout alloc] initWithCurrentLayout:fromLayout nextLayout:toLayout supplementaryKinds:@[UICollectionElementKindSectionHeader, UICollectionElementKindSectionFooter]];
    return layout;
}


#pragma mark - toggle highlight
- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    [UIView animateWithDuration:0.1f animations:^{
        cell.transform = CGAffineTransformMakeScale(0.9f, 0.9f);
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
// a hack to put the refresh control behind other views.
    [_refreshControl removeFromSuperview];
    [self.collectionView insertSubview:_refreshControl atIndex:0];
    
    RestaurantCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:RESTAURANT_COLLECTION_VIEW_CELL_ID forIndexPath:indexPath];
    [self handleSubviewsLayoutForCell:cell withProgress:1.0f];
    [self handleShadowAndCornerRadiusForCells:@[cell]];
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
            headerView.header_title.text = @"Restaurants with Menu";
        } else if (indexPath.section == 1) { // without menu
            headerView.header_title.text = @"Other Restaurants";
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
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(50, 53);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeMake(50, 15);
}

/*
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
*/

#pragma mark
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showMap"]) {
        RestaurantMapViewController *mapViewController = [segue destinationViewController];
        mapViewController.delegate = self;
        mapViewController.restaurantsInfo = [_restaurantsWithMenu arrayByAddingObjectsFromArray:_restaurantsWithoutMenu];
    }
}

#pragma mark - RestaurantMapViewControllerDelegate

- (void)restaurantMapViewDidAppear
{
    /*
    [_indicator stopAnimating];
     */
}

/*
-(void) performSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    
}
*/




@end
