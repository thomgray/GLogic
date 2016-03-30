//
//  GLFormula.h
//  GLogic
//
//  Created by Thomas Gray on 14/03/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLElement.h"
#import "GLRelation.h"
#import "GLEquals.h"
#import "GLSentence.h"
#import "GLVariable.h"
#import "GLFunction.h"
#import "GLConstant.h"
#import "GLConnective.h"
#import "GLQuantifier.h"

@interface GLFormula : NSObject <NSCopying>

@property (nonatomic) NSArray<GLFormula*>* children;
@property (nonatomic) GLElement* rootElement;

#pragma mark Inits

-(instancetype)initWithPrimeFormula:(GLPrimeFormula*)form;

#pragma mark Basic Getting/Setting

#pragma mark Basic Querying

-(GLCompositor*)mainConnective;
-(GLConnective*)mainConnective:(GLConnectiveType)type;
-(GLQuantifier*)mainQuantifier:(GLQuantifierType)type;
-(GLPrimeFormula*)primeFormula;

-(instancetype)firstDecomposition;
-(instancetype)secondDecomposition;
-(instancetype)getDecomposition:(NSInteger)i;
-(instancetype)getDecompositionAtNode:(NSArray<NSNumber*>*)node;
-(NSSet<GLFormula*>*)getAllDecompositions;

-(BOOL)isPrime;
-(BOOL)isComposite;

-(BOOL)isNegation;
-(BOOL)isDoubleNegation;
-(BOOL)isConjunction;
-(BOOL)isDisjunction;
-(BOOL)isConditional;
-(BOOL)isBiconditional;
-(BOOL)isUniversalQualtifier;
-(BOOL)isExistentialQuantifier;

#pragma mark Operations

//Building
-(void)doNegation;
-(void)doNegationStrict;
-(void)doConjunction:(GLPrimeFormula*)pf keepLeft:(BOOL)left;
-(void)doDisjunction:(GLPrimeFormula*)pf keepLeft:(BOOL)left;
-(void)doConditional:(GLPrimeFormula*)pf keepLeft:(BOOL)left;
-(void)doBiconditional:(GLPrimeFormula*)pf keepLeft:(BOOL)left;
-(void)doQuantification:(GLQuantifier*)quant;

//Constructing
+(instancetype)makeNegation:(GLFormula*)form;
+(instancetype)makeNegationStrict:(GLFormula*)form;
+(instancetype)makeConjunction:(GLFormula*)f1 f2:(GLFormula*)f2;
+(instancetype)makeDisjunction:(GLFormula*)f1 f2:(GLFormula*)f2;
+(instancetype)makeConditional:(GLFormula*)f1 f2:(GLFormula*)f2;
+(instancetype)makeBiconditional:(GLFormula*)f1 f2:(GLFormula*)f2;
+(instancetype)makeQuantification:(GLQuantifier*)quant formula:(GLFormula*)form;

@end
