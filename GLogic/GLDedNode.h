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

-(void)dischargeDependency:(GLDedNode*)node;

//---------------------------------------------------------------------------------------------------------
//      Inferences
//---------------------------------------------------------------------------------------------------------
#pragma mark Inferences

+(instancetype)infer_DNE:(GLDedNode*)dn;
+(instancetype)infer_DNI:(GLDedNode *)node;

+(instancetype)infer_BE:(GLDedNode *)node leftToRight:(BOOL)leftToRight;
+(instancetype)infer_BI:(GLDedNode *)cd1 conditional2:(GLDedNode*)cd2;

+(instancetype)infer_CE:(GLDedNode *)conjunction leftFormula:(BOOL)left;
+(instancetype)infer_CI:(GLDedNode *)leftNode right:(GLDedNode*)rightNode;

+(instancetype)infer_DE:(GLDedNode *)disjunction conditional1:(GLDedNode*)c1 conditional2:(GLDedNode*)c2;
+(instancetype)infer_DI:(GLDedNode *)node otherDisjunct:(GLFormula*)dj2 keepLeft:(BOOL)left;

+(instancetype)infer_MP:(GLDedNode *)conditinal antecedent:(GLDedNode*)ant;
+(instancetype)infer_MT:(GLDedNode *)conditional negConsequent:(GLDedNode*)cons;
+(instancetype)infer_CP:(GLDedNode *)assumption minorConc:(GLDedNode*)minorConc;

+(instancetype)infer_RAA:(GLDedNode *)assumption contradiction:(GLDedNode*)contra;


@end

typedef BOOL(^GLDedNodeCriterion)(GLDedNode* node);
