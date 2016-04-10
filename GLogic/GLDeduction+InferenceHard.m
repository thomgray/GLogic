//
//  GLDeduction+InferenceHard.m
//  GLogic
//
//  Created by Thomas Gray on 26/03/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "GLDeduction+InferenceHard.h"

@interface GLDeduction (InferenceHardPrivate)

-(NSInteger)proveHardStackCount;

@end

@implementation GLDeduction (InferenceHard)

-(NSInteger)proveHardStackCount{
    NSArray<NSString*>* stack = [NSThread callStackSymbols];
    NSInteger out = 0;
    for (NSInteger i=0; i<stack.count; i++) {
        if ([stack[i] containsString:@"proveHard:"]) {
            out++;
        }
    }
    return out;
}

-(GLDedNode *)proveHard:(GLFormula *)conclusion{
    GLDedNode* concNode;
    [self.logger logInfo:@{@"Title":@"Prove Hard",
                           @"Conclusion":conclusion,
                           @"Recursion":[NSNumber numberWithInteger:[self proveHardStackCount]]
                           }
               deduction:self];
    
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
   [_checkList addRestriction:conclusion];
    
    GLDedNode* concNode = nil;
    
    GLDedNode* cj1 = [self proveHard:conclusion.firstDecomposition];
    
    if (cj1) {
        GLDedNode* cj2= [self proveHard:conclusion.secondDecomposition];
        if (cj2) {
            concNode = [GLDedNode infer:GLInference_ConjunctionIntro formula:conclusion withNodes:@[cj1, cj2]];
            [self appendNode:concNode];
        }
    }
    
    [_checkList liftRestriction:conclusion];
    return concNode;
}

-(GLDedNode *)infer_Hard_DI:(GLFormula *)conclusion{
    if (!conclusion.isDisjunction || ![self mayAttempt:GLInference_DisjunctionIntro
                                         forConclusion:conclusion]) return nil;
    
    [_checkList addRestriction:conclusion];
    
    GLDedNode* dj = [self proveHard:conclusion.firstDecomposition];
    if (!dj) dj = [self proveHard:conclusion.secondDecomposition];
    
    [_checkList liftRestriction:conclusion];
    
    if (dj) {
        GLDedNode* concNode = [GLDedNode infer:GLInference_DisjunctionIntro formula:conclusion withNodes:@[dj]];
        [self appendNode:concNode];
        return concNode;
    }
    return nil;
}

-(GLDedNode *)infer_Hard_BI:(GLFormula *)conclusion{
    if (!conclusion.isBiconditional || ![self mayAttempt:GLInference_BiconditionalIntro
                                           forConclusion:conclusion]) return nil;
    
    GLDeductionIndex index = [self currentIndex];
    
    GLFormula* cond1 = [conclusion.class makeConditional:conclusion.firstDecomposition f2:conclusion.secondDecomposition];
    GLFormula* cond2 = [conclusion.class makeConditional:conclusion.secondDecomposition f2:conclusion.firstDecomposition];
    
    [_checkList addRestriction:conclusion];
    
    GLDedNode* concNode = nil;
    GLDedNode* cond1Node = [self proveHard:cond1];
    if (cond1Node) {
        GLDedNode* cond2Node = [self proveHard:cond2];
        if (cond2Node) {
            concNode = [GLDedNode infer:GLInference_BiconditionalIntro formula:conclusion withNodes:@[cond1Node, cond2Node]];
            [self appendNode:concNode];
        }
    }
    if (!concNode) {
        [self removeNodesFromIndex:index];
    }
    [_checkList liftRestriction:conclusion];
    return concNode;
}

-(GLDedNode *)infer_Hard_DNI:(GLFormula *)conclusion{
    if (!conclusion.isDoubleNegation || ![self mayAttempt:GLInference_DNI
                                            forConclusion:conclusion]) return nil;
    
    [_checkList addRestriction:conclusion];
    
    GLFormula* dne = [conclusion getDecompositionAtNode:@[@0,@0]];
    GLDedNode* concNode = nil;
    GLDedNode* dneNode = [self proveHard:dne];
    if (dneNode) {
        concNode = [GLDedNode infer:GLInference_DNI formula:conclusion withNodes:@[dneNode]];
        [self appendNode:concNode];
    }
    
    [_checkList liftRestriction:conclusion];
    return concNode;
}

-(GLDedNode *)infer_Hard_CP:(GLFormula *)conclusion{
    if (!conclusion.isConditional || ![self mayAttempt:GLInference_ConditionalProof
                                         forConclusion:conclusion]) return nil;
    
    [_checkList addRestriction:conclusion];
    
    GLFormula* ant = conclusion.firstDecomposition;
    GLFormula* cons = conclusion.secondDecomposition;
    
    GLDedNode* concNode = nil;
    GLDedNode* assumption = [GLDedNode infer:GLInference_AssumptionCP formula:ant withNodes:nil];

    [self subProofWithAssumption:assumption];
    GLDedNode* minorConcNode = [self proveHard:cons];
    
    if (minorConcNode) {
        concNode = [GLDedNode infer:GLInference_ConditionalProof formula:conclusion withNodes:@[assumption, minorConcNode]];
        [self appendNode:concNode];
    }else{
        [self removeNodesFrom:assumption];
    }
    
    [_checkList liftRestriction:conclusion];
    return concNode;
}

//---------------------------------------------------------------------------------------------------------
//      Deconstructive Inferences
//---------------------------------------------------------------------------------------------------------
#pragma mark Deconstructive Inferences

-(GLDedNode *)infer_Hard_CE:(GLFormula *)conclusion{
    if (![self mayAttempt:GLInference_ConjunctionElim forConclusion:conclusion]) return nil;
    
    NSArray<GLFormula*>* conjunctions = [self formulasForCEWithConclusion:conclusion];
    
    for (NSInteger i=0; i<conjunctions.count; i++) {
        BOOL lift = [self.checkList addRestriction:conjunctions[i] forRule:GLInference_ConjunctionIntro];
        GLDedNode* conjunctionNode = [self proveHard:conjunctions[i]];
        if (lift) [self.checkList liftRestriction:conjunctions[i] forRule:GLInference_ConjunctionIntro];
        if (conjunctionNode) {
            GLDedNode* concNode = [GLDedNode infer:GLInference_ConjunctionElim formula:conclusion withNodes:@[conjunctionNode]];
            [self appendNode:concNode];
            return concNode;
        }
    }
    return nil;
}

-(GLDedNode *)infer_Hard_DNE:(GLFormula *)conclusion{
    if (![self mayAttempt:GLInference_DNE forConclusion:conclusion]) return nil;
    
    GLFormula* dniConc = [conclusion.class makeNegationStrict:[conclusion.class makeNegationStrict:conclusion]];
    NSMutableSet<GLFormula*>* forms = [self allFormulaDecompositions];
    NSArray<GLFormula*>* allForms = forms.allObjects;
    for (NSInteger i=0; i<allForms.count; i++) {
        [forms addObject:[allForms[i].class makeNegationStrict:allForms[i]]];
    }
    if (![forms containsObject:dniConc]) return nil;
    
    [_checkList addRestriction:conclusion];
    BOOL lift = [self.checkList addRestriction:dniConc forRule:GLInference_DNI];
    
    GLDedNode* dniNode = [self proveHard:dniConc];
    
    [_checkList liftRestriction:conclusion];
    if (lift) [self.checkList liftRestriction:dniConc forRule:GLInference_DNI];
    
    if (dniNode) {
        GLDedNode* concNode = [GLDedNode infer:GLInference_DNE
                                       formula:conclusion
                                     withNodes:@[dniNode]];
        [self appendNode:concNode];
        return concNode;
    
    }
    return nil;
}

-(GLDedNode *)infer_Hard_BE:(GLFormula *)conclusion{
    if (![self mayAttempt:GLInference_BiconditionalElim forConclusion:conclusion] ||
        !conclusion.isConditional) return nil;
    
    [_checkList addRestriction:conclusion];
    
    GLFormula* ant = conclusion.firstDecomposition;
    GLFormula* cons = conclusion.secondDecomposition;
    GLFormula* bicon1 = [conclusion.class makeBiconditional:ant f2:cons];
    GLFormula* bicon2 = [conclusion.class makeBiconditional:cons f2:ant];
    GLDedNode* biconNode;
    
    BOOL lift = [self.checkList addRestriction:bicon1 forRule:GLInference_BiconditionalIntro];
    biconNode = [self proveHard:bicon1];
    if (lift) [self.checkList liftRestriction:bicon1 forRule:GLInference_BiconditionalIntro];
    
    if (!biconNode){
        lift = [self.checkList addRestriction:bicon2 forRule:GLInference_BiconditionalIntro];
        biconNode = [self proveHard:bicon2];
        if (lift) [self.checkList liftRestriction:bicon2 forRule:GLInference_BiconditionalIntro];
    }
    
    [_checkList liftRestriction:conclusion];
    
    if (biconNode) {
        return [self proveSoft:conclusion];
    }
    
    return nil;
}

-(GLDedNode *)infer_Hard_MP:(GLFormula *)conclusion{
    if (![self mayAttempt:GLInference_ModusPonens forConclusion:conclusion]) return nil;
    
    NSLog(@"Doing MP for %@", conclusion);
    
    [_checkList addRestriction:conclusion];
    
    NSArray<GLFormula*>* conditionals = [self formulasForMPWithConclusion:conclusion];
    GLDedNode* concNode = nil;
    
    for (NSInteger i=0; i<conditionals.count; i++) {
        GLDeductionIndex index = [self currentIndex];
        
        BOOL lift = [_checkList addRestriction:conditionals[i] forRule:GLInference_ConditionalProof];
        GLDedNode* conditionalNode = [self proveHard:conditionals[i]];
        if (lift) [_checkList liftRestriction:conditionals[i] forRule:GLInference_ConditionalProof];
        
        if (!conditionalNode){
            [self removeNodesFromIndex:index];
            continue;
        }
        
        GLFormula* antecedent = [conditionals[i] firstDecomposition];
        
        GLDedNode* antNode = [self proveHard:antecedent];
        if (!antNode){
            [self removeNodesFromIndex:index];
            continue;
        }
        
        concNode = [GLDedNode infer:GLInference_ModusPonens formula:conclusion withNodes:@[conditionalNode, antNode]];
        [self appendNode:concNode];
        break;
    }
    
    [_checkList liftRestriction:conclusion];
    return concNode;
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
    
    GLDedNode* concNode = nil;
    
    NSArray<GLFormula*>* disjunctionArray = [self formulasForDE];
    for (NSInteger i=0; i<disjunctionArray.count; i++) {
        GLFormula* disjunction = disjunctionArray[i];
        if ([_checkList disjunctionIsRestrictedForDE:disjunction]) continue;
        
        BOOL lift = [_checkList addRestriction:disjunction forRule:GLInference_DisjunctionIntro];
        GLDedNode* djNode = [self proveHard:disjunction];
        if (lift) [_checkList liftRestriction:disjunction forRule:GLInference_DisjunctionIntro];
        if (!djNode) continue;
        
        [_checkList addDERestriction:djNode.formula];
        concNode = [self infer_Hard_DE:conclusion withDisjunction:djNode];
        [_checkList liftDERestriction:djNode.formula];
        
        if (concNode) break;
    }
    return concNode;
}

-(GLDedNode *)infer_Hard_DE:(GLFormula *)conclusion withDisjunction:(GLDedNode *)node{
    
    GLFormula* dj1 = [node.formula firstDecomposition];
    GLFormula* dj2 = [node.formula secondDecomposition];
    
//    [self.logDelegate logNote:[NSString stringWithFormat:@"Opening subproof for DE"] deduction:self];
    GLDeductionIndex index = [self currentIndex];
    
    GLDedNode* conc2Node;
    GLDedNode* assumption2;
    GLDedNode* assumption1 = [GLDedNode infer:GLInference_AssumptionDE formula:dj1 withNodes:nil];
    [self subProofWithAssumption:assumption1];
    GLDedNode* conc1Node = [self proveHard:conclusion];
    [self stepDown];
    if (!conc1Node) goto here;
    
    assumption2 = [GLDedNode infer:GLInference_AssumptionDE formula:dj2 withNodes:nil];
    [self subProofWithAssumption:assumption2];
    conc2Node = [self proveHard:conclusion];
    
    
here:;
    if (conc1Node && conc2Node) {
        GLDedNode* concNode = [GLDedNode infer:GLInference_DisjunctionElim formula:conclusion withNodes:@[node, assumption1, conc1Node, assumption2, conc2Node]];
        [self appendNode:concNode];
        return concNode;
    }else{
        [self removeNodesFromIndex:index];
        return nil;
    }
}



//---------------------------------------------------------------------------------------------------------
//      Reductio
//---------------------------------------------------------------------------------------------------------
#pragma mark Reductio

-(GLDedNode *)infer_Hard_RAA:(GLFormula *)conclusion{
//    return nil;
    
    if (![self mayAttempt:GLInference_ReductioAA forConclusion:conclusion]) return nil;
    GLFormula* negConc = [conclusion.class makeNegation:conclusion];
    
    if ([self containsFormula:negConc]) return nil; //no need to prove by reductio if it's negation is already known. There may be occasions where we may want to do this, but we shouldn't ever NEED to do this!
    
    GLDedNode* assumption = [GLDedNode infer:GLInference_AssumptionRAA formula:negConc withNodes:nil];
    
    NSArray<GLFormula*>* formulasForReduction = [self formulasForReductio];
    
//    [self.logDelegate logNote:[NSString stringWithFormat:@"Attempting reductio on %@ to prove %@. The candidate formulas are %@", negConc, conclusion, formulasForReduction] deduction:self];
    
    for (NSInteger i=0; i<formulasForReduction.count; i++) {
        GLFormula* f1 = formulasForReduction[i];
        GLFormula* f2 = [f1.class makeNegation:f1];
        
        GLDeductionIndex index = [self currentIndex];
        [self subProofWithAssumption:assumption];
        
//        if ([self containsFormula:f1] || [self containsFormula:f2]) continue;
        
//        [self.logDelegate logNote:[NSString stringWithFormat:@"We first try to prove %@ before attempting %@", f1, f2] deduction:self];
        
        GLDedNode* cj1 = [self proveHard:f1];
        if (!cj1){
            [self removeNodesFromIndex:index];
            continue;
        }
        
//        [self.logDelegate logNote:[NSString stringWithFormat:@"We have proven %@ for reductio, now we try to prove %@", f1, f2] deduction:self];
        
        GLDedNode* cj2 = [self proveHard:f2];
        if (!cj2) {
            [self removeNodesFromIndex:index];
            continue;
        }
        
        GLFormula* negAssumption = [negConc.class makeNegationStrict:negConc];
        GLDedNode* negAssNode = [GLDedNode infer:GLInference_ReductioAA formula:negAssumption withNodes:@[assumption, cj1, cj2]];
        [self appendNode:negAssNode];
        return [self proveSoft:conclusion];
    }
    return nil;
}

@end
