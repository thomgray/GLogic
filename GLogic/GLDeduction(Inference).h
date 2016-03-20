//
//  GLDeduction(Inference).h
//  GLogic
//
//  Created by Thomas Gray on 16/03/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "GLDeductionBlocks.h"
#import "GLDeductionCheckList.h"

@interface GLDeduction (Inference)


-(BOOL)infer_undirected:(GLDeductionRuleUndirected)block;
-(BOOL)infer_allUndirected;

-(GLDedNode*)infer_directed:(GLFormula*)conclusion withBlock:(GLDeductionRuleDirected)block;
-(GLDedNode*)infer_allDirected:(GLFormula*)conclusion;

-(GLDedNode*)infer_conclusion:(GLFormula*)conc inferenceBlock:(GLInferenceBlock)block;
-(GLDedNode*)infer_conclusion:(GLFormula*)conc;

@end
