//
//  GLDeduction+InferenceSoft.m
//  GLogic
//
//  Created by Thomas Gray on 26/03/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "GLDeduction+InferenceSoft.h"

@interface GLDeduction (InferenceSoftPrivate)

-(GLDedNode*)infer_Soft_CPDE:(GLFormula*)conclusion;

@end

@implementation GLDeduction (InferenceSoft)

-(GLDedNode *)proveSoft:(GLFormula *)conclusion{
    GLDedNode* out;
    
    if ((out=[self proveSoftSafe:conclusion])) {}
    else if ((out=[self infer_Soft_DE:conclusion])){}
    
    return out;
}


-(GLDedNode *)proveSoftSafe:(GLFormula *)conclusion{
    GLDedNode* out;
    
    if ((out=[self findNodeInSequence:conclusion])) {}
    else if ((out=[self infer_Soft_Generatives:conclusion])){}
    else if ((out=[self infer_Soft_BI:conclusion])){}
    else if ((out=[self infer_Soft_CI:conclusion])){}
    else if ((out=[self infer_Soft_CP:conclusion])){}
    else if ((out=[self infer_Soft_DI:conclusion])){}
    else if ((out=[self infer_Soft_DNI:conclusion])){}
    
    return out;
}

//---------------------------------------------------------------------------------------------------------
//      Constructive Inferences
//---------------------------------------------------------------------------------------------------------
#pragma mark Constructive Inferences

-(GLDedNode *)infer_Soft_CI:(GLFormula *)conclusion{
    if (!conclusion.isConjunction) return nil;
    GLFormula* cj1 = [conclusion getDecomposition:0];
    GLFormula* cj2 = [conclusion getDecomposition:1];
    GLDedNode* cj1Node;
    GLDedNode* cj2Node;
    if ((cj1Node=[self proveSoftSafe:cj1]) && (cj2Node=[self proveSoftSafe:cj2])) {
        return [self append:conclusion rule:GLInference_ConjunctionIntro dependencies:@[cj1Node, cj2Node]];
    }else return nil;
}

-(GLDedNode *)infer_Soft_DI:(GLFormula *)conclusion{
    if (!conclusion.isDisjunction) return nil;
    GLFormula* dj1 = [conclusion getDecomposition:0];
    GLFormula* dj2 = [conclusion getDecomposition:1];
    GLDedNode* djNode;
    if ((djNode=[self proveSoftSafe:dj1]) || (djNode=[self proveSoftSafe:dj2])) {
        return [self append:conclusion rule:GLInference_DisjunctionIntro dependencies:@[djNode]];
    }else return nil;
}

-(GLDedNode *)infer_Soft_DNI:(GLFormula *)conclusion{
    if (!conclusion.isDoubleNegation) return nil;
    GLFormula* dne = [conclusion getDecompositionAtNode:@[@0,@0]];
    GLDedNode* dneNode = [self proveSoftSafe:dne];
    if (dneNode) {
        return [self append:conclusion rule:GLInference_DNI dependencies:@[dneNode]];
    }else return nil;
}

-(GLDedNode *)infer_Soft_CP:(GLFormula *)conclusion{
    if (!conclusion.isConditional) return nil;
    
    GLFormula* antecedent = [conclusion getDecomposition:0];
    GLFormula* consequent = [conclusion getDecomposition:1];
    GLDedNode* assumptionNode = [GLDedNode infer:GLInference_AssumptionCP formula:antecedent withNodes:nil];
    GLDeduction* subproof = [self subProofWithAssumption:assumptionNode];
    GLDedNode* minorConcNode = [subproof proveSoftSafe:consequent];
    if (minorConcNode) {
        GLDedNode* concNode = [GLDedNode infer_CP:assumptionNode minorConc:minorConcNode];
        [concNode setSubProof:subproof];
        [self appendNode:concNode];
        return concNode;
    }else return nil;
}

-(GLDedNode *)infer_Soft_CPDE:(GLFormula *)conclusion{
    if (!conclusion.isConditional) return nil;
    GLFormula* antecedent = [conclusion getDecomposition:0];
    GLFormula* consequent = [conclusion getDecomposition:1];
    GLDedNode* assumptionNode = [GLDedNode infer:GLInference_AssumptionDE formula:antecedent withNodes:nil];
    GLDeduction* subproof = [self subProofWithAssumption:assumptionNode];
    GLDedNode* minorConcNode = [subproof proveSoftSafe:consequent];
    if (minorConcNode) {
        GLDedNode* concNode = [GLDedNode infer:GLInference_ConditionalProofDE formula:conclusion withNodes:@[assumptionNode, minorConcNode]];
        [concNode dischargeDependency:assumptionNode];
        [concNode setSubProof:subproof];
        [self appendNode:concNode];
        return concNode;
    }else return nil;
}

-(GLDedNode*)infer_Soft_BI:(GLFormula *)conclusion{
    if (!conclusion.isBiconditional) return nil;
    GLFormula* left = [conclusion getDecomposition:0];
    GLFormula* right = [conclusion getDecomposition:1];
    GLFormula* conditional1 = [left.class makeConditional:left f2:right];
    GLFormula* conditional2 = [left.class makeConditional:right f2:left];
    GLDedNode* conditional1Node;
    GLDedNode* conditional2Node;
    if ((conditional1Node=[self proveSoftSafe:conditional1]) && (conditional2Node=[self proveSoftSafe:conditional2])) {
        return [self append:conclusion rule:GLInference_BiconditionalIntro dependencies:@[conditional1Node, conditional2Node]];
    }else return nil;
}

//---------------------------------------------------------------------------------------------------------
//      Deconstructive Inferences
//---------------------------------------------------------------------------------------------------------
#pragma mark Deconstructive Inferences

-(GLDedNode *)infer_Soft_Generatives:(GLFormula *)conclusion{
    GLDeduction* subproof = [self tempProof];
    BOOL repeat;
    do {
        repeat = FALSE;
        repeat = [subproof infer_Deconstructive_BE] || repeat;
        repeat = [subproof infer_Deconstructive_CE] || repeat;
        repeat = [subproof infer_Deconstructive_DNE] || repeat;
        repeat = [subproof infer_Deconstructive_MP] || repeat;
        repeat = [subproof infer_Deconstructive_MT] || repeat;
    } while (repeat);
    
    GLDedNode* concNode = [subproof findNodeInSequence:conclusion];

    if (concNode) {
        [subproof tidyDeductionIncludingNodes:@[concNode]];
        [self assimilateDeduction:subproof fromLine:0];
        return concNode;
    }else return nil;
}

-(BOOL)infer_Deconstructive_BE{
    BOOL out = FALSE;
    for (NSInteger i=0; i<self.sequence.count; i++) {
        GLDedNode* node = self.sequence[i];
        if (node.formula.isBiconditional) {
            GLFormula* cd1 = [node.formula.class makeConditional:node.formula.firstDecomposition f2:node.formula.secondDecomposition];
            GLFormula* cd2 = [node.formula.class makeConditional:node.formula.secondDecomposition f2:node.formula.firstDecomposition];
            if ([self isInformedBy:cd1]) {
                GLDedNode* cd1Node = [GLDedNode infer:GLInference_BiconditionalElim formula:cd1 withNodes:@[node]];
                [self appendNode:cd1Node];
                out = TRUE;
            }
            if ([self isInformedBy:cd2]) {
                GLDedNode* cd2Node = [GLDedNode infer:GLInference_BiconditionalElim formula:cd2 withNodes:@[node]];
                [self appendNode:cd2Node];
                out = TRUE;
            }
        }
    }
    return out;
}

-(BOOL)infer_Deconstructive_CE{
    BOOL out = FALSE;
    for (NSInteger i=0; i<self.sequence.count; i++) {
        GLDedNode* node = self.sequence[i];
        if (node.formula.isConjunction) {
            if ([self isInformedBy:node.formula.firstDecomposition]) {
                GLDedNode* cj1 = [GLDedNode infer:GLInference_ConjunctionElim formula:node.formula.firstDecomposition withNodes:@[node]];
                [self appendNode:cj1];
                out = TRUE;
            }
            if ([self isInformedBy:node.formula.secondDecomposition]) {
                GLDedNode* cj2 = [GLDedNode infer:GLInference_ConjunctionElim formula:node.formula.secondDecomposition withNodes:@[node]];
                [self appendNode:cj2];
                out = TRUE;
            }
        }
    }
    return out;
}
-(BOOL)infer_Deconstructive_DNE{
    BOOL out = FALSE;
    for (NSInteger i=0; i<self.sequence.count; i++) {
        GLDedNode* node = self.sequence[i];
        if (node.formula.isDoubleNegation) {
            GLFormula* f = [node.formula getDecompositionAtNode:@[@0,@0]];
            if ([self isInformedBy:f]) {
                GLDedNode* dneg = [GLDedNode infer:GLInference_DNE formula:f withNodes:@[node]];
                [self appendNode:dneg];
                out = TRUE;
            }
        }
    }
    return out;
}
-(BOOL)infer_Deconstructive_MP{
    BOOL out = FALSE;
    for (NSInteger i=0; i<self.sequence.count; i++) {
        GLDedNode* node = self.sequence[i];
        if (node.formula.isConditional) {
            GLFormula* ant = node.formula.firstDecomposition;
            GLFormula* cons = node.formula.secondDecomposition;
            GLDedNode* antNode;
            if ([self isInformedBy:cons] && (antNode=[self findNodeInSequence:ant])) {
                GLDedNode* consNode = [GLDedNode infer:GLInference_ModusPonens formula:cons withNodes:@[node, antNode]];
                [self appendNode:consNode];
                out = TRUE;
            }
        }
    }
    return out;
}

-(BOOL)infer_Deconstructive_MT{
    BOOL out = FALSE;
    for (NSInteger i=0; i<self.sequence.count; i++) {
        GLDedNode* node = self.sequence[0];
        if (node.formula.isConditional) {
            GLFormula* ant = node.formula.firstDecomposition;
            GLFormula* cons = node.formula.secondDecomposition;
            GLFormula* negAnt = [ant.class makeNegationStrict:ant];
            GLFormula* negCons = [cons.class makeNegationStrict:cons];
            GLDedNode* negConsNode;
            if ([self isInformedBy:negAnt] && (negConsNode=[self findNodeInSequence:negCons])) {
                GLDedNode* negAntNode = [GLDedNode infer:GLInference_ModusTollens formula:negAnt withNodes:@[node, negConsNode]];
                [self appendNode:negAntNode];
                out = TRUE;
            }
        }
    }
    return out;
}

//---------------------------------------------------------------------------------------------------------
//      Non Safe Inferences
//---------------------------------------------------------------------------------------------------------
#pragma mark Non Safe Inferences

-(GLDedNode *)infer_Soft_DE:(GLFormula *)conclusion{
    NSArray<GLDedNode*>* disjunctions = [self getNodesWithCriterion:^BOOL(GLDedNode *node) {
        return node.formula.isDisjunction;
    }];
    for (NSInteger i=0; i<disjunctions.count; i++) {
        GLDedNode* djNode = disjunctions[i];
        GLFormula* dj1 = djNode.formula.firstDecomposition;
        GLFormula* dj2 = djNode.formula.secondDecomposition;
        GLFormula* cond1 = [dj1.class makeConditional:dj1 f2:conclusion];
        GLFormula* cond2 = [dj2.class makeConditional:dj2 f2:conclusion];
        
        GLDeduction* tempProof = [self tempProof];
        
        GLDedNode* cond1Node = [tempProof infer_Soft_CPDE:cond1];
        if (!cond1Node) continue;
        
        GLDedNode* cond2Node = [tempProof infer_Soft_CPDE:cond2];
        if (!cond2Node) continue;
        
        [self assimilateDeduction:tempProof fromLine:self.sequence.count];
        GLDedNode* concNode = [self append:conclusion rule:GLInference_DisjunctionElim dependencies:@[djNode, cond1Node, cond2Node]];
        return concNode;        
    }
    return nil;
}

@end
