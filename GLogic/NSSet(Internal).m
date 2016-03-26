//
//  NSSet(Internal).m
//  GLogic
//
//  Created by Thomas Gray on 25/03/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "NSSet(Internal).h"

@implementation NSSet (Internal)

-(instancetype)subsetWithScheme:(BOOL (^)(id))scheme{
    NSArray * objects = [self allObjects];
    NSSet * out = [[self.class alloc]init];
    for (NSInteger i=0; i<objects.count; i++) {
        id object = objects[i];
        if (scheme(object)) {
            out = [out setByAddingObject:object];
        }
    }
    return out;
}


@end
