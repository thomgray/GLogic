//
//  GLSentence.m
//  GLogic
//
//  Created by Thomas Gray on 14/03/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "GLSentence.h"

@implementation GLSentence
@synthesize index;

-(instancetype)initWithIndex:(NSInteger)i{
    self = [super init];
    if (self) {
        index = i;
    }
    return self;
}

-(BOOL)isSentence{ return true;}
-(id)copyWithZone:(NSZone *)zone{
    GLSentence* out = [super copyWithZone:zone];
    out.index = index;
    return out;
}

-(BOOL)isEqual:(id)object{
    if ([object isMemberOfClass:self.class]) {
        GLSentence* sen = (GLSentence*)object;
        return sen.index==index;
    }else return FALSE;
}

@end
