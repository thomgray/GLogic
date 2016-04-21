//
//  AllocationTestObject.m
//  GLogic
//
//  Created by Thomas Gray on 21/04/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "AllocationTestObject.h"

@implementation AllocationTestObject

@synthesize thing = _thing;

-(void)setThing:(AllocationTestObject *)thing{
    _thing = thing;
    thing.otherThing = self;
}
-(AllocationTestObject *)thing{
    return _thing;
}

@end
