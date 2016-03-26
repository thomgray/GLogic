//
//  GLQuantifier.m
//  GLogic
//
//  Created by Thomas Gray on 14/03/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "GLQuantifier.h"

@implementation GLQuantifier
-(BOOL)isQuantifier{ return true; }

-(instancetype)initWithType:(GLQuantifierType)type variable:(GLVariable *)var{
    self = [super init];
    if (self) {
        _type = type;
        _boundVariable = var;
    }
    return self;
}

+(instancetype)makeExistentialQuantifierWithVariable:(NSInteger)idx{
    return [[self alloc]initWithType:GLQuantifierType_Existential variable:GLMakeVariable(idx)];
}
+(instancetype)makeUniversalQuantifierWithVariable:(NSInteger)idx{
    return [[self alloc]initWithType:GLQuantifierType_Universal variable:GLMakeVariable(idx)];
}

-(id)copyWithZone:(NSZone *)zone{
    GLQuantifier* out = [super copyWithZone:zone];
    out.type = self.type;
    out.boundVariable = [self.boundVariable copyWithZone:zone];
    return out;
}

-(BOOL)isEqual:(id)object{
    if ([object isKindOfClass:[GLQuantifier class]]) {
        GLQuantifier* q = (GLQuantifier*)object;
        if (q.type!=self.type) return FALSE;
        return [q.boundVariable isEqual:self.boundVariable];
    }else return FALSE;
}

-(NSUInteger)hash{
    return [GLQuantifier hash] ^ [_boundVariable hash] ^ (NSUInteger)_type;
}

-(BOOL)isUniversalQuantifier{
    return self.type == GLQuantifierType_Universal;
}
-(BOOL)isExistentialQuantifier{
    return self.type == GLQuantifierType_Existential;
}
@end
