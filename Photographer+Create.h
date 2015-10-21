//
//  Photographer+Create.h
//  Photomania
//
//  Created by Joseph Gordon on 9/24/15.
//  Copyright © 2015 Laura Gordon. All rights reserved.
//

#import "Photographer.h"

@interface Photographer (Create)

+ (Photographer *)userInManagedObjectContext:(NSManagedObjectContext *)context;

- (BOOL)isUser;

+(Photographer *) photographerWithName:(NSString *)name
               inManagedObjectContext:(NSManagedObjectContext *)context;


@end
