//
//  GLEquals.m
//  GLogic
//
//  Created by Thomas Gray on 14/03/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "GLEquals.h"

@implementation GLEquals
-(BOOL)isEquals{ return true;}

-(BOOL)isEqual:(id)object{
    if ([object isKindOfClass:[GLEquals class]]) {
        GLEquals* eq = (GLEquals*)object;
        if (![self.leftTerm isEqual:eq.leftTerm]) return FALSE;
        return [self.rightTerm isEqual:eq.rightTerm];
    }else return FALSE;
}

-(NSUInteger)hash{
    NSUInteger out = [GLEquals hash];
    out ^= [_leftTerm hash] ^ 1;
    out ^= [_rightTerm hash] ^ 2;
    return out;
}

-(id)copyWithZone:(NSZone *)zone{
    GLEquals* out = [super copyWithZone:zone];
    out.leftTerm = [self.leftTerm copyWithZone:zone];
    out.rightTerm = [self.rightTerm copyWithZone:zone];
    return out;
}



@end
