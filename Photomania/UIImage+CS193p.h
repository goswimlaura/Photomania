//
//  UIImage+CS193p.h
//  Photomania
//
//  Created by Joseph Gordon on 10/5/15.
//  Copyright © 2015 Laura Gordon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (CS193p)

//makes a copy at a different size
- (UIImage *)imageByScalingToSize:(CGSize)size;

//applies filter
- (UIImage *)imageByApplyingFilterNamed:(NSString *)filterName;

@end
