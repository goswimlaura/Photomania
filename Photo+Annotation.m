//
//  Photo+Annotation.m
//  Photomania
//
//  Created by Joseph Gordon on 9/30/15.
//  Copyright © 2015 Laura Gordon. All rights reserved.
//

#import "Photo+Annotation.h"

@implementation Photo (Annotation)

-(CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D coordinate;
    
    coordinate.latitude =[self.latitude doubleValue];
    coordinate.longitude = [self.longitude doubleValue];
    
    return coordinate;
}

@end
