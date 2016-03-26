//
//  GLConnective.m
//  GLogic
//
//  Created by Thomas Gray on 14/03/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "GLConnective.h"

@implementation GLConnective
@synthesize type;

-(instancetype)initWithType:(GLConnectiveType)typ{
    self = [super init];
    if (self) {
        type = typ;
    }
    return self;
}

-(id)copyWithZone:(NSZone *)zone{
    GLConnective* out = [super copyWithZone:zone];
    out.type = self.type;
    return out;
}

-(BOOL)isEqual:(id)object{
    if ([object isKindOfClass:[GLConnective class]]) {
        GLConnective* con = (GLConnective*)object;
        return type==con.type;
    }else return FALSE;
}
-(NSUInteger)hash{
    return [GLConnective hash] ^ (NSUInteger)type;
}

-(BOOL)isConnective{ return true; }
-(BOOL)isNegation{
    return type==GLConnectiveType_Negation;
}
-(BOOL)isConjunction{
    return type==GLConnectiveType_Conjunction;
}
-(BOOL)isDisjunction{
    return type==GLConnectiveType_Disjunction;
}
-(BOOL)isConditional{
    return type==GLConnectiveType_Conditional;
}
-(BOOL)isBiconditional{
    return type==GLConnectiveType_Biconditional;
}

+(instancetype)makeNegation{
    return [[self alloc]initWithType:GLConnectiveType_Negation];
}
+(instancetype)makeConjunction{
    return [[self alloc]initWithType:GLConnectiveType_Conjunction];
}
+(instancetype)makeDisjunction{
    return [[self alloc]initWithType:GLConnectiveType_Disjunction];
}
+(instancetype)makeConditional{
    return [[self alloc]initWithType:GLConnectiveType_Conditional];
}
+(instancetype)makeBiconditional{
    return [[self alloc]initWithType:GLConnectiveType_Biconditional];
}
@end
