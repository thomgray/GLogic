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

-(instancetype)init{
    self = [super init];
    if (self) {
        _thing = @"Hello in there";
    }
    return self;
}
@end
