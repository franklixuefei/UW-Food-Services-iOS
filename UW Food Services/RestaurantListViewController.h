//
//  MasterViewController.h
//  UW Food Services
//
//  Created by Frank Li on 12/14/2013.
//  Copyright (c) 2013 Xuefei Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TLIndexPathTools/TLCollectionViewController.h>
#import <TLLayoutTransitioning/UICollectionView+TLTransitioning.h>
#import "easing.h"

@class RestaurantDetailViewController;

#import <CoreData/CoreData.h>
#import "RestaurantMapViewControllerDelegate.h"

@interface RestaurantListViewController : TLCollectionViewController <NSFetchedResultsControllerDelegate, UICollectionViewDelegateFlowLayout, RestaurantMapViewControllerDelegate>

@property (strong, nonatomic) RestaurantDetailViewController *detailViewController;

//@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
//@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
