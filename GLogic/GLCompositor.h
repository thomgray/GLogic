//
//  GLCompositor.h
//  GLogic
//
//  Created by Thomas Gray on 14/03/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "GLElement.h"

@interface GLCompositor : GLElement


-(BOOL)isNegation;
-(BOOL)isConjunction;
-(BOOL)isDisjunction;
-(BOOL)isConditional;
-(BOOL)isBiconditional;
-(BOOL)isExistentialQuantifier;
-(BOOL)isUniversalQuantifier;

@end
