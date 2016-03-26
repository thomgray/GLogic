//
//  GLDeductionBlocks.m
//  GLogic
//
//  Created by Thomas Gray on 17/03/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "GLDeductionBlocks.h"

@implementation GLInferenceResult

+(instancetype)rule:(GLInferenceRule)rule steps:(NSArray<GLFormula *> *)steps{
    GLInferenceResult* out = [[self alloc]init];
    [out setRule:rule];
    [out setSteps:steps];
    return out;
}

@end

@implementation GLDeductionBlocks

//---------------------------------------------------------------------------------------------------------
//      Generative Blocks
//---------------------------------------------------------------------------------------------------------
#pragma mark Generative Blocks
/**
 *
 *
 *  @return Block for Biconditional Elimination
 */
+(GenerativeInferenceBlock)generative_BE{
    return ^(GLDedNode* node, GLDeduction* ded){
        if ([node.formula mainConnective:GLConnectiveType_Biconditional]) {
            GLFormula* left = [node.formula getDecomposition:0];
            GLFormula* right = [node.formula getDecomposition:1];
            GLFormula* cond1 = [GLFormula makeConditional:left f2:right];
            GLFormula* cond2 = [GLFormula makeConditional:right f2:left];
            GLDedNode* ded1 = [GLDedNode infer:GLInference_BiconditionalElim formula:cond1 withNodes:@[node]];
            GLDedNode* ded2 = [GLDedNode infer:GLInference_BiconditionalElim formula:cond2 withNodes:@[node]];
            return @[ded1, ded2];
        }else return (NSArray*)nil;
    };
}
+(GenerativeInferenceBlock)generative_CE{
    return ^(GLDedNode* node, GLDeduction* ded){
        if ([node.formula mainConnective:GLConnectiveType_Conjunction]) {
            GLFormula* left = [node.formula getDecomposition:0];
            GLFormula* right = [node.formula getDecomposition:1];
            GLDedNode* leftDed = [GLDedNode infer:GLInference_ConjunctionElim formula:left withNodes:@[node]];
            GLDedNode* rightDed = [GLDedNode infer:GLInference_ConjunctionElim formula:right withNodes:@[node]];
            return @[leftDed, rightDed];
        }
        return (NSArray*) nil;
    };
}

+(GenerativeInferenceBlock)generative_DNE{
    return ^(GLDedNode* node, GLDeduction* ded){
        if ([node.formula mainConnective:GLConnectiveType_Negation] &&
            [[node.formula getDecomposition:0] mainConnective:GLConnectiveType_Negation]) {
            GLFormula* dneFormula = [[node.formula getDecomposition:0] getDecomposition:0];
            GLDedNode* dneNode = [GLDedNode infer:GLInference_DNE formula:dneFormula withNodes:@[node]];
            return @[dneNode];
        }else return (NSArray*)nil;
    };
}
+(GenerativeInferenceBlock)generative_MP{
    return ^(GLDedNode* node, GLDeduction* ded){
        if ([node.formula mainConnective:GLConnectiveType_Conditional]) {
            GLFormula* ant = [node.formula getDecomposition:0];
            GLDedNode* antNode = [ded findNodeInSequence:ant];
            if (antNode) {
                GLDedNode* dedOut = [GLDedNode infer:GLInference_ModusPonens formula:[node.formula getDecomposition:1].copy withNodes:@[node, antNode]];
                return @[dedOut];
            }
        }
        return (NSArray*) nil;
    };
}
+(GenerativeInferenceBlock)generative_MT{
    return ^(GLDedNode* node, GLDeduction* ded){
        if (node.formula.isConditional) {
            GLFormula* cons = [node.formula getDecomposition:1];
            GLFormula* negCons = [GLFormula makeNegationStrict:cons];
            GLDedNode* negConsNode = [ded findNodeInSequence:negCons];
            if (negConsNode) {
                GLFormula* conc = [GLFormula makeNegationStrict:[node.formula getDecomposition:0]];
                GLDedNode* concNode = [GLDedNode infer:GLInference_ModusTollens formula:conc withNodes:@[node, negConsNode]];
                return @[concNode];
            }
        }
        return (NSArray*) nil;
    };
}

//---------------------------------------------------------------------------------------------------------
//      Directed Blocks - Constructive
//---------------------------------------------------------------------------------------------------------
#pragma mark Directed Blocks - Constructive

+(DirectedInferenceBlock)directed_BI{
    return ^(GLFormula* conclusion){
        if (conclusion.isBiconditional) {
            GLFormula* left = [conclusion getDecomposition:0];
            GLFormula* right = [conclusion getDecomposition:1];
            GLFormula* cond1 = [GLFormula makeConditional:left f2:right];
            GLFormula* cond2 = [GLFormula makeConditional:right f2:left];
            return [GLInferenceResult rule:GLInference_BiconditionalIntro steps:@[cond1, cond2]];
        }else return (GLInferenceResult*)nil;
    };
}
+(DirectedInferenceBlock)directed_CI{
    return ^(GLFormula* conc){
        if ([conc isConjunction]) {
            GLFormula* f1 = [conc getDecomposition:0];
            GLFormula* f2 = [conc getDecomposition:1];
            return [GLInferenceResult rule:GLInference_ConjunctionIntro steps:@[f1,f2]];
        }else return (GLInferenceResult*)nil;
    };
}
+(DirectedInferenceBlock)directed_DI{
    return ^(GLFormula* conc){
        if (conc.isDisjunction) {
            GLFormula* dj1 = [conc getDecomposition:0];
            GLFormula* dj2 = [conc getDecomposition:1];
            return [GLInferenceResult rule:GLInference_DisjunctionElim steps:@[dj1, dj2]];
        }else return (GLInferenceResult*) nil;
    };
}
+(DirectedInferenceBlock)directed_DNI{
    return ^(GLFormula* conc){
        if ([conc isDoubleNegation]) {
            GLFormula* step = [[conc getDecomposition:0]getDecomposition:0];
            return [GLInferenceResult rule:GLInference_DNI steps:@[step]];
        }else return (GLInferenceResult*) nil;
    };
}
+(DirectedInferenceBlock)directed_CP{
    return ^(GLFormula* conc){
        if (conc.isConditional) {
            GLFormula* ant = [conc getDecomposition:0];
            GLFormula* cons = [conc getDecomposition:1];
            return [GLInferenceResult rule:GLInference_ConditionalProof steps:@[ant, cons]];
        }else return (GLInferenceResult*) nil;
    };
}
+(DirectedInferenceBlock)directed_CPDE{
    return ^(GLFormula* conc){
        if (conc.isConditional) {
            GLFormula* ant = [conc getDecomposition:0];
            GLFormula* cons = [conc getDecomposition:1];
            return [GLInferenceResult rule:GLInference_ConditionalProofDE steps:@[ant, cons]];
        }else return (GLInferenceResult*) nil;
    };
}

//---------------------------------------------------------------------------------------------------------
//      Directed Blocks - Deconstructive
//---------------------------------------------------------------------------------------------------------
#pragma mark Directed Blocks - Deconstructive



@end
