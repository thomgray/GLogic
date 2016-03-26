//
//  NSSet(Internal).h
//  GLogic
//
//  Created by Thomas Gray on 25/03/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSSet<ObjectType> (Internal)

-(instancetype)subsetWithScheme:(BOOL(^)(ObjectType object))scheme;

@end
