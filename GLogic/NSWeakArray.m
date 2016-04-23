//
//  NSWeakArray.m
//  GLogic
//
//  Created by Thomas Gray on 22/04/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "NSWeakArray.h"

@interface Wrapper : NSObject
@property (weak) id thing;
+(instancetype)wrapperWithObject:(id)obj;
@end

@implementation Wrapper
+(instancetype)wrapperWithObject:(id)obj{
    Wrapper* w = [[self alloc]init];
    [w setThing: obj];
    return w;
}
@end

@implementation NSWeakArray

//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//
#pragma mark Initialising & Copying
//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//

-(instancetype)initWithArray:(NSArray *)array{
    self = [super init];
    if (self) {
        NSMutableArray* wrappers = [[NSMutableArray alloc]init];
        for (NSInteger i=0; i<array.count; i++) {
            Wrapper* wrapper = [Wrapper wrapperWithObject:array[i]];
            [wrappers addObject:wrapper];
        }
        _wrapperArray = [NSArray arrayWithArray:wrappers];
    }
    return self;
}

+(instancetype)arrayWithArray:(NSArray *)array{
    return [[self alloc]initWithArray:array];
}

-(NSArray *)toArray{
    NSMutableArray* arr = [[NSMutableArray alloc]init];
    for (NSInteger i=0; i<_wrapperArray.count; i++) {
        [arr addObject:((Wrapper*)_wrapperArray[i]).thing];
    }
    return [NSArray arrayWithArray:arr];
}

//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//
#pragma mark Querying
//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//

-(NSUInteger)count{
    return _wrapperArray.count;
}

-(id)objectAtIndex:(NSUInteger)index{
    return ((Wrapper*)[_wrapperArray objectAtIndex:index]).thing;
}
-(id)objectAtIndexedSubscript:(NSUInteger)idx{
    return ((Wrapper*)[_wrapperArray objectAtIndexedSubscript:idx]).thing;
}


@end
