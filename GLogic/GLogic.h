//
//  GLogic.h
//  GLogic
//
//  Created by Thomas Gray on 14/03/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import <Cocoa/Cocoa.h>

//! Project version number for GLogic.
FOUNDATION_EXPORT double GLogicVersionNumber;

//! Project version string for GLogic.
FOUNDATION_EXPORT const unsigned char GLogicVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <GLogic/PublicHeader.h>

//Formula
#import "GLFormula.h"
#import "GLFormula(Notation).h"
#import "GLFormula(Operations).h"

//Element
#import "GLElement.h"
#import "GLPrimeFormula.h"
#import "GLSentence.h"
#import "GLRelation.h"
#import "GLEquals.h"

#import "GLTerm.h"
#import "GLVariable.h"
#import "GLFunction.h"
#import "GLConstant.h"

#import "GLCompositor.h"
#import "GLConnective.h"
#import "GLQuantifier.h"

//Deduction

#import "GLDedNode.h"
#import "GLDeductionSequence.h"
//#import "GLDeduction(Inference).h"
#import "GLDeduction.h"

