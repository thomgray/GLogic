//
//  GLFunction.m
//  GLogic
//
//  Created by Thomas Gray on 14/03/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "GLFunction.h"

@implementation GLFunction
-(BOOL)isFunction{ return true;}

-(BOOL)isEqual:(id)object{
    if ([object isKindOfClass:[GLFunction class]]) {
        GLFunction* func = (GLFunction*)object;
        if (self.arguments==NULL && func.arguments==NULL) return TRUE;
        else return [self.arguments isEqualToArray:func.arguments];
    }else return FALSE;
}

-(NSUInteger)hash{
    NSUInteger out = [GLFunction hash];
    out ^= self.index;
    for (NSInteger i=0; i<_arguments.count; i++) {
        out ^= [_arguments[i] hash] ^ i;
    }
    return out;
}

-(id)copyWithZone:(NSZone *)zone{
    GLFunction* out = [super copyWithZone:zone];
    out.arguments = self.arguments? [[NSArray alloc]initWithArray:self.arguments copyItems:YES]:NULL;
    return out;
}
@end
