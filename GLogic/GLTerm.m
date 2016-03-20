//
//  GLTerm.m
//  GLogic
//
//  Created by Thomas Gray on 14/03/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "GLTerm.h"

@implementation GLTerm
-(BOOL)isTerm{ return true;}
-(BOOL)isEqual:(id)object{
    if ([object isMemberOfClass:self.class]) {
        GLTerm* t = (GLTerm*)object;
        return t.index == self.index;
    }else return FALSE;
}

-(id)copyWithZone:(NSZone *)zone{
    GLTerm* out = [super copyWithZone:zone];
    out.index = self.index;
    return out;
}
@end
