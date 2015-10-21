//
//  AddPhotoViewController.m
//  Photomania
//
//  Created by Joseph Gordon on 10/5/15.
//  Copyright © 2015 Laura Gordon. All rights reserved.
//

#import "AddPhotoViewController.h"
#import "Photo.h"
#import <CoreLocation/CoreLocation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "UIImage+CS193p.h"

@interface AddPhotoViewController () <UITextFieldDelegate, UIAlertViewDelegate, CLLocationManagerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextField *subtitleTextField;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) UIImage *image;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *location;
@property (strong, nonatomic) NSURL *imageURL;
@property (strong, nonatomic) NSURL *thumbnailURL;
@property (strong, nonatomic, readwrite) Photo *addPhoto;
@property (nonatomic) NSInteger locationErrorCode;
@end


@implementation AddPhotoViewController

//Check to be sure we have a camera available, can get an image, can check location status to be sure it is not restricted.
-(BOOL) canAddPhoto
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        if([availableMediaTypes containsObject:(NSString *)kUTTypeImage]){
            if([CLLocationManager authorizationStatus] != kCLAuthorizationStatusRestricted){
                //can take a photo
                return YES;
            }
        }
    }
    return NO;
}


-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    /*
     if(![[self class] canAddPhoto])
    {
        [self fatalAlter:@"Sorry, this device cannot add a photo because you do not have a photo."];
    }
     */
    
    //TURN IT ON start getting the current locations turning it on.
    [self.locationManager startUpdatingLocation];
    
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //TURN IT OFF turn off the location manager so it will stop. Note it is modal so not totally necessry here
    [self.locationManager stopUpdatingLocation];
}

-(void) viewDidLoad
{
    [super viewDidLoad];
    self.image = [UIImage imageNamed:@"cardimage.jpg"];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //when the return key on the keyboard is pressed it closes the keyboard.
    [textField resignFirstResponder];
    
    return YES;
}

#define UNWIND_SEGUE_IDENTIFIER @"Do Add Photo"

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:UNWIND_SEGUE_IDENTIFIER]){
        //CREATE the photo
        NSManagedObjectContext *context = self.photographerTakingPhoto.managedObjectContext;
        
        //if context of the photographer taking the photos is not nill we can add a photo
        if (context) {
            Photo *photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
            photo.title = self.titleTextField.text;
            photo.subtitle = self.subtitleTextField.text;
            photo.whoTook = self.photographerTakingPhoto;
            photo.latitude = @(self.location.coordinate.latitude);
            photo.longitude = @(self.location.coordinate.longitude);
            photo.imageURL = [self.imageURL absoluteString];
            photo.thumbnailURL = [self.thumbnailURL absoluteString];
            
            self.addedPhoto = photo;
            
            self.imageURL = nil; //this url has been used now
            self.thumbnailURL = nil;
        }
    }
}
-(BOOL) shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
  //checks to see if we should do the unwind prepareForSegue
  
    //if ([identifier isEqualtoString:UNWIND_SEGUE_IDENTIFIER]) {
        if (!self.image ) {
            [self alert:@"No photo taken!"];
            return NO;
        } else if (![self.titleTextField.text length]) {
                [self alert:@"Title required!"];
                return NO;
        } else if (self.location) {
            switch (self.locationErrorCode) {
                case kCLErrorLocationUnknown:
                    //it is still trying to figure out where the photo is yet, but i can keep trying.
                    [self alert:@"Couldn't figure out where this photo was taken yet."];
                    break;
                case kCLErrorDenied:
                    [self alert:@"Location Services disabled under Privacy in Settings application"];
                    break;
                case kCLErrorNetwork:
                    [self alert:@"Can't figure out where this photo is taken. Verify your connection to the network."];
                    break;
                default:
                    [self alert:@"Can't figure out where this photo is being taken, sorry."];
                    break;
            }
            return NO;
            
        } else { //should check location and imageURL too.
            return YES;
        }
    //} else {
        //return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
    //}
}

-(void) alert: (NSString *)msg
{
    /*[[[UIAlertView alloc] initWithTitle:@"Add Photo"
     message:msg delegate:nil
     cancelButtonTitle:nil
     otherButtonTitles:@"OK", nil] show];
    */
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Add Photo" message:msg preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Add Photo:";
        textField.secureTextEntry = NO;
    }];
    [self presentViewController:alert animated:YES completion:nil];
        
}


 -(void) fatalAlter:(NSString *)msg
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Add Photo" message:msg preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Add Photo:";
        textField.secureTextEntry = NO;
    }];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void) alertView:(UIAlertController *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self cancel];
}

- (CLLocationManager *) locationManager
{
    if(!_locationManager ) {
        CLLocationManager *locationManager = [[CLLocationManager alloc]init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager = locationManager;
    }
    return _locationManager;
}

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    //get teh last one because it is the most current
    self.location = [locations lastObject];
}

-(NSURL *)uniqueDocumentURL
{
    NSArray *documentDirectories = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    //NSString *unique = [NSString stringWithFormat:@"%.@f", floor([NSDate timeIntervalSinceReferenceDate])];
    NSString *unique = [NSString stringWithFormat:@"%f", floor([NSDate timeIntervalSinceReferenceDate])];
    return [[documentDirectories firstObject]URLByAppendingPathComponent:unique];
}

-(NSURL *)imageURL
{
    if(!_imageURL && self.image) {
        NSURL *url = [self uniqueDocumentURL];
        if (url) {
            NSData *imageData = UIImageJPEGRepresentation(self.image, 1.0);
            if ([imageData writeToURL:url atomically:YES]) {
                _imageURL = url;
            }
        }
    }
    return _imageURL;
}

- (NSURL *)thumbnailURL
{
    NSURL *url = [self.imageURL URLByAppendingPathExtension:@"thumbnail"];
    if(![_thumbnailURL isEqual:url]) {
        _thumbnailURL = nil;
        if(url) {
            UIImage *thumbnail = [self.image imageByScalingToSize:CGSizeMake(75, 75)];
            NSData *imageData = UIImageJPEGRepresentation(thumbnail, 0.5);
            if ([imageData writeToURL:url atomically:YES]){
                _thumbnailURL = url;
            }
        }
    }
    return _thumbnailURL;
}

-(void)setImage:(UIImage *)image
{
    self.imageView.image = image;
    
    //when the image is changed we must delete the urls we created if any.
    [[NSFileManager defaultManager] removeItemAtURL:_imageURL error:NULL];
    [[NSFileManager defaultManager] removeItemAtURL:_thumbnailURL error:NULL];
    self.imageURL = nil;
    self.thumbnailURL = nil;
}

-(UIImage *)image
{
    return  self.imageView.image;
}


- (IBAction)cancel
{
    //cleanup any temp files.
    self.image = nil;
    
    //dismissed the modal viewcontroller
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)takePhoto
{
    //modal camera takes over the screen
    UIImagePickerController *uiipc = [[UIImagePickerController alloc] init];
    uiipc.delegate = self;
    uiipc.mediaTypes = @[(NSString *)kUTTypeImage];
    uiipc.sourceType = UIImagePickerControllerSourceTypeCamera;
    uiipc.allowsEditing = YES;
    [self presentViewController:uiipc animated:YES completion:NULL];
    
    
}

-(void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *image = info[UIImagePickerControllerEditedImage];
    if(!image) image = info[UIImagePickerControllerOriginalImage];
    //set it to the image
    self.image = image;
    //dismiss the camera controller
    [self dismissViewControllerAnimated:YES completion:NULL];
}
@end
