//
//  AddPhotoViewController.h
//  Photomania
//
//  Created by Joseph Gordon on 10/5/15.
//  Copyright © 2015 Laura Gordon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Photographer.h"
#import "Photo.h"

@interface AddPhotoViewController : UIViewController

// IN
@property(nonatomic, strong) Photographer *photographerTakingPhoto;

// OUT
@property (nonatomic, strong) Photo *addedPhoto;
@end
