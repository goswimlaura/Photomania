//
//  FlickrFetcher.h
//  Shutterbug
//
//  Created by Joseph Gordon on 9/22/15.
//  Copyright © 2015 Laura Gordon. All rights reserved.
//

#import <Foundation/Foundation.h>

//key paths to photos or places at top-level of Flickr results
#define FLICKR_RESULTS_PHOTOS @"photos.photo"  //.means follow dict
#define FLICKR_RESULTS_PLACES @"photos.places"

//key (paths) to values in a photo dictionary
#define FLICKR_PHOTO_TITLE @"title"
#define FLICKR_PHOTO_DESCRIPTION @"description._content"
#define FLICKR_PHOTO_ID @"id"
#define FLICKR_PHOTO_OWNER @"ownername"
#define FLICKR_PHOTO_PLACE_NAME @"derived_place"

//key (paths) to values in a places dictionary
#define FLICKR_PLACE_NAME @"_content"
#define FLICKR_PLACE_ID @"place_id"

//key applicabel to all types of Flickr dictionaries
#define FLICKR_LATITUDE @"latitude"
#define FLICKR_LONGITUDE @"longitude"
#define FLICKR_TAGS @"tags"

typedef enum{
    FlickrPhotoFormatSquare = 1, //thumbnail
    FlickrPhotoFormatLarge = 2,  //normal size
    FlickrPhotoFormatOriginal = 64, //high resolution
    
} FlickrPhotoFormat;

@interface FlickrFetcher: NSObject

+ (NSURL *) URLforTopPlaces;
+ (NSURL *) URLforPhotosInPlaces:(id)flickrPlaceId maxResults: (int)maxResults;
+ (NSURL *) URLforPhoto:(NSDictionary *)photo format:(FlickrPhotoFormat)format;
+ (NSURL *) URLforRecentGeoreferencedPhotos;

+ (NSURL *)URLforInformationAboutPlace:(id)flickrPlaceId;

+ (NSString *)extractNameOfPlace:(id)placeId fromPlaceInformation:(NSDictionary *)place;
+ (NSString *)extractRegionNameFromPlaceInformation:(NSDictionary *)placeInformation;

@end


