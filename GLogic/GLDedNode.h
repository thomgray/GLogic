//
//  GLDedNode.h
//  GLogic
//
//  Created by Thomas Gray on 16/03/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "GLFormula(Operations).h"

@class GLDeduction;


typedef enum {
    //SL Inferences
    GLInference_Premise, GLInference_Reiteration,
    GLInference_AssumptionCP, GLInference_AssumptionRAA, GLInference_AssumptionDE,
    GLInference_ConjunctionIntro, GLInference_ConjunctionElim,
    GLInference_DisjunctionIntro, GLInference_DisjunctionElim,
    GLInference_DNE, GLInference_DNI,
    GLInference_BiconditionalIntro, GLInference_BiconditionalElim,
    GLInference_ModusPonens, GLInference_ModusTollens,
    GLInference_ConditionalProof, GLInference_ConditionalProofDE,
    GLInference_ReductioAA
} GLInferenceRule;

@interface GLDedNode : NSObject

@property GLFormula* formula;
@property GLInferenceRule inferenceRule;
@property NSArray<GLDedNode*>* dependencies;
@property NSArray<GLDedNode*>* inferenceNodes;
@property GLDeduction* subProof;

-(instancetype)initWithFormula:(GLFormula*)form inference:(GLInferenceRule)inf;
-(void)inheritDependencies:(NSArray<GLDedNode*>*) nodes;
+(instancetype)infer:(GLInferenceRule)inf formula:(GLFormula*)form withNodes:(NSArray<GLDedNode*>*)nodes;

@end

typedef BOOL(^GLDedNodeCriterion)(GLDedNode* node);
