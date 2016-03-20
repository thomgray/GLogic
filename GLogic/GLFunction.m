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
    if ([super isEqual:object]) {
        GLFunction* func = (GLFunction*)object;
        if (self.arguments==NULL && func.arguments==NULL) return TRUE;
        else return [self.arguments isEqualToArray:func.arguments];
    }else return FALSE;
}

-(id)copyWithZone:(NSZone *)zone{
    GLFunction* out = [super copyWithZone:zone];
    out.arguments = self.arguments? [[NSArray alloc]initWithArray:self.arguments copyItems:YES]:NULL;
    return out;
}
@end
