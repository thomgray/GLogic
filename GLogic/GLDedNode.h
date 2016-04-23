//
//  GLDedNode.h
//  GLogic
//
//  Created by Thomas Gray on 16/03/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "GLFormula(Operations).h"

@class NSWeakArray<ObjectType>;

NS_ASSUME_NONNULL_BEGIN

/*!
 Enums representing the various inference rules
 */
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

NS_INLINE BOOL GLInferenceIsAssumption(GLInferenceRule rule){
    return (rule==GLInference_AssumptionCP || rule==GLInference_AssumptionDE || rule==GLInference_AssumptionRAA);
}

NS_INLINE BOOL GLInferenceIsAppropriate(GLFormula* formula, GLInferenceRule rule){
    switch (rule) {
        case GLInference_BiconditionalElim:
        case GLInference_ConditionalProof:
        case GLInference_ConditionalProofDE:
            return formula.isConditional;
        case GLInference_BiconditionalIntro:
            return formula.isBiconditional;
        case GLInference_ConjunctionIntro:
            return formula.isConjunction;
        case GLInference_DisjunctionIntro:
            return formula.isDisjunction;
        case GLInference_DNI:
            return formula.isDoubleNegation;
        default:
            return TRUE;
    }
}

#pragma mark
//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//
#pragma mark GLDedNode
//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//

@interface GLDedNode : NSObject{
//    NSArray<GLDedNode*>* _Nullable _inferences;
//    NSArray<GLDedNode*>* _Nullable _dependencies;
//    
    NSWeakArray<GLDedNode*>* _Nullable _weakInferences;
    NSWeakArray<GLDedNode*>* _weakDependencies;
}

@property GLFormula* formula;
@property GLInferenceRule inferenceRule;

@property NSArray<GLDedNode*>* dependencies;
@property NSArray<GLDedNode*>* _Nullable inferenceNodes;

@property NSInteger tier;

-(instancetype)initWithFormula:(GLFormula*)form inference:(GLInferenceRule)inf;
-(void)inheritDependencies:(NSArray<GLDedNode*>*) nodes;
+(instancetype)infer:(GLInferenceRule)inf formula:(GLFormula*)form withNodes:(NSArray<GLDedNode*>* _Nullable)nodes;

-(void)dischargeDependency:(GLDedNode*)node;
-(void)infer:(GLInferenceRule)rule nodes:(NSArray<GLDedNode*>* _Nullable)nodes;

+(NSArray<NSNumber*>*)allInferenceRules;

@end

#pragma mark

typedef BOOL(^GLDedNodeCriterion)(GLDedNode* node);


NS_INLINE NSString* GLStringForRule(GLInferenceRule rule){
    switch (rule) {
        case GLInference_AssumptionCP:
            return @"Assumption (CP)";
        case GLInference_AssumptionDE:
            return @"Assumption (DE)";
        case GLInference_AssumptionRAA:
            return @"Assumption (RAA)";
        case GLInference_BiconditionalElim:
            return @"Biconditional Elimination";
        case GLInference_BiconditionalIntro:
            return @"Biconditional Introduction";
        case GLInference_ConditionalProof:
            return @"Conditional Proof";
        case GLInference_ConditionalProofDE:
            return @"Conditional Proof (DE)";
        case GLInference_ConjunctionElim:
            return @"Conjunction Elimination";
        case GLInference_ConjunctionIntro:
            return @"Conjunction Introduction";
        case GLInference_DisjunctionElim:
            return @"Disjunction Elimination";
        case GLInference_DisjunctionIntro:
            return @"Disjunction Introduction";
        case GLInference_DNE:
            return @"DNE";
        case GLInference_DNI:
            return @"DNI";
        case GLInference_ModusPonens:
            return @"Modus Ponens";
        case GLInference_ModusTollens:
            return @"Modus Tollens";
        case GLInference_Premise:
            return @"Premise";
        case GLInference_ReductioAA:
            return @"Reductio Ad Absurdum";
        case GLInference_Reiteration:
            return @"Reiteration";
        default:
            return nil;
    }
}

NS_ASSUME_NONNULL_END

