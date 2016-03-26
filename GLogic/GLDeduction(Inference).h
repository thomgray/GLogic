//
//  GLDeduction(Inference).h
//  GLogic
//
//  Created by Thomas Gray on 16/03/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "GLDeduction(Internal).h"
#import "GLDeductionBlocks.h"

@interface GLDeduction (Inference)

#pragma mark Generative Inferences
-(BOOL)proveGenerative;
-(BOOL)infer_GenerativeBlock:(GenerativeInferenceBlock)block;

#pragma mark Soft Inferences
-(GLDedNode*)proveSoft:(GLFormula*)conclusion;
-(GLDedNode*)infer_SoftBlock:(DirectedInferenceBlock)block conclusion:(GLFormula*)conc;
-(GLDedNode*)proveSoft_withCriterion:(GLFormulaCriterion)criterion includingNegations:(BOOL)includeNegs includingConclusion:(BOOL)includeConc;

#pragma mark Semi-Soft Inferences
-(GLDedNode*)proveSemiSoft:(GLFormula*)conclusion;
-(GLDedNode*)proveSemiSoft_withCriterion:(GLFormulaCriterion)criterion includingNegations:(BOOL)includeNegations includingConclusion:(BOOL)includeConclusion;
-(GLDedNode*)infer_SemiSoft_DE:(GLFormula *)conc;

#pragma mark Hard Inferences
-(GLDedNode*)proveHard:(GLFormula*)conclusion;

-(GLDedNode *)infer_HardBlock:(DirectedInferenceBlock)block conclusion:(GLFormula *)conc;
-(GLDedNode*)proveHard_withCriterion:(GLFormulaCriterion)criterion includingNegations:(BOOL)includeNegs includingConclusion:(BOOL)includeConclusion;

//Deconstructive inferences
-(GLDedNode *)infer_Hard_CE:(GLFormula *)conc;
-(GLDedNode *)infer_Hard_BE:(GLFormula *)conc;


-(GLDedNode *)infer_Hard_RAA:(GLFormula *)conc;
-(GLDedNode *)infer_Hard_DE:(GLFormula *)conc;


@end
