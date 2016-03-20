//
//  GLCompositor.m
//  GLogic
//
//  Created by Thomas Gray on 14/03/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "GLCompositor.h"

@implementation GLCompositor

-(BOOL)isCompositor{ return true; }
-(BOOL)isNegation{ return false; }
-(BOOL)isConjunction{ return false; }
-(BOOL)isDisjunction{ return false; }
-(BOOL)isConditional{ return false; }
-(BOOL)isBiconditional{ return false; }
-(BOOL)isExistentialQuantifier{ return false; }
-(BOOL)isUniversalQuantifier{ return false; }

@end
