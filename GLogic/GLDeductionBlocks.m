//
//  GLDeduction(Blocks).m
//  GLogic
//
//  Created by Thomas Gray on 17/03/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "GLDeductionBlocks.h"

@implementation GLInferenceResult

+(instancetype)rule:(GLInferenceRule)rule conclusion:(GLFormula *)conclusion steps:(NSArray<GLFormula *> *)steps{
    GLInferenceResult* out = [[self alloc]init];
    [out setRule:rule];
    [out setConclusion:conclusion];
    [out setSteps:steps];
    return out;
}

@end

@implementation GLDeductionBlocks

+(GLDeductionRuleUndirected)CjE_Undirected{
    return ^(GLDedNode* node, GLDeduction* ded){
        if ([node.formula mainConnective:GLConnectiveType_Conjunction]) {
            GLFormula* left = [node.formula getDecomposition:0].copy;
            GLFormula* right = [node.formula getDecomposition:1].copy;
            GLDedNode* leftDed = [GLDedNode infer:GLInference_ConjunctionElim formula:left withNodes:@[node]];
            GLDedNode* rightDed = [GLDedNode infer:GLInference_ConjunctionElim formula:right withNodes:@[node]];
            return @[leftDed, rightDed];
        }
        return (NSArray*) NULL;
    };
}
+(GLDeductionRuleUndirected)BcdE_Undirected{
    return ^(GLDedNode* node, GLDeduction* ded){
        if ([node.formula mainConnective:GLConnectiveType_Biconditional]) {
            GLFormula* left = [node.formula getDecomposition:0];
            GLFormula* right = [node.formula getDecomposition:1];
            GLFormula* cond1 = [GLFormula makeConditional:left.copy f2:right.copy];
            GLFormula* cond2 = [GLFormula makeConditional:right.copy f2:left.copy];
            GLDedNode* ded1 = [GLDedNode infer:GLInference_BiconditionalElim formula:cond1 withNodes:@[node]];
            GLDedNode* ded2 = [GLDedNode infer:GLInference_BiconditionalElim formula:cond2 withNodes:@[node]];
            return @[ded1, ded2];
        }else return (NSArray*)NULL;
    };
}
+(GLDeductionRuleUndirected)MP_Undirected{
    return ^(GLDedNode* node, GLDeduction* ded){
        if ([node.formula mainConnective:GLConnectiveType_Conditional]) {
            GLFormula* ant = [node.formula getDecomposition:0];
            GLDedNode* antNode = [ded findNodeInSequence:ant];
            if (antNode) {
                GLDedNode* dedOut = [GLDedNode infer:GLInference_ModusPonens formula:[node.formula getDecomposition:1].copy withNodes:@[node, antNode]];
                return @[dedOut];
            }
        }
        return (NSArray*) NULL;
    };
}
+(GLDeductionRuleUndirected)DNE_Undirected{
    return ^(GLDedNode* node, GLDeduction* ded){
        if ([node.formula mainConnective:GLConnectiveType_Negation] &&
            [[node.formula getDecomposition:0] mainConnective:GLConnectiveType_Negation]) {
            GLFormula* dneFormula = [[node.formula getDecomposition:0] getDecomposition:0];
            GLDedNode* dneNode = [GLDedNode infer:GLInference_DNE formula:dneFormula withNodes:@[node]];
            return @[dneNode];
        }else return (NSArray*)NULL;
    };
}

+(GLDeductionRuleDirected)CjI_Directed{
    return ^(GLFormula* conc, GLDeduction* ded){
        if ([conc mainConnective:GLConnectiveType_Conjunction]) {
            GLFormula* left = [conc getDecomposition:0];
            GLFormula* right = [conc getDecomposition:1];
            GLDedNode* leftNode = [ded findNodeInSequence:left];
            GLDedNode* rightNode = [ded findNodeInSequence:right];
            if (leftNode && rightNode) {
                GLDedNode* out = [GLDedNode infer:GLInference_ConjunctionIntro formula:conc withNodes:@[leftNode, rightNode]];
                return out;
            }
        }
        return (GLDedNode*) NULL;
    };
}

+(GLDeductionRuleDirected)DjI_Directed{
    return ^(GLFormula* conc, GLDeduction* ded){
        if ([conc mainConnective:GLConnectiveType_Disjunction]) {
            GLFormula* left = [conc getDecomposition:0];
            GLFormula* right = [conc getDecomposition:1];
            GLDedNode* leftNode = [ded findNodeInSequence:left];
            GLDedNode* rightNode = [ded findNodeInSequence:right];
            if (leftNode || rightNode) {
                GLDedNode* out = [GLDedNode infer:GLInference_ConjunctionIntro formula:conc withNodes:leftNode? @[leftNode]:@[rightNode]];
                return out;
            }
        }
        return (GLDedNode*) NULL;
    };
}

+(GLDeductionRuleDirected)BcdI_Directed{
    return ^(GLFormula* conc, GLDeduction* ded){
        if ([conc mainConnective:GLConnectiveType_Biconditional]) {
            GLFormula* left = [conc getDecomposition:0];
            GLFormula* right = [conc getDecomposition:1];
            GLFormula* firstConditional = [GLFormula makeConditional:left f2:right].copy;
            GLFormula* secondConditional = [GLFormula makeConditional:right f2:left].copy;
            GLDedNode* firstNode = [ded findNodeInSequence:firstConditional];
            GLDedNode* secondNode = [ded findNodeInSequence:secondConditional];
            if (firstNode && secondNode) {
                return [GLDedNode infer:GLInference_BiconditionalIntro formula:conc withNodes:@[firstNode, secondNode]];
            }
        }
        return (GLDedNode*) NULL;
    };
}

+(GLDeductionRuleDirected)DNI_Directed{
    return ^(GLFormula* conc, GLDeduction* ded){
        return (GLDedNode*) NULL;
    };
}

//---------------------------------------------------------------------------------------------------------
//      Inference Rule Blocks
//---------------------------------------------------------------------------------------------------------
#pragma mark Inference Rule Blocks

+(GLInferenceBlock)ConjunctionI{
    return ^(GLFormula* conc){
        if ([conc isConjunction]) {
            GLFormula* f1 = [conc getDecomposition:0];
            GLFormula* f2 = [conc getDecomposition:1];
            return [GLInferenceResult rule:GLInference_ConjunctionIntro conclusion:conc steps:@[f1,f2]];
        }
        return (GLInferenceResult*)NULL;
    };
}
+(GLInferenceBlock)DNI{
    return ^(GLFormula* conc){
        if ([conc isDoubleNegation]) {
            GLFormula* step = [[conc getDecomposition:0]getDecomposition:0].copy;
            return [GLInferenceResult rule:GLInference_DNI conclusion:conc steps:@[step]];
        }else return (GLInferenceResult*) NULL;
    };
}
+(GLInferenceBlock)BiconditionalI{
    return ^(GLFormula* conc){
        if ([conc mainConnective:GLConnectiveType_Biconditional]) {
            GLFormula* left = [conc getDecomposition:0];
            GLFormula* right = [conc getDecomposition:1];
            GLFormula* cond1 = [GLFormula makeConditional:left f2:right];
            GLFormula* cond2 = [GLFormula makeConditional:right f2:left];
            return [GLInferenceResult rule:GLInference_BiconditionalIntro conclusion:conc steps:@[cond1, cond2]];
        }else return (GLInferenceResult*) NULL;
    };
}


@end
