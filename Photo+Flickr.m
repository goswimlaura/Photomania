//
//  Photo+Flickr.m
//  Photomania
//
//  Created by Joseph Gordon on 9/24/15.
//  Copyright © 2015 Laura Gordon. All rights reserved.
//

#import "Photo+Flickr.h"
#import "FlickrFetcher.h"
#import "Photographer+Create.h"


@implementation Photo (Flickr)


//takes a flickr database
+(Photo *)photoWithFlickrInfo:(NSDictionary *)photoDictionary
       inManagedObjectContext:(NSManagedObjectContext *)context;
{
    Photo *photo = nil;
    
    //Find the photo
    
    //See if photo is already there in the photo table based upon unique the key field in flickr
    NSString *unique = photoDictionary[FLICKR_PHOTO_ID]; //gets unique key from flickr
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"unique = %@", unique];
    
    //get the photo that matches
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    
    if(!matches || error ||([matches count] > 1)){
        //handle error more than one of the same photo
    }else if ([matches count]){
        photo = [matches firstObject];
    }else{
        //we have zero matches so empty array so it doesn't exist so create it
        photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo"
                                              inManagedObjectContext:context];
        
        photo.unique = unique;
        photo.title = [photoDictionary valueForKeyPath:FLICKR_PHOTO_TITLE];
        photo.subtitle = [photoDictionary valueForKey:FLICKR_PHOTO_DESCRIPTION];
        photo.imageURL = [[FlickrFetcher URLforPhoto:photoDictionary format:FlickrPhotoFormatLarge] absoluteString];
        photo.latitude = @([photoDictionary [FLICKR_LATITUDE]doubleValue]);
        photo.longitude = @([photoDictionary[FLICKR_LONGITUDE]doubleValue]);
        photo.thumbnailURL = [[FlickrFetcher URLforPhoto:photoDictionary format:FlickrPhotoFormatSquare]absoluteString];
        NSString *photographerName = [photoDictionary valueForKeyPath:FLICKR_PHOTO_OWNER];
        photo.whoTook = [Photographer photographerWithName:photographerName
                                    inManagedObjectContext:context];
                         
        
    }
                            
    
    return photo;
}

//of Flickr NSDictionary
+ (void) loadPhotosFromFlickrArray:(NSArray *)photos
         intoManagedObjectContext:(NSManagedObjectContext *)context;
{
    for (NSDictionary *photo in photos){
        [self photoWithFlickrInfo:photo inManagedObjectContext:context];
    }
}
@end
