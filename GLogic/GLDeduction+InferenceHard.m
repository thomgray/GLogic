//
//  GLDeduction+InferenceHard.m
//  GLogic
//
//  Created by Thomas Gray on 26/03/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "GLDeduction+InferenceHard.h"

@implementation GLDeduction (InferenceHard)

-(GLDedNode *)proveHard:(GLFormula *)conclusion{
    GLDedNode* concNode;
    
    //NSLog(@"Proving hard: %@", conclusion);
    
    if ((concNode= [self proveSoft:conclusion])) {NSLog(@"Proved %@ soft", conclusion);}
    else if ((concNode=[self infer_Hard_BI:conclusion])){NSLog(@"Proved by BI");}
    else if ((concNode=[self infer_Hard_CI:conclusion])){NSLog(@"Proved by CI");}
    else if ((concNode=[self infer_Hard_DI:conclusion])){NSLog(@"Proved by DI");}
    else if ((concNode=[self infer_Hard_DNI:conclusion])){NSLog(@"Proved by DNI");}
    else if ((concNode=[self infer_Hard_CP:conclusion])){NSLog(@"Proved by CP");}
    
    else if ((concNode=[self infer_Hard_DNE:conclusion])){NSLog(@"Proved by DNE");}
    else if ((concNode=[self infer_Hard_CE:conclusion])){NSLog(@"Proved by CE");}
    else if ((concNode=[self infer_Hard_BE:conclusion])){NSLog(@"Proved by BE");}
    else if ((concNode=[self infer_Hard_MP:conclusion])){NSLog(@"Proved by MP");}
    else if ((concNode=[self infer_Hard_MT:conclusion])){NSLog(@"Proved by MT");}
    
    else if ((concNode=[self infer_Hard_DE:conclusion])){NSLog(@"Proved by DE");}
    else if ((concNode=[self infer_Hard_RAA:conclusion])){NSLog(@"Proved by RAA");}

    else {NSLog(@"Didn't prove it");}
    
    //Think about directing the order of inference depending on the connective;
    
    return concNode;
}

//---------------------------------------------------------------------------------------------------------
//      Construction Inferences
//---------------------------------------------------------------------------------------------------------
#pragma mark Construction Inferences

-(GLDedNode *)infer_Hard_CI:(GLFormula *)conclusion{
    if (!conclusion.isConjunction || ![self mayAttempt:GLInference_ConjunctionIntro
                                         forConclusion:conclusion]) return nil;
    
    //Don't try prove the conclusion while trying to prove by CI
    BOOL lift = [_checkList addRestriction:conclusion];
    
    GLDedNode* concNode = nil;
    GLDedNode* cj1 = [self proveHard:conclusion.firstDecomposition];
    if (cj1) {
        GLDedNode* cj2= [self proveHard:conclusion.secondDecomposition];
        if (cj2) {
            concNode = [self append:conclusion
                               rule:GLInference_ConjunctionIntro
                       dependencies:@[cj1, cj2]];
        }
    }
    
    if (lift) [_checkList liftRestriction:conclusion];
    return concNode;
}

-(GLDedNode *)infer_Hard_DI:(GLFormula *)conclusion{
    if (!conclusion.isDisjunction || ![self mayAttempt:GLInference_DisjunctionIntro
                                         forConclusion:conclusion]) return nil;
    
    BOOL lift = [_checkList addRestriction:conclusion];
    
    GLDedNode* dj = [self proveHard:conclusion.firstDecomposition];
    if (!dj) dj = [self proveHard:conclusion.secondDecomposition];
    
    if (lift) [_checkList liftRestriction:conclusion];
    
    if (dj) {
        GLDedNode* concNode = [self append:conclusion rule:GLInference_DisjunctionIntro dependencies:@[dj]];
        return concNode;
    }
    return nil;
}

-(GLDedNode *)infer_Hard_BI:(GLFormula *)conclusion{
    if (!conclusion.isBiconditional || ![self mayAttempt:GLInference_BiconditionalIntro
                                           forConclusion:conclusion]) return nil;
    
    GLFormula* cond1 = [conclusion.class makeConditional:conclusion.firstDecomposition f2:conclusion.secondDecomposition];
    GLFormula* cond2 = [conclusion.class makeConditional:conclusion.secondDecomposition f2:conclusion.firstDecomposition];
    
    BOOL lift = [_checkList addRestriction:conclusion];
    
    GLDedNode* concNode = nil;
    GLDedNode* cond1Node = [self proveHard:cond1];
    if (cond1Node) {
        GLDedNode* cond2Node = [self proveHard:cond2];
        if (cond2Node) {
            concNode = [self append:conclusion rule:GLInference_BiconditionalIntro dependencies:@[cond1Node, cond2Node]];
        }
    }
    
    if (lift) [_checkList liftRestriction:conclusion];
    return concNode;
}

-(GLDedNode *)infer_Hard_DNI:(GLFormula *)conclusion{
    if (!conclusion.isDoubleNegation || ![self mayAttempt:GLInference_DNI
                                            forConclusion:conclusion]) return nil;
    
    GLFormula* dne = [conclusion getDecompositionAtNode:@[@0,@0]];
    BOOL lift = [_checkList addRestriction:conclusion];
    GLDedNode* concNode = nil;
    GLDedNode* dneNode = [self proveHard:dne];
    if (dneNode) {
        concNode = [self append:conclusion rule:GLInference_DNI dependencies:@[dneNode]];
    }
    if (lift) [_checkList liftRestriction:conclusion];
    return concNode;
}

-(GLDedNode *)infer_Hard_CP:(GLFormula *)conclusion{
    if (!conclusion.isConditional || ![self mayAttempt:GLInference_ConditionalProof
                                         forConclusion:conclusion]) return nil;
    
    GLFormula* ant = conclusion.firstDecomposition;
    GLFormula* cons = conclusion.secondDecomposition;
    
    BOOL lift = [_checkList addRestriction:conclusion];
    
    GLDedNode* concNode = nil;
    GLDedNode* assumption = [GLDedNode infer:GLInference_AssumptionCP formula:ant withNodes:nil];
    GLDeduction* subproof = [self subProofWithAssumption:assumption];
    GLDedNode* minorConcNode = [subproof proveHard:cons];
    if (minorConcNode) {
        concNode = [GLDedNode infer:GLInference_ConditionalProof formula:conclusion withNodes:@[assumption, minorConcNode]];
        [concNode setSubProof:subproof];
        [concNode dischargeDependency:assumption];
        [self appendNode:concNode];
    }
    if (lift) [_checkList liftRestriction:conclusion];
    return concNode;
}

//---------------------------------------------------------------------------------------------------------
//      Deconstructive Inferences
//---------------------------------------------------------------------------------------------------------
#pragma mark Deconstructive Inferences

-(GLDedNode *)infer_Hard_CE:(GLFormula *)conclusion{
    if (![self mayAttempt:GLInference_ConjunctionElim forConclusion:conclusion]) return nil;
    
    NSSet<GLFormula*>* formulas = [self getAllFormulaDecompositions_includingNegations:NO includingConclusion:NO];
    formulas = [formulas subsetWithScheme:^BOOL(GLFormula *object) {
        if (object.isConjunction) {
            return [object.firstDecomposition isEqual:conclusion] || [object.secondDecomposition isEqual:conclusion];
        }else return FALSE;
    }];
    NSArray<GLFormula*>* conjunctions = formulas.allObjects;
    for (NSInteger i=0; i<conjunctions.count; i++) {
        BOOL lift = [self.checkList addRestriction:conjunctions[i] forRule:GLInference_ConjunctionIntro];
        GLDedNode* conjunctionNode = [self proveHard:conjunctions[i]];
        if (lift) [self.checkList liftRestriction:conjunctions[i] forRule:GLInference_ConjunctionIntro];
        if (conjunctionNode) {
            return [self proveSoft:conclusion];
        }
    }
    return nil;
}

-(GLDedNode *)infer_Hard_DNE:(GLFormula *)conclusion{
    if (![self mayAttempt:GLInference_DNE forConclusion:conclusion]) return nil;
    
    GLFormula* dniConc = [conclusion.class makeNegationStrict:[conclusion.class makeNegationStrict:conclusion]];
    NSSet<GLFormula*>* forms = [self getAllFormulaDecompositions_includingNegations:YES includingConclusion:NO];
    if ([forms containsObject:dniConc]) {
        BOOL lift = [self.checkList addRestriction:dniConc forRule:GLInference_DNI];
        GLDedNode* dniNode = [self proveHard:dniConc];
        if (lift) [self.checkList liftRestriction:dniConc forRule:GLInference_DNI];
        if (dniNode) {
            GLDedNode* concNode = [GLDedNode infer:GLInference_DNE
                                           formula:conclusion
                                         withNodes:@[dniNode]];
            [self appendNode:concNode];
            return concNode;
        }
    }
    return nil;
}

-(GLDedNode *)infer_Hard_BE:(GLFormula *)conclusion{
    if (![self mayAttempt:GLInference_BiconditionalElim forConclusion:conclusion]) return nil;
    if (conclusion.isConditional) {
        GLFormula* ant = conclusion.firstDecomposition;
        GLFormula* cons = conclusion.secondDecomposition;
        GLFormula* bicon1 = [conclusion.class makeBiconditional:ant f2:cons];
        GLFormula* bicon2 = [conclusion.class makeBiconditional:ant f2:cons];
        GLDedNode* biconNode;
        
        BOOL lift = [self.checkList addRestriction:bicon1 forRule:GLInference_BiconditionalIntro];
        biconNode = [self proveHard:bicon1];
        if (lift) [self.checkList liftRestriction:bicon1 forRule:GLInference_BiconditionalIntro];
        
        if (!biconNode){
            lift = [self.checkList addRestriction:bicon2 forRule:GLInference_BiconditionalIntro];
            biconNode = [self proveHard:bicon2];
            if (lift) [self.checkList liftRestriction:bicon2 forRule:GLInference_BiconditionalIntro];
            
        }
        
        if (biconNode) {
            return [self proveSoft:conclusion];
        }
    }
    return nil;
}

-(GLDedNode *)infer_Hard_MP:(GLFormula *)conclusion{
    if (![self mayAttempt:GLInference_ModusPonens forConclusion:conclusion]) return nil;
    /*
    NSLog(@"Proving %@ by MP", conclusion);
    NSLog(@"Inferring MP \n\
          Conclusion: %@ \n\
          Restrictions: %@ \n\
          Self: %@",
          conclusion, _checkList.items, @""); /**/
    /**/
    for (NSInteger i=0; i<self.sequence.count; i++) {
        GLDedNode* node = self.sequence[i];
        if (node.formula.isConditional) {
            GLFormula* ant = node.formula.firstDecomposition;
            GLFormula* cons = node.formula.secondDecomposition;
            if ([conclusion isEqual:cons]) {
                GLDedNode* antNode = [self proveHard:ant];
                if (antNode) {
                    GLDedNode* concNode = [self append:conclusion rule:GLInference_ModusPonens dependencies:@[node, antNode]];
                    return concNode;
                }
            }
        }
    }
    return nil;
}

-(GLDedNode *)infer_Hard_MT:(GLFormula *)conclusion{
    if (![self mayAttempt:GLInference_ModusTollens forConclusion:conclusion]) return nil;
    return nil;
}

//---------------------------------------------------------------------------------------------------------
//      DE
//---------------------------------------------------------------------------------------------------------
#pragma mark DE 

-(GLDedNode *)infer_Hard_DE:(GLFormula *)conclusion{
    if (![self mayAttempt:GLInference_DisjunctionElim forConclusion:conclusion]) return nil;
    /*
    NSLog(@"Proving %@ by DE", conclusion);
    NSLog(@"*******************Inferring DE for %@ \n\
          Restrictions: %@ \n\
          Self: %@", conclusion, _checkList.items, self); /**/
    /**/
    
    NSArray<GLDedNode*>* disjunctions = [self getNodesWithCriterion:^BOOL(GLDedNode *node) {
        return node.formula.isDisjunction;
    }];
    
    for (NSInteger i=0; i<disjunctions.count; i++) {        
        GLDedNode* djNode = disjunctions[i];
        GLFormula* disjunction = djNode.formula;
        
        if ([_checkList disjunctionIsRestrictedForDE:disjunction]) continue;
        
        [_checkList addDERestriction:disjunction];
        GLDedNode* concNode = [self infer_Hard_DE:conclusion withDisjunction:djNode];
        [_checkList liftDERestriction:disjunction];
        
        if (concNode) return concNode;
    }
    return nil;
}

-(GLDedNode *)infer_Hard_DE:(GLFormula *)conclusion withDisjunction:(GLDedNode *)node{
    
    GLFormula* dj1 = [node.formula firstDecomposition];
    GLFormula* dj2 = [node.formula secondDecomposition];
    GLFormula* cond1 = [dj1.class makeConditional:dj1 f2:conclusion];
    GLFormula* cond2 = [dj1.class makeConditional:dj2 f2:conclusion];
    
    GLDeduction * subproof = [self subProofWithAssumption:nil];
    
    GLDedNode* cond1Node = [subproof infer_Hard_CPDE:cond1];
    if (!cond1Node) return nil;
    
    GLDedNode* cond2Node = [subproof infer_Hard_CPDE:cond2];
    if (!cond2Node) return nil;
    
    GLDedNode* concNode = [GLDedNode infer:GLInference_DisjunctionElim formula:conclusion withNodes:@[node, cond1Node, cond2Node]];
    [self appendNode:concNode];
    [concNode setSubProof:subproof];
    return concNode;
}


-(GLDedNode *)infer_Hard_CPDE:(GLFormula *)conclusion{
    if (![self mayAttempt:GLInference_ConditionalProofDE forConclusion:conclusion]) return nil;
    else if (!conclusion.isConditional) return nil;
    
    //NSLog(@"Doing CP for DE on: %@", conclusion);
    
    GLFormula* ant = conclusion.firstDecomposition;
    GLFormula* cons = conclusion.secondDecomposition;
    
    GLDedNode* assumptionNode = [GLDedNode infer:GLInference_AssumptionDE formula:ant withNodes:nil];
    GLDeduction* subproof = [self subProofWithAssumption:assumptionNode];
    
    //NSLog(@"Assuming %@ to prove %@ with the subproof %@", ant, cons, subproof);
    
    GLDedNode* minorConc = [subproof proveHard:cons];
    if (minorConc) {
        GLDedNode* concNode = [GLDedNode infer:GLInference_ConditionalProofDE formula:conclusion withNodes:@[assumptionNode, minorConc]];
        [concNode setSubProof:subproof];
        [concNode dischargeDependency:assumptionNode];
        [self appendNode:concNode];
        return concNode;
    }
    return nil;
}

//---------------------------------------------------------------------------------------------------------
//      Reductio
//---------------------------------------------------------------------------------------------------------
#pragma mark Reductio

-(GLDedNode *)infer_Hard_RAA:(GLFormula *)conclusion{
    return nil;
    
    if (![self mayAttempt:GLInference_ReductioAA forConclusion:conclusion]) return nil;
    GLFormula* negConc = [conclusion.class makeNegation:conclusion];
    
    if ([self containsFormula:negConc] || [self containsFormula:conclusion]) return nil;
    //No point in assuming something we already know or reductio-ing something we know. This will also (hopefully) guarantee reductio's don't recur indefinitely
    
    //NSLog(@"Doing Reductio for conclusion: %@ by assuming %@", conclusion, negConc);
    //NSLog(@"%@", self);
    
    GLDedNode* assumption = [GLDedNode infer:GLInference_AssumptionRAA formula:negConc withNodes:nil];
    GLDeduction* subProof = [self subProofWithAssumption:assumption];
    
    NSArray<GLFormula*>* formulasForReduction = [self formulasForReductio];
    
    //NSLog(@"\t For reuctio of %@, we consider the following formulas: %@", negConc, formulasForReduction);
    for (NSInteger i=0; i<formulasForReduction.count; i++) {
        GLFormula* f1 = formulasForReduction[i];
        GLFormula* f2 = [f1.class makeNegation:f1];
        GLFormula* contra = [f1.class makeConjunction:f1 f2:f2];
        
        if ([self containsFormula:f1] && [self containsFormula:f2]) continue;
        
        GLDedNode* cj1 = [subProof proveHard:f1];
        if (!cj1) continue;
        GLDedNode* cj2 = [subProof proveHard:f2];
        if (!cj2) continue;
        
        GLDedNode* contraNode = [subProof proveSoft:contra];
        
        if (contraNode) {
            GLFormula* negAssumption = [negConc.class makeNegationStrict:negConc];
            GLDedNode* negAssNode = [GLDedNode infer:GLInference_ReductioAA formula:negAssumption withNodes:@[assumption, contraNode]];
            [negAssNode dischargeDependency:assumption];
            return [self proveSoft:conclusion];
        }
    }
    return nil;
}

@end
