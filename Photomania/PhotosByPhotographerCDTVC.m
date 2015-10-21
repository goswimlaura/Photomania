//
//  PhotosByPhotographerCDTVC.m
//  Photomania
//
//  Created by Joseph Gordon on 9/29/15.
//  Copyright © 2015 Laura Gordon. All rights reserved.
//

#import "PhotosByPhotographerCDTVC.h"

@implementation PhotosByPhotographerCDTVC

-(void) setPhotographer:(Photographer *)photographer
{
    _photographer = photographer;
    self.title = photographer.name;
    [self setupFetchedResultsController];
}

- (void) setupFetchedResultsController
{
    //ask the photographer for its context because we get the photos from the same database that the photographer got his context from.
    NSManagedObjectContext *context = self.photographer.managedObjectContext;
    
    if(context){
        //get all the photos where whoTook is equal to the photographer and sort by the title of the photo.
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
        request.predicate = [NSPredicate predicateWithFormat:@"whoTook = %@", self.photographer];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title"
                                                                  ascending:YES
                                                                   selector:@selector(localizedStandardCompare:)]];
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:request
                                                                           managedObjectContext:context
                                                                             sectionNameKeyPath:nil
                                                                                      cacheName:nil];
    } else{
        //makes the table blank
        self.fetchedResultsController = nil;
    }
}

@end
