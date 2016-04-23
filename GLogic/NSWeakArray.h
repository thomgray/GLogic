//
//  NSWeakArray.h
//  GLogic
//
//  Created by Thomas Gray on 22/04/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSWeakArray<__covariant ObjectType> : NSObject{
    NSArray* _wrapperArray;
}
@property (readonly) NSUInteger count;

-(instancetype)initWithArray:(NSArray*)array;
+(instancetype)arrayWithArray:(NSArray*)array;

-(NSArray<ObjectType>*)toArray;

-(ObjectType)objectAtIndex:(NSUInteger)idx;
-(ObjectType)objectAtIndexedSubscript:(NSUInteger)idx;


@end
