//
//  MasterViewController.h
//  ContactsSyncSampleApp
//
//  Created by Saad Masood on 11/11/14.
//  Copyright (c) 2014 QBXNet Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface MasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;


@end

