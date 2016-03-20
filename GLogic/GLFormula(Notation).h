//
//  GLFormula(Notation).h
//  GLogic
//
//  Created by Thomas Gray on 14/03/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//


#import "GLFormula.h"

typedef NS_ENUM(NSUInteger, GLLanguageType) { GLLanguage_Alphabetic = 0, GLLanguage_Indexed = 1};
typedef NS_ENUM(NSUInteger, GLSyntaxType) { GLSyntax_Standard = 0, GLSyntax_Polish = 1};


@interface GLFormula (Notation)

-(GLLanguageType)defaultLanguage;
-(GLSyntaxType)defaultSyntax;

-(NSString*)stringWithSyntax:(GLSyntaxType)syntax andLanguage:(GLLanguageType)language;

#pragma mark PRIME FORMULAS
-(NSString*)stringForSentence:(GLSentence*)sentence syntax:(GLSyntaxType)syntax language:(GLLanguageType)language;
-(NSString*)stringForRelation:(GLRelation*)rel arguments:(NSArray<NSString*>*)args syntax:(GLSyntaxType)syntax language:(GLLanguageType)language;
-(NSString*)stringForEquals:(GLEquals*)equals arguments:(NSArray<NSString*>*)args syntax:(GLSyntaxType)syntax language:(GLLanguageType)language;

#pragma mark COMPOSITORS
-(NSString*)stringForConnective:(GLConnective*)conn composits:(NSArray<NSString*>*)comps syntax:(GLSyntaxType)syntax language:(GLLanguageType)language;
-(NSString*)stringForQuantifier:(GLQuantifier*)quant composit:(NSString*)comp variable:(NSString*)var syntax:(GLSyntaxType)syntax language:(GLLanguageType)language;

#pragma mark TERMS
-(NSString*)stringForVariable:(GLVariable*)var syntax:(GLSyntaxType)syntax language:(GLLanguageType)language;
-(NSString*)stringForConstant:(GLConstant*)cons syntax:(GLSyntaxType)syntax language:(GLLanguageType)language;
-(NSString*)stringForFunction:(GLFunction*)func arguments:(NSArray<NSString*>*)args syntax:(GLSyntaxType)syntax language:(GLLanguageType)language;

@end