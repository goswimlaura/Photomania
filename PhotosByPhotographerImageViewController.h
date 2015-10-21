//
//  PhotosByPhotographerImageViewController.h
//  Photomania
//
//  Created by Joseph Gordon on 10/1/15.
//  Copyright © 2015 Laura Gordon. All rights reserved.
// This subclass passes the photographer into the class.

#import "ImageViewController.h"
#import "Photographer.h"

@interface PhotosByPhotographerImageViewController : ImageViewController
@property (nonatomic, strong)Photographer *photographer;
@end
