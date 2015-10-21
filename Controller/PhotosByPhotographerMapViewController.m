//
//  PhotosByPhotographerMapViewController.m
//  Photomania
//
//  Created by Joseph Gordon on 9/30/15.
//  Copyright © 2015 Laura Gordon. All rights reserved.
//

#import "PhotosByPhotographerMapViewController.h"
#import <MapKit/MapKit.h>
#import "Photo.h"
#import "ImageViewController.h"

@interface PhotosByPhotographerMapViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) NSArray *photosByPhotographer;  //of photo objects

@end

@implementation PhotosByPhotographerMapViewController

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    static NSString *reuseId = @"PhotosByPhotographerMapViewController";
    MKAnnotationView *view = [mapView dequeueReusableAnnotationViewWithIdentifier:reuseId];
    
    if(!view){
        view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId];
        
        view.canShowCallout = YES;
        
        //add left callout button
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,46,46)];
        view.leftCalloutAccessoryView = imageView;
        
        //add right callout button
        UIButton *disclosureButton = [[UIButton alloc]init];
        [disclosureButton setBackgroundImage:[UIImage imageNamed:@"disclosure.png"] forState:UIControlStateNormal];
        [disclosureButton sizeToFit];
        view.rightCalloutAccessoryView = disclosureButton;
    }
    
    view.annotation = annotation;
    
    return view;
    
}

-(void) mapView:(MKMapView *)mapView didSelectAnnotationView:(nonnull MKAnnotationView *)view
{
    //only load teh left callout photo when the annotation view is selected
    [self updateLeftCalloutAccessoryViewInAnnotationView:view];
    
}

-(void) mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    //gets call when left or right uicontrol gets tapped.
    //segue inside of here
    [self performSegueWithIdentifier:@"Show Photo" sender:view];
    
}

-(void)prepareViewController:(id)vc
                    forSegue:(NSString *)segueIdentifier
            toShowAnnotation:(id <MKAnnotation>)annotation
{
    Photo *photo = nil;
    if([annotation isKindOfClass:[Photo class]]){
        photo = (Photo *)annotation;
    }
    if(photo){
        if(![segueIdentifier length] || [segueIdentifier isEqualToString:@"Show Photo"]) {
            if([vc isKindOfClass:[ImageViewController class]]) {
                ImageViewController *ivc = (ImageViewController *)vc;
                ivc.imageURL = [NSURL URLWithString:photo.imageURL];
                ivc.title = photo.title;
            }
        }
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([sender isKindOfClass:[MKAnnotationView class]]) {
        [self prepareViewController:segue.destinationViewController forSegue:segue.identifier toShowAnnotation:((MKAnnotationView *)sender).annotation];
    }
}

-(void) updateLeftCalloutAccessoryViewInAnnotationView:(MKAnnotationView *)annotationView
{
    UIImageView *imageView = nil;
    if([annotationView.leftCalloutAccessoryView isKindOfClass:[UIImageView class]]) {
        imageView = (UIImageView *)annotationView.leftCalloutAccessoryView;
    }
    if(imageView) {
        Photo *photo = nil;
        if([annotationView.annotation isKindOfClass:[Photo class]]) {
            photo = (Photo *)annotationView.annotation;
        }
        if(photo) {
#pragma - warning Blocking the main queue!
            imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:photo.thumbnailURL]]];
        }
    }
}

-(void) updateMapViewAnnotations;
{
    //updates the mapview annotations since we don't know if the map or photographer will get updated first call it from both.
    
    //first remove any annotation that is currently showing
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    //add
    [self.mapView addAnnotations:self.photosByPhotographer];

    //zoom map in to show the annotation
    [self.mapView showAnnotations:self.photosByPhotographer animated:YES];
    
    
}


-(void) setMapView:(MKMapView *)mapView
{
    _mapView = mapView;
    self.mapView.delegate = self;
    [self updateMapViewAnnotations]; //update the maps annotations
    
}

-(void)setPhotographer:(Photographer *)photographer
{
    _photographer = photographer;
    self.title = photographer.name;
    self.photosByPhotographer = nil;
    [self updateMapViewAnnotations]; //update the maps annotations
}

-(NSArray *)photosByPhotographer
{
    //if the photographer gets changed then change the photos
    if(!_photosByPhotographer) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
        request.predicate = [NSPredicate predicateWithFormat:@"whoTook = %@", self.photographer];
        _photosByPhotographer = [self.photographer.managedObjectContext executeFetchRequest:request error:NULL];
    }
    return _photosByPhotographer;
}
@end
