//
//  Photo+Flickr.h
//  Photomania
//
//  Created by Joseph Gordon on 9/24/15.
//  Copyright © 2015 Laura Gordon. All rights reserved.
//

#import "Photo.h"

@interface Photo (Flickr)

//takes a flickr database and puts it into context
+(Photo *)photoWithFlickrInfo:(NSDictionary *)photoDictionary
       inManagedObjectContext:(NSManagedObjectContext *)context;

//of Flickr NSDictionary...call method above in bulk.
+(void) loadPhotosFromFlickrArray:(NSArray *)photos
    intoManagedObjectContext:(NSManagedObjectContext *)context;

@end
