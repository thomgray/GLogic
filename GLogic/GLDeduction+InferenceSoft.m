//
//  GLDeduction+InferenceSoft.m
//  GLogic
//
//  Created by Thomas Gray on 26/03/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "GLDeduction+InferenceSoft.h"

@interface GLDeduction (InferenceSoftPrivate)

//-(GLDedNode*)infer_Soft_CPDE:(GLFormula*)conclusion;

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
    
    if ((out=[self findAvailableNode:conclusion])) {}
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
        GLDedNode* out = [GLDedNode infer:GLInference_ConjunctionIntro formula:conclusion withNodes:@[cj1Node, cj2Node]];
        [self appendNode:out];
        return out;
    }else return nil;
}

-(GLDedNode *)infer_Soft_DI:(GLFormula *)conclusion{
    if (!conclusion.isDisjunction) return nil;
    GLFormula* dj1 = [conclusion getDecomposition:0];
    GLFormula* dj2 = [conclusion getDecomposition:1];
    GLDedNode* djNode;
    if ((djNode=[self proveSoftSafe:dj1]) || (djNode=[self proveSoftSafe:dj2])) {
        GLDedNode* concNode = [GLDedNode infer:GLInference_DisjunctionIntro formula:conclusion withNodes:@[djNode]];
        [self appendNode:concNode];
        return concNode;
    }else return nil;
}

-(GLDedNode *)infer_Soft_DNI:(GLFormula *)conclusion{
    if (!conclusion.isDoubleNegation) return nil;
    GLFormula* dne = [conclusion getDecompositionAtNode:@[@0,@0]];
    GLDedNode* dneNode = [self proveSoftSafe:dne];
    if (dneNode) {
        GLDedNode* concNode = [GLDedNode infer:GLInference_DNI formula:conclusion withNodes:@[dneNode]];
        [self appendNode:concNode];
        return concNode;
    }else return nil;
}

-(GLDedNode *)infer_Soft_CP:(GLFormula *)conclusion{
    if (!conclusion.isConditional) return nil;
    
    GLFormula* antecedent = [conclusion getDecomposition:0];
    GLFormula* consequent = [conclusion getDecomposition:1];
    GLDedNode* assumptionNode = [GLDedNode infer:GLInference_AssumptionCP formula:antecedent withNodes:nil];

    [self subProofWithAssumption:assumptionNode];
    GLDedNode* minorConcNode = [self proveSoftSafe:consequent];
    
    if (minorConcNode) {
        GLDedNode* concNode = [GLDedNode infer:GLInference_ConditionalProof formula:conclusion withNodes:@[assumptionNode, minorConcNode]];
        [self appendNode:concNode];
        return concNode;
    }else{
        [self removeNodesFrom:assumptionNode];
        return nil;
    }
}

//-(GLDedNode *)infer_Soft_CPDE:(GLFormula *)conclusion{
//    if (!conclusion.isConditional) return nil;
//    GLFormula* antecedent = [conclusion getDecomposition:0];
//    GLFormula* consequent = [conclusion getDecomposition:1];
//    GLDedNode* assumptionNode = [GLDedNode infer:GLInference_AssumptionDE formula:antecedent withNodes:nil];
//    [self stepUp];
//    [self appendNode:assumptionNode];
//    GLDedNode* minorConcNode = [self proveSoftSafe:consequent];
//    [self stepDown];
//    
//    if (minorConcNode) {
//        GLDedNode* concNode = [GLDedNode infer:GLInference_ConditionalProofDE formula:conclusion withNodes:@[assumptionNode, minorConcNode]];
//        [self appendNode:concNode];
//        return concNode;
//    }else {
//        [self removeNodesFrom:assumptionNode];
//        return nil;
//    }
//}

-(GLDedNode*)infer_Soft_BI:(GLFormula *)conclusion{
    if (!conclusion.isBiconditional) return nil;
    GLFormula* left = [conclusion getDecomposition:0];
    GLFormula* right = [conclusion getDecomposition:1];
    GLFormula* conditional1 = [left.class makeConditional:left f2:right];
    GLFormula* conditional2 = [left.class makeConditional:right f2:left];
    GLDedNode* conditional1Node;
    GLDedNode* conditional2Node;
    if ((conditional1Node=[self proveSoftSafe:conditional1]) && (conditional2Node=[self proveSoftSafe:conditional2])) {
        GLDedNode* concNode = [GLDedNode infer:GLInference_BiconditionalIntro formula:conclusion withNodes:@[conditional1Node, conditional2Node]];
        [self appendNode:concNode];
        return concNode;
    }else return nil;
}

//---------------------------------------------------------------------------------------------------------
//      Deconstructive Inferences
//---------------------------------------------------------------------------------------------------------
#pragma mark Deconstructive Inferences

-(GLDedNode *)infer_Soft_Generatives:(GLFormula *)conclusion{
    GLDeductionIndex index= [self currentIndex];
    BOOL repeat;
    do {
        repeat = FALSE;
        repeat = [self infer_Deconstructive_BE] || repeat;
        repeat = [self infer_Deconstructive_CE] || repeat;
        repeat = [self infer_Deconstructive_DNE] || repeat;
        repeat = [self infer_Deconstructive_MP] || repeat;
        repeat = [self infer_Deconstructive_MT] || repeat;
    } while (repeat);
    
    GLDedNode* concNode = [self findAvailableNode:conclusion];

    if (concNode) {
        return concNode;
    }else{
        [self removeNodesFromIndex:index];
        return nil;
    }
}

-(BOOL)infer_Deconstructive_BE{
    BOOL out = FALSE;
    NSArray<GLDedNode*>* availables = [self availableNodes];
    for (NSInteger i=0; i<availables.count; i++) {
        GLDedNode* node = availables[i];
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
    NSArray<GLDedNode*>* availables = [self availableNodes];
    for (NSInteger i=0; i<availables.count; i++) {
        GLDedNode* node = availables[i];
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
    NSArray<GLDedNode*>* availables = [self availableNodes];
    for (NSInteger i=0; i<availables.count; i++) {
        GLDedNode* node = availables[i];
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
    NSArray<GLDedNode*>* availables = [self availableNodes];
    for (NSInteger i=0; i<availables.count; i++) {
        GLDedNode* node = availables[i];
        if (node.formula.isConditional) {
            GLFormula* ant = node.formula.firstDecomposition;
            GLFormula* cons = node.formula.secondDecomposition;
            GLDedNode* antNode;
            if ([self isInformedBy:cons] && (antNode=[self findAvailableNode:ant])) {
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
    NSArray<GLDedNode*>* availables = [self availableNodes];
    for (NSInteger i=0; i<availables.count; i++) {
        GLDedNode* node = availables[i];
        if (node.formula.isConditional) {
            GLFormula* ant = node.formula.firstDecomposition;
            GLFormula* cons = node.formula.secondDecomposition;
            GLFormula* negAnt = [ant.class makeNegationStrict:ant];
            GLFormula* negCons = [cons.class makeNegationStrict:cons];
            GLDedNode* negConsNode;
            if ([self isInformedBy:negAnt] && (negConsNode=[self findAvailableNode:negCons])) {
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
    NSArray<GLDedNode*>* disjunctions = [self availableNodesWithCriterion:^BOOL(GLDedNode *node) {
        return node.formula.isDisjunction;
    }];
    for (NSInteger i=0; i<disjunctions.count; i++) {
        GLDedNode* djNode = disjunctions[i];
        
        GLFormula* dj1 = djNode.formula.firstDecomposition;
        GLFormula* dj2 = djNode.formula.secondDecomposition;
        
        GLDeductionIndex index = [self currentIndex];
        
        GLDedNode* assumption1 = [GLDedNode infer:GLInference_AssumptionDE formula:dj1 withNodes:nil];
        [self subProofWithAssumption:assumption1];
        GLDedNode* conc1 = [self proveSoftSafe:conclusion];
        
        if (!conc1) {
            [self removeNodesFromIndex:index];
            continue;
        }
        
        [self stepDown];
        GLDedNode* assumption2 = [GLDedNode infer:GLInference_AssumptionDE formula:dj2 withNodes:nil];
        [self subProofWithAssumption:assumption2];
        GLDedNode* conc2 = [self proveSoftSafe:conclusion];
        
        if (conc2) {
            GLDedNode * concNode = [GLDedNode infer:GLInference_DisjunctionElim formula:conclusion withNodes:@[djNode, assumption1, conc1, assumption2, conc2]];
            [concNode dischargeDependency:assumption1];
            [concNode dischargeDependency:assumption2];
            [self appendNode:concNode];
            return concNode;
        }else{
            [self removeNodesFromIndex:index];
        }
    }
    return nil;
}

@end
