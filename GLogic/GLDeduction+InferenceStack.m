//
//  GLDeduction+InferenceStack.m
//  GLogic
//
//  Created by Thomas Gray on 13/04/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "GLDeduction+InferenceStack.h"
#import "GLInference.h"


@implementation GLDeduction (InferenceStack)

-(BOOL)proveHard:(GLInference *)conclusion{
//    NSLog(@"%@\n%@", _rootInference, self);
//    NSLog(@"Stack count: %ld", [NSThread callStackSymbols].count);
    
    @autoreleasepool {
        GLDedNode* concNode = [self proveSoftSafe:conclusion.formula];
        if (concNode) {
            [conclusion setNode:concNode];
        }
        
        //constructive inferences
        else if ([self infer_Hard_CI:conclusion]){}
        else if ([self infer_Hard_DI:conclusion]){}
        else if ([self infer_Hard_BI:conclusion]){}
        else if ([self infer_Hard_DNI:conclusion]){}
        else if ([self infer_Hard_CP:conclusion]){}
        
        //eliminative inferences
        else if ([self infer_Hard_CE:conclusion]){}
        else if ([self infer_Hard_BE:conclusion]){}
        else if ([self infer_Hard_DNE:conclusion]){}
        else if ([self infer_Hard_MP:conclusion]){}
        else if ([self infer_Hard_MT:conclusion]){}
        
        //tricky ones
        else if ([self infer_Hard_DE:conclusion]){}
        else if ([self infer_Hard_RAA:conclusion]){}
        
        else{
            [conclusion setSubInferences:nil];
        }
    }
    
    return conclusion.isProven;
}


//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//
#pragma mark Constructive Inferences
//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//

-(BOOL)infer_Hard_CI:(GLInference *)conclusion{
    [conclusion setInferenceRule:GLInference_ConjunctionIntro];
    if (![conclusion mayAttempt]) return FALSE;
    
    GLInference* cj1 = [GLInference inferenceWithFormula:conclusion.formula.firstDecomposition];
    [cj1 addRestriction:conclusion.formula];
    GLInference* cj2 = [GLInference inferenceWithFormula:conclusion.formula.secondDecomposition];
    [cj2 addRestriction:conclusion.formula];
    
    [conclusion setSubInferences:@[cj1, cj2]];
    
    GLDeductionIndex index = [self currentIndex];
    
    if ([self proveHard:cj1]) [self proveHard:cj2];
    
    if (cj1.isProven && cj2.isProven) {
        GLDedNode* node = [GLDedNode infer:GLInference_ConjunctionIntro formula:conclusion.formula withNodes:@[cj1.node, cj2.node]];
        [conclusion setNode:node];
        [self appendNode:node];
        return TRUE;
    }else{
        [conclusion setSubInferences:nil];
        [self removeNodesFromIndex:index];
        return FALSE;
    }
}

-(BOOL)infer_Hard_DI:(GLInference *)conclusion{
    [conclusion setInferenceRule:GLInference_DisjunctionIntro];
    if (![conclusion mayAttempt]) return FALSE;
    
    GLDeductionIndex index = [self currentIndex];
    
    GLInference* dj = [GLInference inferenceWithFormula:conclusion.formula.firstDecomposition];
    [dj addRestriction:conclusion.formula];
    [conclusion setSubInferences:@[dj]];
    
    if (![self proveHard:dj]) {
        [dj setFormula:conclusion.formula.secondDecomposition];
        [self proveHard:dj];
    }
    
    if (dj.isProven) {
        GLDedNode* node = [GLDedNode infer:GLInference_DisjunctionIntro formula:conclusion.formula withNodes:@[dj.node]];
        [self appendNode:node];
        [conclusion setNode:node];
        return TRUE;
    }else{
        [conclusion setSubInferences:nil];
        [self removeNodesFromIndex:index];
        return FALSE;
    }
}

-(BOOL)infer_Hard_DNI:(GLInference *)conclusion{
    [conclusion setInferenceRule:GLInference_DNI];
    if (![conclusion mayAttempt]) return FALSE;
    
    GLFormula* dneFormula = [conclusion.formula getDecompositionAtNode:@[@0,@0]];
    GLInference* dne = [GLInference inferenceWithFormula:dneFormula];
    [dne addRestriction:conclusion.formula];
    GLDeductionIndex index = [self currentIndex];
    
    if ([self proveHard:dne]) {
        GLDedNode* node = [GLDedNode infer:GLInference_DNI formula:conclusion.formula withNodes:@[dne.node]];
        [self appendNode:node];
        [conclusion setNode:node];
        return TRUE;
    }else{
        [conclusion setSubInferences:nil];
        [self removeNodesFromIndex:index];
        return FALSE;
    }
}

-(BOOL)infer_Hard_BI:(GLInference *)conclusion{
    [conclusion setInferenceRule:GLInference_BiconditionalIntro];
    if (![conclusion mayAttempt]) return FALSE;
    
    Class class = conclusion.formula.class;
    GLFormula* c1Formula = [class makeConditional:conclusion.formula.firstDecomposition
                                               f2: conclusion.formula.secondDecomposition];
    GLFormula* c2Formula = [class makeConditional:conclusion.formula.secondDecomposition
                                               f2:conclusion.formula.firstDecomposition];
    
    GLInference* c1 = [GLInference inferenceWithFormula:c1Formula];
    [c1 addRestriction:conclusion.formula];
    GLInference* c2 = [GLInference inferenceWithFormula:c2Formula];
    [c2 addRestriction:conclusion.formula];
    
    [conclusion setSubInferences:@[c1,c2]];
    GLDeductionIndex index = [self currentIndex];
    
    if ([self proveHard:c1]) [self proveHard:c2];
    
    if (c1.isProven && c2.isProven) {
        GLDedNode* node = [GLDedNode infer:GLInference_BiconditionalIntro formula:conclusion.formula withNodes:@[c1.node, c2.node]];
        [self appendNode:node];
        [conclusion setNode:node];
        return TRUE;
    }else{
        [conclusion setSubInferences:nil];
        [self removeNodesFromIndex:index];
        return FALSE;
    }
}

-(BOOL)infer_Hard_CP:(GLInference *)conclusion{
    [conclusion setInferenceRule:GLInference_ConditionalProof];
    if (![conclusion mayAttempt]) return FALSE;
    
    GLDeductionIndex index = [self currentIndex];
    
    GLDedNode* antecedent = [GLDedNode infer:GLInference_AssumptionCP formula:conclusion.formula.firstDecomposition withNodes:nil];
    [self appendNode:antecedent];
    
    GLInference* minorConc = [GLInference inferenceWithFormula:conclusion.formula.secondDecomposition];
    [conclusion setSubInferences:@[minorConc]];
    [minorConc addRestriction:conclusion.formula];
    
    if ([self proveHard:minorConc]) {
        GLDedNode* node = [GLDedNode infer:GLInference_ConditionalProof formula:conclusion.formula withNodes:@[minorConc.node]];
        [self appendNode:node];
        [conclusion setNode:node];
        return TRUE;
    }else{
        [conclusion setSubInferences:nil];
        [self removeNodesFromIndex:index];
        return FALSE;
    }
}

//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//
#pragma mark Eliminative Inferences
//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//

-(BOOL)infer_Hard_CE:(GLInference *)conclusion{
    [conclusion setInferenceRule:GLInference_ConjunctionElim];
    if (![conclusion mayAttempt]) return FALSE;
    
    NSArray<GLFormula*>* conjunctions = [self formulasForCEWithConclusion:conclusion.formula];
    
    for (NSInteger i=0; i<conjunctions.count; i++) {
        GLInference* conjunction = [GLInference inferenceWithFormula:conjunctions[i]];
        [conjunction addRestriction:conclusion.formula];
        [conjunction addRestriction:conjunction.formula rule:GLInference_ConjunctionIntro];
        [conjunction addRestriction:conjunction.formula rule:GLInference_ReductioAA];
        [conclusion setSubInferences:@[conjunction]];
        GLDeductionIndex index= [self currentIndex];
        
        if ([self proveHard:conjunction]) {
            GLDedNode* node = [GLDedNode infer:GLInference_ConjunctionElim formula:conclusion.formula withNodes:@[conjunction.node]];
            [self appendNode:node];
            [conclusion setNode:node];
            return TRUE;
        }else{
            [self removeNodesFromIndex:index];
        }
    }
    [conclusion setSubInferences:nil];
    return FALSE;
}


-(BOOL)infer_Hard_DNE:(GLInference *)conclusion{
    [conclusion setInferenceRule:GLInference_DNE];
    if (![conclusion mayAttempt]) return FALSE;
    
    GLFormula* dni = [conclusion.formula.class makeNegationStrict:conclusion.formula];
    dni = [dni.class makeNegationStrict:dni];
    
    NSSet<GLFormula*>* decompositions = [self allFormulaDecompositions];
    if (![decompositions containsObject:dni]) return FALSE;
    
    GLInference* dniInference = [GLInference inferenceWithFormula:dni];
    [dniInference addRestriction:conclusion.formula];
    [dniInference addRestriction:dni rule:GLInference_DNI];
    [dniInference addRestriction:dni rule:GLInference_ReductioAA];
    [conclusion setSubInferences:@[dniInference]];
    
    if ([self proveHard:dniInference]) {
        GLDedNode* node = [GLDedNode infer:GLInference_DNE formula:conclusion.formula withNodes:@[dniInference.node]];
        [self appendNode:node];
        [conclusion setNode:node];
        return TRUE;
    }else{
        [conclusion setSubInferences:nil];
        return FALSE;
    }
}

-(BOOL)infer_Hard_BE:(GLInference *)conclusion{
    [conclusion setInferenceRule:GLInference_BiconditionalElim];
    if (![conclusion mayAttempt]) return FALSE;

    GLFormula* antecedent = conclusion.formula.firstDecomposition;
    GLFormula* consequent = conclusion.formula.secondDecomposition;
    NSArray<GLFormula*>* biconditionals = @[
                                    [antecedent.class makeBiconditional:antecedent f2:consequent],
                                    [antecedent.class makeBiconditional:consequent f2:antecedent]
                                    ];
    
    for (NSInteger i=0; i<biconditionals.count; i++) {
        GLFormula* biconFormula = biconditionals[i];
        GLInference* biconditional = [GLInference inferenceWithFormula:biconFormula];
        [biconditional addRestriction:conclusion.formula];
        [biconditional addRestriction:biconFormula rule:GLInference_BiconditionalIntro];
        [biconditional addRestriction:biconFormula rule:GLInference_ReductioAA];
        [conclusion setSubInferences:@[biconditional]];
        GLDeductionIndex index = [self currentIndex];
        
        if ([self proveHard:biconditional]) {
            GLDedNode* node = [GLDedNode infer:GLInference_BiconditionalElim formula:conclusion.formula withNodes:@[biconditional.node]];
            [conclusion setNode:node];
            [self appendNode:node];
            return TRUE;
        }else [self removeNodesFromIndex:index];
    }
    
    [conclusion setSubInferences:nil];
    return FALSE;
}

-(BOOL)infer_Hard_MP:(GLInference *)conclusion{
    [conclusion setInferenceRule:GLInference_ModusPonens];
    if (![conclusion mayAttempt]) return FALSE;
    
    NSArray<GLFormula*>* formulas = [self formulasForMPWithConclusion:conclusion.formula];
    for (NSInteger i=0; i<formulas.count; i++) {
        GLFormula* conditional = formulas[i];
        GLDeductionIndex index = [self currentIndex];
        
        GLInference* cond = [GLInference inferenceWithFormula:conditional];
        [cond addRestriction:conclusion.formula];
        [cond addRestriction:cond.formula rule:GLInference_ConditionalProof];
        [cond addRestriction:cond.formula rule:GLInference_ReductioAA];
        
        GLInference* ant = [GLInference inferenceWithFormula:conditional.firstDecomposition];
        [ant addRestriction:conclusion.formula];
        
        [conclusion setSubInferences:@[cond, ant]];
        
        if ([self proveHard:cond] && [self proveHard:ant]) {
            GLDedNode* node = [GLDedNode infer:GLInference_ModusPonens formula:conclusion.formula withNodes:@[cond.node, ant.node]];
            [self appendNode:node];
            [conclusion setNode:node];
            return TRUE;
        }else{
            [self removeNodesFromIndex:index];
        }
    }
    [conclusion setSubInferences:nil];
    return FALSE;
}

-(BOOL)infer_Hard_MT:(GLInference *)conclusion{
    [conclusion setInferenceRule:GLInference_ModusTollens];
    if (![conclusion mayAttempt]) return FALSE;
    
    NSArray<GLFormula*>* conditionals = [self formulasForMTWithConclusion:conclusion.formula];
    for (NSInteger i=0; i<conditionals.count; i++) {
        GLInference* conditional = [GLInference inferenceWithFormula:conditionals[i]];
        GLInference* negCons = [GLInference inferenceWithFormula:
                                [conditionals[i].class makeNegationStrict:conditionals[i].secondDecomposition]];
        [conditional addRestriction:conclusion.formula];
        [conditional addRestriction:conditional.formula rule:GLInference_ConditionalProof];
        [conditional addRestriction:conditional.formula rule:GLInference_ReductioAA];
        [negCons addRestriction:conclusion.formula];
        GLDeductionIndex index = [self currentIndex];
        
        [conclusion setSubInferences:@[conditional, negCons]];
        
        if ([self proveHard:conditional] && [self proveHard:negCons]) {
            GLFormula* negAntFormula = [conditional.formula.class makeNegationStrict:conditional.formula.firstDecomposition];
            GLDedNode* negAntNode = [GLDedNode infer:GLInference_ModusTollens formula:negAntFormula withNodes:@[conditional.node, negCons.node]];
            [self appendNode:negAntNode];
            [conclusion setNode:negAntNode];
            
            if (![conclusion.formula isEqual:negAntFormula]) {
                GLInference* negAntInference = [GLInference inferenceWithFormula:negAntNode.formula];
                [negAntInference setInferenceRule:GLInference_ModusTollens];
                [negAntInference setNode:negAntNode];
                [negAntInference setSubInferences:conclusion.subInferences];
                
                [conclusion setSubInferences:@[negAntInference]];
                [conclusion setInferenceRule:GLInference_DNE];
                
                GLDedNode* dne = [GLDedNode infer:GLInference_DNE formula:conclusion.formula withNodes:@[negAntNode]];
                [conclusion setNode:dne];
                [self appendNode:dne];
            }
            return TRUE;
        }else{
            [self removeNodesFromIndex:index];
        }
    }
    
    [conclusion setSubInferences:nil];
    return FALSE;
}



//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//
#pragma mark Tricky Ones
//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//


-(BOOL)infer_Hard_DE:(GLInference *)conclusion{
    [conclusion setInferenceRule:GLInference_DisjunctionElim];
    if (![conclusion mayAttempt]) return FALSE;
    
    NSArray<GLFormula*>* disjunctions = [self formulasForDE];
    for (NSInteger i=0; i<disjunctions.count; i++) {
        if (![conclusion mayAttempt_DE_withDisjunction:disjunctions[i]]) continue;
        GLInference* dj = [GLInference inferenceWithFormula:disjunctions[i]];
        [dj addRestriction:dj.formula rule:GLInference_DisjunctionIntro];
        [dj addRestriction:dj.formula rule:GLInference_ReductioAA];
        GLDeductionIndex index = [self currentIndex];
        
        GLInference* minorConc1 = [GLInference inferenceWithFormula:conclusion.formula];
        GLInference* minorConc2 = [GLInference inferenceWithFormula:conclusion.formula];

        [conclusion setSubInferences:@[dj, minorConc1, minorConc2]];
        
        if ([self proveHard:dj]) {
            GLDedNode* ass1 = [GLDedNode infer:GLInference_AssumptionDE
                                       formula:disjunctions[i].firstDecomposition
                                     withNodes:nil];
            GLDedNode* ass2 = [GLDedNode infer:GLInference_AssumptionDE
                                       formula:disjunctions[i].secondDecomposition
                                     withNodes:nil];
            [self appendNode:ass1];
            if (![self proveHard:minorConc1]) goto endOfLoop;
            
            [self stepDown];
            
            [self appendNode:ass2];
            if (![self proveHard:minorConc2]) goto endOfLoop;
            
            [conclusion setNode:[GLDedNode infer:GLInference_DisjunctionElim formula:conclusion.formula withNodes:@[dj.node, ass1, minorConc1.node, ass2, minorConc2.node]]];
            [self appendNode:conclusion.node];
            return TRUE;
        }
    endOfLoop:
        [self removeNodesFromIndex:index];
    }
    
    [conclusion setSubInferences:nil];
    return FALSE;
}



-(BOOL)infer_Hard_RAA:(GLInference *)conclusion{
    [conclusion setInferenceRule:GLInference_ReductioAA];
    if (![conclusion mayAttempt]) return FALSE;
    
    Class class = conclusion.formula.class;
    GLFormula* nConc = [class makeNegation:conclusion.formula];
    GLFormula* nnConc = [class makeNegationStrict:nConc];
    
    if ([self findAvailableNode:nConc]) return FALSE;
    
    GLDedNode* assumption = [GLDedNode infer:GLInference_AssumptionRAA
                                     formula:nConc
                                   withNodes:nil];
    
    GLDeductionIndex preassumptionIndex = [self currentIndex];
    [self appendNode:assumption];
    
    NSArray<GLFormula*>* formulas = [self formulasForReductio];
    for (NSInteger i=0; i<formulas.count; i++) {
        GLDeductionIndex postAssumptionIndex = [self currentIndex];
        GLInference* f = [GLInference inferenceWithFormula:formulas[i]];
        GLInference* nf = [GLInference inferenceWithFormula:[class makeNegationStrict:f.formula]];
        [conclusion setSubInferences:@[f, nf]];
        
        if ([self proveHard:f] && [self proveHard:nf]) {
            [conclusion setNode:[GLDedNode infer:GLInference_ReductioAA formula:nnConc withNodes:@[assumption, f.node, nf.node]]];
            [self appendNode:conclusion.node];
            
            if (![conclusion.formula isEqual:nnConc]) {
                GLInference* nnConcInference = [GLInference inferenceWithFormula:nnConc];
                [nnConcInference setSubInferences:conclusion.subInferences];
                [nnConcInference setInferenceRule:GLInference_ReductioAA];
                [nnConcInference setNode:conclusion.node];
                
                [conclusion setSubInferences:@[nnConcInference]];
                [conclusion setInferenceRule:GLInference_DNE];
                [conclusion setNode:[GLDedNode infer:GLInference_DNE formula:conclusion.formula withNodes:@[nnConcInference.node]]];
                
                [self appendNode:conclusion.node];
            }
            return TRUE;
            
        }else{
            [self removeNodesFromIndex:postAssumptionIndex];
        }
        
    }
    
    [self removeNodesFromIndex:preassumptionIndex];
    [conclusion setSubInferences:nil];
    return FALSE;
}















@end
