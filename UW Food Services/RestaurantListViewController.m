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
#import "GlobalConstants.h"
#import "AFNetworking.h"
#import "FoodServer.h"
#import "RestaurantCollectionViewCell.h"
#import "UIColor+HexColor.h"
#import <UIKit/UIKit.h>

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
- (void)configureCell:(RestaurantCollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)reload:(__unused id)sender;
- (void)initBasicUI;
- (void)changeLayout:(__unused id)sender;
- (void)mapThem:(__unused id)sender;
@end

@implementation RestaurantListViewController {
    NSMutableArray *_cells;
    UIImage *_listLayout;
    UIImage *_gridLayout;
    UIImage *_gridDetailLayout;
    enum State _currentLayoutState;
}

@synthesize restaurantsWithMenu = _restaurantsWithMenu;
@synthesize restaurantsWithoutMenu = _restaurantsWithoutMenu;
@synthesize restaurantsMenu = _restaurantsMenu;
@synthesize menuDate = _menuDate;
@synthesize nextLayoutState = _nextLayoutState;

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)reload:(__unused id)sender {

//    self.navigationItem.rightBarButtonItem.enabled = NO;
    [FoodServer restaurantsInfoWithTypeArray:@[API_OUTLETS_TYPE, API_LOCATIONS_TYPE, API_MENU_TYPE] andProgressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
        
    } andSuccessBlock:^(NSDictionary *parsedData) {
//        NSLog(@"parsedData: %@", parsedData);
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
            [_cells addObject:[NSValue valueWithCGSize:RESTAURANT_COLLECTION_VIEW_CELL_SIZE_GRID]]; // grid layout by default.
        }
        
        dispatch_async(dispatch_get_main_queue(), ^
                       {
                           [self.collectionView reloadData];
                           
                       });
        
    } andFailureBlock:^(NSError *error) {
        NSLog(@"error: %@", error);
    }];
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    _cells = [NSMutableArray array];
    UINib *cellNib = [UINib nibWithNibName:@"RestaurantCollectionViewCell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:RESTAURANT_COLLECTION_VIEW_CELL_ID];
    [self initBasicUI];
//    self.detailViewController = (RestaurantDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];

    [self reload:nil];
}

- (void)initBasicUI
{
    _listLayout = [UIImage imageNamed:@"listlayout"];
    _gridLayout = [UIImage imageNamed:@"gridlayout"];
    _gridDetailLayout = [UIImage imageNamed:@"griddetaillayout"];
    _nextLayoutState = SmallList;
    _currentLayoutState = Grid;
    UIBarButtonItem *layoutButton = [[UIBarButtonItem alloc] initWithImage:_listLayout style:UIBarButtonItemStylePlain target:self action:@selector(changeLayout:)];
    self.navigationItem.leftBarButtonItem = layoutButton;
    UIBarButtonItem *mapThemButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"mapthem"] style:UIBarButtonItemStylePlain target:self action:@selector(mapThem:)];
    self.navigationItem.rightBarButtonItem = mapThemButton;
    self.collectionView.backgroundColor = [UIColor colorWithHexValue:0xdddddd andAlpha:1];
    self.title = SCREEN_NAME_RESTAURANT_LIST;
}

- (void)setNextLayoutState:(enum State)nextLayoutState
{
    _nextLayoutState = nextLayoutState;
    switch (_nextLayoutState) {
        case Grid:
            [self.navigationItem.leftBarButtonItem setImage:_gridLayout];
            break;
        case SmallList:
            [self.navigationItem.leftBarButtonItem setImage:_listLayout];
            break;
        case DetailedList:
            [self.navigationItem.leftBarButtonItem setImage:_gridDetailLayout];
            break;
        default:
            break;
    }
}

- (void)changeLayout:(id)sender
{
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
        for (RestaurantCollectionViewCell *cell in self.collectionView.visibleCells) {
            cell.layer.shadowOpacity = 0.0f;
        }
    } completion:^(BOOL finished) {
        for (RestaurantCollectionViewCell *cell in self.collectionView.visibleCells) {
            cell.layer.shadowPath = [UIBezierPath bezierPathWithRect:cell.bounds].CGPath;
            cell.layer.shadowOpacity = 0.8f;
        }
    }];
    self.nextLayoutState = (_nextLayoutState + 1) % TotalNumLayouts;
    
}


- (void)mapThem:(id)sender
{
    NSLog(@"mapThem button pressed.");
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

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"collectionView: %@ didHighlightItemAtIndexPath: %@", collectionView, indexPath);
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"collectionView: %@ didUnhighlightItemAtIndexPath: %@", collectionView, indexPath);
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
    RestaurantCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:RESTAURANT_COLLECTION_VIEW_CELL_ID forIndexPath:indexPath];
    cell.layer.shadowPath = [UIBezierPath bezierPathWithRect:cell.bounds].CGPath;
    [self configureCell:cell atIndexPath:indexPath];
    // TODO: add data here.
    return cell;
}

//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
//{
//    
//}

#pragma mark - Configure Cell

- (void)configureCell:(RestaurantCollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
//    NSLog(@"configuring collection view cells...");
    NSURL *url = nil;
    Restaurant *r = nil;
    switch (indexPath.section) {
        case RestaurantsTableWithMenuSection:
            r = [_restaurantsWithMenu objectAtIndex:indexPath.item];
            url = r.logoURL;
            break;
        case RestaurantsTableWithoutMenuSection:
            r = [_restaurantsWithoutMenu objectAtIndex:indexPath.item];
            url = r.logoURL;
            break;
        default:
            break;
    }
    [cell setImageURL:url];
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
