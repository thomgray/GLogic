//
//  GLDeduction(Blocks).h
//  GLogic
//
//  Created by Thomas Gray on 17/03/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "GLDeduction.h"

@interface GLInferenceResult : NSObject
@property GLFormula* conclusion;
@property NSArray<GLFormula*>* steps;
@property GLInferenceRule rule;
+(instancetype)rule:(GLInferenceRule)rule conclusion:(GLFormula*)conclusion steps:(NSArray<GLFormula*>*)steps;
@end

typedef NSArray<GLDedNode*>*(^GLDeductionRuleUndirected)(GLDedNode* node, GLDeduction* ded);
typedef GLDedNode*(^GLDeductionRuleDirected)(GLFormula* conc, GLDeduction* ded);

/*
 For inferences that can recur safely, if one can make an inference on the condition that some steps are present/provable, then this block will be of use
 */
typedef GLInferenceResult* (^GLInferenceBlock)(GLFormula* conclusion);

@interface GLDeductionBlocks: NSObject

+(GLDeductionRuleUndirected)CjE_Undirected;
+(GLDeductionRuleUndirected)BcdE_Undirected;
+(GLDeductionRuleUndirected)MP_Undirected;
+(GLDeductionRuleUndirected)DNE_Undirected;

+(GLDeductionRuleDirected)CjI_Directed;
+(GLDeductionRuleDirected)DjI_Directed;
+(GLDeductionRuleDirected)BcdI_Directed;
+(GLDeductionRuleDirected)DNI_Directed;

#pragma mark Result Blocks

+(GLInferenceBlock)ConjunctionI;
+(GLInferenceBlock)DNI;
+(GLInferenceBlock)BiconditionalI;


@end

