//
//  PhotographersCDTVC.h
//  Photomania
//
//  Created by Joseph Gordon on 9/24/15.
//  Copyright © 2015 Laura Gordon. All rights reserved.
//

#import "CoreDataTableViewController.h"

@interface PhotographersCDTVC : CoreDataTableViewController

//show all photographers in a database
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
