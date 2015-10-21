//
//  PhotosByPhotographerImageViewController.m
//  Photomania
//
//  Created by Joseph Gordon on 10/1/15.
//  Copyright © 2015 Laura Gordon. All rights reserved.
//

#import "PhotosByPhotographerImageViewController.h"
#import "PhotosByPhotographerMapViewController.h"
#import "Photographer+Create.h"
#import "AddPhotoViewController.h"

@interface PhotosByPhotographerImageViewController()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addPhotoBarButtonItem;
@property (nonatomic, strong) PhotosByPhotographerMapViewController *mapvc;
@end

@implementation PhotosByPhotographerImageViewController

-(void) setPhotographer:(Photographer *)photographer
{
    _photographer = photographer;
    self.title = photographer.name;
    //set photographer here and in prepareForSegue because we don't know which is going to get called first.
    self.mapvc.photographer = self.photographer;
    
    //Method called to determine if we show the camera barbuttonitem
    [self updateAddPhotoBarButtonItem];
}

- (void)updateAddPhotoBarButtonItem
{
    
    //show the camera bar button item
    if(self.addPhotoBarButtonItem) {
        BOOL canAddPhoto = self.photographer.isUser;
        NSMutableArray *rightBarButtonItems = [self.navigationItem.rightBarButtonItems mutableCopy];
        if(!rightBarButtonItems) rightBarButtonItems = [[NSMutableArray alloc] init];
        NSUInteger addPhotoBarButtonItemIndex = [rightBarButtonItems indexOfObject:self.addPhotoBarButtonItem];
        if (addPhotoBarButtonItemIndex == NSNotFound) {
            if (canAddPhoto) {
                [rightBarButtonItems addObject:self.addPhotoBarButtonItem];
            }
        }else {
            if(!canAddPhoto) [rightBarButtonItems removeObjectAtIndex:addPhotoBarButtonItemIndex];
            //int myTest = self.navigationItem.rightBarButtonItems.count;
        }
        self.navigationItem.rightBarButtonItems = rightBarButtonItems;
    }
    
}

//Unwind for the modal segue of AddPhotoViewController
-(IBAction)addedPhoto:(UIStoryboardSegue *)segue
{
    //make sure the source is an add photo view controller
    if ([segue.sourceViewController isKindOfClass:[AddPhotoViewController class]])
    {
        AddPhotoViewController *apvc = (AddPhotoViewController *)segue.sourceViewController;
        Photo *addedPhoto = apvc.addedPhoto;
        if(addedPhoto)
        {
            //show the photo on the map and its annotation
            //[self.mapView addAnnotation:addedPhoto];
            //[self.mapView showAnnotation:@[addedPhoto] animated:YES];
            
        } else {
            NSLog(@"AddPhotoViewController unexpectedly did not add a photo!");
        }
    }
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //this is preparing for the modal segue that displays the AddPhotoViewController when the camera button is pressed.
    if ([segue.destinationViewController isKindOfClass:[AddPhotoViewController class]])
    {
        AddPhotoViewController *apvc = (AddPhotoViewController *)segue.destinationViewController;
        BOOL canAddPhoto = self.photographer.isUser;
        if (canAddPhoto) {
            apvc.photographerTakingPhoto = self.photographer;
        }
    }
    
    //this is preparing for the embedded segue that displays the map.
    if([segue.destinationViewController isKindOfClass:[PhotosByPhotographerMapViewController class]]){
        PhotosByPhotographerMapViewController *pbpmapvc = (PhotosByPhotographerMapViewController *)segue.destinationViewController;
        //set photographer here and in setPhotographer because we dont know which is going to get called first.
        pbpmapvc.photographer = self.photographer;
        self.mapvc = pbpmapvc;
    }else {
        [super prepareForSegue:segue sender:sender];
    }
}
@end
