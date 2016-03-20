//
//  GLElement.m
//  GLogic
//
//  Created by Thomas Gray on 14/03/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "GLElement.h"

@implementation GLElement

-(BOOL)isPrimeFormula{ return false ;}
-(BOOL)isSentence{ return false; }
-(BOOL)isRelation{ return false; }
-(BOOL)isEquals{ return false;}

-(BOOL)isCompositor{ return false; }
-(BOOL)isConnective{ return false; }
-(BOOL)isQuantifier{ return false; }

-(BOOL)isTerm{ return false; }
-(BOOL)isFunction{ return false; }
-(BOOL)isVariable{ return false;}
-(BOOL)isConstant{ return false;}

-(id)copyWithZone:(NSZone *)zone{
    id out = [[self.class alloc]init];
    return out;
}

@end
