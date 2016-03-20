//
//  GLElement.h
//  GLogic
//
//  Created by Thomas Gray on 14/03/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GLElement : NSObject <NSCopying>

#pragma mark BASIC QUERYING

-(BOOL)isPrimeFormula;
-(BOOL)isSentence;
-(BOOL)isRelation;
-(BOOL)isEquals;

-(BOOL)isCompositor;
-(BOOL)isConnective;
-(BOOL)isQuantifier;

-(BOOL)isTerm;
-(BOOL)isConstant;
-(BOOL)isFunction;
-(BOOL)isVariable;

@end
