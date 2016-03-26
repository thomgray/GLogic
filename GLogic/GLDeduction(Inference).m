//
//  GLDeduction(Inference).m
//  GLogic
//
//  Created by Thomas Gray on 16/03/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "GLDeduction(Inference).h"

//---------------------------------------------------------------------------------------------------------
//      Inference Private Interface
//---------------------------------------------------------------------------------------------------------
#pragma mark Inference Private Interface

@interface GLDeduction (InferencePrivate)

-(GLDedNode*)infer_SoftSteps_AllSteps:(GLFormula*)conc rule:(GLInferenceRule)rule steps:(NSArray<GLFormula*>*)steps;
-(GLDedNode *)infer_SoftSteps_AnyStep:(GLFormula *)conc rule:(GLInferenceRule)rule steps:(NSArray<GLFormula *> *)steps;
-(GLDedNode *)infer_SoftSteps_CP:(GLFormula *)conc rule:(GLInferenceRule)rule steps:(NSArray<GLFormula *> *)steps;

-(GLDedNode*)infer_SoftBlock_Standard:(DirectedInferenceBlock)block conclusion:(GLFormula *)conc;
-(GLDedNode *)infer_SoftBlock_Disjunctive:(DirectedInferenceBlock)block conclusion:(GLFormula *)conc;
-(GLDedNode *)infer_SoftBlock_CP:(DirectedInferenceBlock)block conclusion:(GLFormula *)conc;



@end

#pragma mark
//---------------------------------------------------------------------------------------------------------
//      Inference Implementation
//---------------------------------------------------------------------------------------------------------
#pragma mark Inference Implementation

@implementation GLDeduction (Inference)

//---------------------------------------------------------------------------------------------------------
//      Prove Hard
//---------------------------------------------------------------------------------------------------------
#pragma mark Prove Hard

-(GLDedNode *)proveHard:(GLFormula *)conclusion{
    GLDedNode* out;
    if ((out=[self proveSemiSoft:conclusion])) {}

    return out;
}


//---------------------------------------------------------------------------------------------------------
//      Prove Soft
//---------------------------------------------------------------------------------------------------------
#pragma mark Prove Soft

-(GLDedNode*)proveSemiSoft:(GLFormula*)conclusion{
    GLDedNode * out;
    if ((out=[self proveSoft:conclusion])) return out;
    else if ((out=[self infer_SemiSoft_DE:conclusion])) return out;
    return nil;
}

-(GLDedNode *)proveSoft:(GLFormula *)conclusion{
    GLDedNode* out;
    [self proveGenerative];
    if ((out = [self findNodeInSequence:conclusion])) return out;
    else if ((out = [self infer_SoftBlock:[GLDeductionBlocks directed_BI] conclusion:conclusion])) {}
    else if ((out = [self infer_SoftBlock:[GLDeductionBlocks directed_CI] conclusion:conclusion])) {}
    else if ((out = [self infer_SoftBlock:[GLDeductionBlocks directed_DI] conclusion:conclusion])) {}
    else if ((out = [self infer_SoftBlock:[GLDeductionBlocks directed_DNI] conclusion:conclusion])) {}
    else if ((out = [self infer_SoftBlock:[GLDeductionBlocks directed_CP] conclusion:conclusion])) {}
    return out;
}

//---------------------------------------------------------------------------------------------------------
//      Generative Inferences
//---------------------------------------------------------------------------------------------------------
#pragma mark Generative Inferences

-(BOOL)proveGenerative{
    BOOL out = FALSE;
    BOOL repeat;
    do {
        repeat = FALSE;
        repeat = [self infer_GenerativeBlock:[GLDeductionBlocks generative_CE]] || repeat;
        repeat = [self infer_GenerativeBlock:[GLDeductionBlocks generative_BE]] || repeat;
        repeat = [self infer_GenerativeBlock:[GLDeductionBlocks generative_DNE]] || repeat;
        repeat = [self infer_GenerativeBlock:[GLDeductionBlocks generative_MP]] || repeat;
        repeat = [self infer_GenerativeBlock:[GLDeductionBlocks generative_MT]] || repeat;
        out = out || repeat;
    } while (repeat);
    return out;
}

-(BOOL)infer_GenerativeBlock:(GenerativeInferenceBlock)block{
    BOOL out = FALSE;
    for (NSInteger i=0; i<self.sequence.count; i++) {
        GLDedNode* node = self.sequence[i];
        NSArray<GLDedNode*>* inferences = block(node, self);
        if (inferences) {
            for (NSInteger j=0; j<inferences.count; j++) {
                if ([self isInformedBy:inferences[j].formula]) {
                    [self appendNode:inferences[j]];
                    out = TRUE;
                }
            }
        }
    }
    return out;
}

//---------------------------------------------------------------------------------------------------------
//      Soft Inferences
//---------------------------------------------------------------------------------------------------------
#pragma mark Soft Inferences

-(GLDedNode *)infer_SoftBlock:(DirectedInferenceBlock)block conclusion:(GLFormula *)conc{
    GLInferenceResult* result = block(conc);
    if (result) {
        switch (result.rule) {
            case GLInference_DisjunctionIntro:
                return [self infer_SoftSteps_AnyStep:conc rule:result.rule steps:result.steps];
                break;
            case GLInference_ConditionalProof:
            case GLInference_ConditionalProofDE:
                return [self infer_SoftSteps_CP:conc rule:result.rule steps:result.steps];
                break;
            default:
                return [self infer_SoftSteps_AllSteps:conc rule:result.rule steps:result.steps];
                break;
        }
    }else return nil;
}

-(GLDedNode *)proveSoft_withCriterion:(GLFormulaCriterion)criterion includingNegations:(BOOL)includeNegs includingConclusion:(BOOL)includeConc{
    NSSet<GLFormula*>* concs = [self getAllFormulaDecompositions_includingNegations:includeNegs includingConclusion:includeConc];
    NSArray<GLFormula*>* concArray = [concs allObjects];
    GLDedNode* out;
    for (NSInteger i=0; i<concArray.count; i++) {
        GLFormula* f = concArray[i];
        if ((out=[self proveSoft:f])){
            return out;
        }
    }
    return nil;
}

-(GLDedNode *)infer_SoftSteps_AllSteps:(GLFormula *)conc rule:(GLInferenceRule)rule steps:(NSArray<GLFormula *> *)steps{
    NSMutableArray<GLDedNode*>* stepNodes = [[NSMutableArray alloc]init];
    for (NSInteger i=0; i<steps.count; i++) {
        GLDedNode* step = [self proveSoft:steps[i]];
        if (!step) return nil;
        [stepNodes addObject:step];
    }
    return [self append:conc rule:rule dependencies:stepNodes];
}

-(GLDedNode *)infer_SoftSteps_AnyStep:(GLFormula *)conc rule:(GLInferenceRule)rule steps:(NSArray<GLFormula *> *)steps{
    for (NSInteger i=0; i<steps.count; i++) {
        GLDedNode* step = [self proveSoft:steps[i]];
        if (step){
            return [self append:conc rule:rule dependencies:@[step]];
        }
    }
    return nil;
}

-(GLDedNode *)infer_SoftSteps_CP:(GLFormula *)conc rule:(GLInferenceRule)rule steps:(NSArray<GLFormula *> *)steps{
    GLInferenceRule assumptionRule;
    switch (rule) {
        case GLInference_ConditionalProof:
            assumptionRule = GLInference_AssumptionCP;
            break;
        case GLInference_ConditionalProofDE:
            assumptionRule = GLInference_AssumptionDE;
            break;
        default:
            return nil;
    }
    GLDedNode* assumption = [GLDedNode infer:assumptionRule formula:steps[0] withNodes:nil];
    GLDeduction* subproof = [self subProofWithAssumption:assumption];
    GLDedNode* consequent = [subproof proveSoft:steps[1]];
    if (consequent) {
        GLDedNode* out = [GLDedNode infer:rule formula:conc withNodes:@[assumption, consequent]];
        [out setSubProof:subproof];
        [self appendNode:out];
        return out;
    }else return nil;
}


//---------------------------------------------------------------------------------------------------------
//      Semi Soft Inferences
//---------------------------------------------------------------------------------------------------------
/*These methods do not safely recur, and hence cannot be called by 'proveSoft:'. They may themselves call 'proveSoft:'. Hence they represent a halfway force of proof between hard and soft proofs. These methods are really inessential as they are just weaker versions of their respective 'proveHard:' methods, but exist for the sake of having an inexpensive inference method for the inference rules here.
 */
#pragma mark Semi Soft Inferences
/**
 * Checks for all disjunctions in the sequence. Calls <code>infer_Soft_CPDE:disjuncion:</code> for each disjunction in attempting to infer:
 <ul>
 <li>D1->C</li>
 <li>D2->C</li>
 </ul>
 until either they are proven or the disjunctions are exhausted. If no result obtains so far, nil is returned. If both conditionals are inferred, the conclusion is appended to the deduction as a disjunction elimination, and returned.<p/>
 <p> @b Calls:</p><p> <code>infer_Soft_CPDE:disjuncion:</code></p>
 <p><code>getNodesWithCriterion</code> </p>
 * @param conc The conclusion
 * @return GLDedNode* The conclusion node, or nil if not inferred
 */
-(GLDedNode *)infer_SemiSoft_DE:(GLFormula *)conc{
    NSArray<GLDedNode*>* disjunctions = [self getNodesWithCriterion:^BOOL(GLDedNode *node) {
        return node.formula.isDisjunction;
    }];
    for (NSInteger i=0; i<disjunctions.count; i++) {
        GLDedNode* dj = disjunctions[i];
        GLFormula* c1 = [GLFormula makeConditional:[dj.formula getDecomposition:0] f2:conc];
        GLFormula* c2 = [GLFormula makeConditional:[dj.formula getDecomposition:1] f2:conc];
        GLDedNode* cdNode1;
        GLDedNode* cdNode2;
        if ((cdNode1=[self infer_SoftBlock:[GLDeductionBlocks directed_CPDE] conclusion:c1]) &&
            (cdNode2=[self infer_SoftBlock:[GLDeductionBlocks directed_CPDE] conclusion:c2])) {
            return [self append:conc rule:GLInference_DisjunctionElim dependencies:@[dj, cdNode1, cdNode2]];
        }
    }
    return nil;
}

-(GLDedNode *)proveSemiSoft_withCriterion:(GLFormulaCriterion)criterion includingNegations:(BOOL)includeNegations includingConclusion:(BOOL)includeConclusion{
    NSSet<GLFormula*>* formulas = [self getAllFormulaDecompositions_includingNegations:includeNegations includingConclusion:includeConclusion];
    NSArray<GLFormula*>* formArray = [formulas allObjects];
    GLDedNode* out;
    for (NSInteger i=0; i<formArray.count; i++) {
        GLFormula* f = formArray[i];
        if ((out=[self proveSemiSoft:f])) {
            return out;
        }
    }
    return nil;
}


//---------------------------------------------------------------------------------------------------------
//      Hard Inferences
//---------------------------------------------------------------------------------------------------------
#pragma mark Hard Inferences

-(GLDedNode *)proveHard_withCriterion:(GLFormulaCriterion)criterion includingNegations:(BOOL)includeNegs includingConclusion:(BOOL)includeConclusion{
    NSSet<GLFormula*>* formulas = [self getAllFormulaDecompositions_includingNegations:includeNegs includingConclusion:includeConclusion];
    NSArray<GLFormula*>* formulaArray = [formulas allObjects];
    GLDedNode* out;
    for (NSInteger i=0; i<formulaArray.count; i++) {
        GLFormula* f = formulaArray[i];
        if ((out=[self proveHard:f])) {
            return out;
        }
    }
    return nil;
}

-(GLDedNode *)infer_Hard_CI:(GLFormula *)conc{
    if (!conc.isConjunction)return nil;
    else if (![self mayAttempt:GLInference_ConjunctionIntro forConclusion:conc]) return nil;
    
    GLFormula* left = [conc getDecomposition:0];
    GLFormula* right = [conc getDecomposition:1];
    GLDedNode* leftNode;
    GLDedNode* rightNode;
    if ((leftNode=[self proveSemiSoft:left]) || (leftNode=[self proveHard:left])){}
    else return nil;
    
    if ((rightNode=[self proveSemiSoft:right]) || (rightNode=[self proveHard:right])) {
        return [GLDedNode infer_CI:leftNode right:rightNode];
    }else return nil;
}

-(GLDedNode *)infer_Hard_CE:(GLFormula *)conc{
    if (![self mayAttempt:GLInference_ConjunctionElim forConclusion:conc]) return nil;
    //criterion
    GLFormulaCriterion conjunctionCriterion = ^BOOL(GLFormula * object){
        if ([object isConjunction]) {
            GLFormula* leftConjunct = [object getDecomposition:0];
            GLFormula* rightConjunct = [object getDecomposition:1];
            return [conc isEqual:leftConjunct] || [conc isEqual:rightConjunct];
        }else return FALSE;
    };
    
    GLDedNode* conjunctinNode;
    GLDedNode* concNode;
    
    [self.checkList addRestriction:conc];
    if ((conjunctinNode=[self proveSemiSoft_withCriterion:conjunctionCriterion includingNegations:NO includingConclusion:NO]) || (conjunctinNode=[self proveHard_withCriterion:conjunctionCriterion includingNegations:NO includingConclusion:NO])) {
        concNode = [GLDedNode infer_CE:conjunctinNode leftFormula:[[conjunctinNode.formula getDecomposition:0] isEqual:conc]];
    }
    [self.checkList liftRestriction:conc];
    //give up
    return concNode;
}

-(GLDedNode *)infer_Hard_BE:(GLFormula *)conc{
    if (!conc.isConditional) return nil;
    else if (![self mayAttempt:GLInference_BiconditionalElim forConclusion:conc]) return nil;
    
    GLFormulaCriterion criterion = ^BOOL(GLFormula* f){
        if (f.isBiconditional) return FALSE;
        GLFormula* left = [f getDecomposition:0];
        GLFormula* right = [f getDecomposition:1];
        if ([[conc getDecomposition:0] isEqual:left] && [[conc getDecomposition:1]isEqual:right]) {
            return TRUE;
        }else if ([[conc getDecomposition:0]isEqual:right] && [[conc getDecomposition:1]isEqual:left]){
            return TRUE;
        }else return FALSE;
    };
    
    GLDedNode* biconditionalNode;
    //semi-soft
    if ((biconditionalNode=[self proveSemiSoft_withCriterion:criterion includingNegations:NO includingConclusion:NO])) {
        return [GLDedNode infer:GLInference_BiconditionalElim formula:conc withNodes:@[biconditionalNode]];
    }
    //hard
    else if ((biconditionalNode=[self proveHard_withCriterion:criterion includingNegations:NO includingConclusion:NO])){
        return [GLDedNode infer:GLInference_BiconditionalElim formula:conc withNodes:@[biconditionalNode]];
    }
    //give up
    else return nil;
}





















@end

















