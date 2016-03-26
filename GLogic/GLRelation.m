//
//  GLRelation.m
//  GLogic
//
//  Created by Thomas Gray on 14/03/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "GLRelation.h"

@implementation GLRelation
@synthesize arity;

-(NSUInteger)arity{
    return self.arguments.count;
}

-(BOOL)isRelation{return true;}

-(id)copyWithZone:(NSZone *)zone{
    GLRelation* out = [super copyWithZone:zone];
    out.index = self.index;
    out.arguments = self.arguments? [[NSArray alloc]initWithArray:self.arguments copyItems:YES]:NULL;
    return out;    
}

-(BOOL)isEqual:(id)object{
    if ([object isKindOfClass:[GLRelation class]]) {
        GLRelation* rel = (GLRelation*)object;
        if (rel.index!=self.index) return FALSE;
        if (rel.arity!=self.arity) return FALSE;
        if (self.arguments==NULL && rel.arguments==NULL) return TRUE;
        else return [self.arguments isEqualToArray:rel.arguments];
    }else return FALSE;
}

-(NSUInteger)hash{
    NSUInteger out = [GLRelation hash];
    for (NSInteger i=0; i<_arguments.count; i++) {
        out ^= [_arguments[i] hash] ^ i;
    }
    return out;
}

@end
