//
//  GLVariable.m
//  GLogic
//
//  Created by Thomas Gray on 14/03/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "GLVariable.h"

@implementation GLVariable
@synthesize index;

-(instancetype)initWithIndex:(NSInteger)i{
    self = [super init];
    if (self) {
        index = i;
    }
    return self;
}

-(BOOL)isEqual:(id)object{
    if ([object isKindOfClass:[GLVariable class]]) {
        GLTerm* t = (GLTerm*)object;
        return t.index == self.index;
    }else return FALSE;
}

-(NSUInteger)hash{
    return [GLVariable hash] ^ index;
}

-(BOOL)isVariable{ return true; }
@end
