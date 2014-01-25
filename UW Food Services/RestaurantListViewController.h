//
//  MasterViewController.h
//  UW Food Services
//
//  Created by Frank Li on 12/14/2013.
//  Copyright (c) 2013 Xuefei Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RestaurantDetailViewController;

#import <CoreData/CoreData.h>
#import "RestaurantMapViewControllerDelegate.h"

@interface RestaurantListViewController : UICollectionViewController <NSFetchedResultsControllerDelegate, UICollectionViewDelegateFlowLayout, RestaurantMapViewControllerDelegate>

@property (strong, nonatomic) RestaurantDetailViewController *detailViewController;

//@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
//@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
