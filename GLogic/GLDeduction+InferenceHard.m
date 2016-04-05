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
    
    GLDeduction* tempProof = [self tempProof];
    
    GLDedNode* cj1 = [tempProof proveHard:conclusion.firstDecomposition];
    if (cj1) {
        GLDedNode* cj2= [tempProof proveHard:conclusion.secondDecomposition];
        if (cj2) {
            [self assimilateDeduction:tempProof fromLine:self.sequence.count];
            concNode = [self append:conclusion
                               rule:GLInference_ConjunctionIntro
                       dependencies:@[cj1, cj2]];
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
    
    [_checkList addRestriction:conclusion];
    GLDeduction* tempProof = [self tempProof];
    
    GLDedNode* concNode = nil;
    GLDedNode* cond1Node = [tempProof proveHard:cond1];
    if (cond1Node) {
        GLDedNode* cond2Node = [tempProof proveHard:cond2];
        if (cond2Node) {
            [self assimilateDeduction:tempProof fromLine:self.sequence.count];
            concNode = [self append:conclusion rule:GLInference_BiconditionalIntro dependencies:@[cond1Node, cond2Node]];
        }
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
        concNode = [self append:conclusion rule:GLInference_DNI dependencies:@[dneNode]];
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
    
    GLDeduction* subproof = [self subProofWithAssumption:assumption];
    GLDedNode* minorConcNode = [subproof proveHard:cons];
    if (minorConcNode) {
        concNode = [GLDedNode infer:GLInference_ConditionalProof formula:conclusion withNodes:@[assumption, minorConcNode]];
        [concNode setSubProof:subproof];
        [concNode dischargeDependency:assumption];
        [self appendNode:concNode];
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
            return [self append:conclusion
                           rule:GLInference_ConjunctionElim
                   dependencies:@[conjunctionNode]];
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
    
    [_checkList addRestriction:conclusion];
    
    NSArray<GLFormula*>* conditionals = [self formulasForMPWithConclusion:conclusion];
    GLDedNode* concNode = nil;
    
    for (NSInteger i=0; i<conditionals.count; i++) {
        GLDeduction * tempDed = [self tempProof];
        
//        [self.logDelegate logNote:[NSString stringWithFormat:@"Attempting modus ponens for conclusion %@ by first proving %@ before proving %@", conclusion, conditionals[i], conditionals[i].firstDecomposition] deduction:self];
        
        BOOL lift = [_checkList addRestriction:conditionals[i] forRule:GLInference_ConditionalProof];
        GLDedNode* conditionalNode = [tempDed proveHard:conditionals[i]];
        if (lift) [_checkList liftRestriction:conditionals[i] forRule:GLInference_ConditionalProof];
        
        if (!conditionalNode) continue;
        
        GLFormula* antecedent = [conditionals[i] firstDecomposition];
        
//        [self.logDelegate logNote:[NSString stringWithFormat:@"Proved %@, now we prove %@ to infer conclusion %@", conditionalNode.formula, antecedent, conclusion] deduction:self];
        
        GLDedNode* antNode = [tempDed proveHard:antecedent];
        if (!antNode) continue;
        
        [self assimilateDeduction:tempDed fromLine:self.sequence.count];
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
    GLFormula* cond1 = [dj1.class makeConditional:dj1 f2:conclusion];
    GLFormula* cond2 = [dj1.class makeConditional:dj2 f2:conclusion];
    
//    [self.logDelegate logNote:[NSString stringWithFormat:@"Opening subproof for DE"] deduction:self];
    
    GLDeduction * subproof = [self subProofWithAssumption:nil];
    
    GLDedNode* cond1Node = [subproof infer_Hard_CPDE:cond1];
    if (!cond1Node) return nil;
    
    GLDedNode* cond2Node = [subproof infer_Hard_CPDE:cond2];
    if (!cond2Node) return nil;
    
    [subproof appendNode:cond1Node];
    [subproof appendNode:cond2Node];
    
    GLDedNode* concNode = [GLDedNode infer:GLInference_DisjunctionElim formula:conclusion withNodes:@[node, cond1Node, cond2Node]];
    [self appendNode:concNode];
    [concNode setSubProof:subproof];
    return concNode;
}


-(GLDedNode *)infer_Hard_CPDE:(GLFormula *)conclusion{
    if (![self mayAttempt:GLInference_ConditionalProofDE forConclusion:conclusion]) return nil;
    else if (!conclusion.isConditional) return nil;
    
    GLFormula* ant = conclusion.firstDecomposition;
    GLFormula* cons = conclusion.secondDecomposition;
    
    GLDedNode* assumptionNode = [GLDedNode infer:GLInference_AssumptionDE formula:ant withNodes:nil];
    
//    [self.logDelegate logNote:[NSString stringWithFormat:@"Opening subproof for CPDE to prove %@", conclusion] deduction:self];
    GLDeduction* subproof = [self subProofWithAssumption:assumptionNode];
        
    GLDedNode* minorConc = [subproof proveHard:cons];
    if (minorConc) {
        GLDedNode* concNode = [GLDedNode infer:GLInference_ConditionalProofDE formula:conclusion withNodes:@[assumptionNode, minorConc]];
        [concNode setSubProof:subproof];
        [concNode dischargeDependency:assumptionNode];
        return concNode;
    }
    return nil;
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
    
    GLDeduction* subProof = [self subProofWithAssumption:assumption];
    
    for (NSInteger i=0; i<formulasForReduction.count; i++) {
        GLFormula* f1 = formulasForReduction[i];
        GLFormula* f2 = [f1.class makeNegation:f1];
        
//        if ([self containsFormula:f1] || [self containsFormula:f2]) continue;
        
//        [self.logDelegate logNote:[NSString stringWithFormat:@"We first try to prove %@ before attempting %@", f1, f2] deduction:self];
        
        GLDedNode* cj1 = [subProof proveHard:f1];
        if (!cj1) continue;
        
//        [self.logDelegate logNote:[NSString stringWithFormat:@"We have proven %@ for reductio, now we try to prove %@", f1, f2] deduction:self];
        
        GLDedNode* cj2 = [subProof proveHard:f2];
        if (!cj2) continue;
        
        GLFormula* negAssumption = [negConc.class makeNegationStrict:negConc];
        GLDedNode* negAssNode = [GLDedNode infer:GLInference_ReductioAA formula:negAssumption withNodes:@[assumption, cj1, cj2]];
        [negAssNode setSubProof:subProof];
        [negAssNode dischargeDependency:assumption];
        [self appendNode:negAssNode];
        return [self proveSoft:conclusion];
    }
    return nil;
}

@end
