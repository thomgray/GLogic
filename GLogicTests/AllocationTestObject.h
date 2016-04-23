//
//  AllocationTestObject.h
//  GLogic
//
//  Created by Thomas Gray on 21/04/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLogic/NSWeakArray.h>

@interface AllocationTestObject : NSObject 


@property NSString* string;
@property (weak) id thing;
@property NSWeakArray* array;

@end
