//
//  GLDeduction(Inference).m
//  GLogic
//
//  Created by Thomas Gray on 16/03/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "GLDeduction(Inference).h"

//---------------------------------------------------------------------------------------------------------
//      Deduction Blocks
//---------------------------------------------------------------------------------------------------------
#pragma mark Deduction Blocks

@interface GLDeductionBlocks (Advanced)

@end

@implementation GLDeductionBlocks (Advanced)


@end

//---------------------------------------------------------------------------------------------------------
//      Inference Private Interface
//---------------------------------------------------------------------------------------------------------
#pragma mark Inference Private Interface

@interface GLDeduction (InferencePrivate)

-(BOOL)performBlockForSequence:(BOOL(^)(GLDedNode* node))block;

@end

//---------------------------------------------------------------------------------------------------------
//      Inference Implementation
//---------------------------------------------------------------------------------------------------------
#pragma mark Inference Implementation

@implementation GLDeduction (Inference)


//---------------------------------------------------------------------------------------------------------
//      Private Methods
//---------------------------------------------------------------------------------------------------------
#pragma mark Private Methods

-(BOOL)performBlockForSequence:(BOOL (^)(GLDedNode *))block{
    BOOL out = FALSE;
    for (NSInteger i=0; i<self.sequence.count; i++) {
        GLDedNode* node = self.sequence[i];
        BOOL thisBool = block(node);
        if (thisBool) out = TRUE;
    }
    return out;
}



//-(BOOL)infer_disjunctionIntroduction:(GLFormula *)disjunction{
//    if (disjunction.mainConnective && disjunction.mainConnective.isDisjunction){
//        GLFormula* dj1 = [disjunction getDecomposition:0];
//        GLFormula* dj2 = [disjunction getDecomposition:1];
//        GLDedNode* disjunct = [self nodeSatisfyingCriterion:^BOOL(GLDedNode *node) {
//            if ([node.formula isEqual:dj1] || [node.formula isEqual:dj2]) {
//                return TRUE;
//            }else return FALSE;
//        }];
//        if (disjunct) {
//            GLDedNode* out = [GLDedNode infer:GLInference_DisjunctionIntro formula:disjunction withNodes:@[disjunct]];
//            [self appendNode:out];
//            return TRUE;
//        }
//    }else @throw [NSException exceptionWithName:@"Not a disjunction" reason:nil userInfo:nil];
//    return FALSE;
//}



//---------------------------------------------------------------------------------------------------------
//      Undirected Inferences
//---------------------------------------------------------------------------------------------------------
#pragma mark Undirected Inferences
/**
 * Enumerates all nodes in the deduction and passes them to the block. The block should return an array of dedNodes that may be inferred for each node. This method ensures that any inference returned should be informative
 * @return TRUE if an inference is made, FALSE otherwise
 */
-(BOOL)infer_undirected:(GLDeductionRuleUndirected)block{
    BOOL out = FALSE;
    for (NSInteger i=0; i<self.sequence.count; i++) {
        GLDedNode* node = self.sequence[i];
        NSArray<GLDedNode*>* inferences = block(node, self);
        if (inferences && inferences.count) {
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

-(BOOL)infer_allUndirected{
    BOOL out = FALSE;
    BOOL repeat;
    do {
        repeat = FALSE;
        repeat = [self infer_undirected:[GLDeductionBlocks BcdE_Undirected]] || repeat;
        repeat = [self infer_undirected:[GLDeductionBlocks CjE_Undirected]] || repeat;
        repeat = [self infer_undirected:[GLDeductionBlocks DNE_Undirected]] || repeat;
        repeat = [self infer_undirected:[GLDeductionBlocks MP_Undirected]] || repeat;
        out = out || repeat;
    } while (repeat);
    return out;
}

//---------------------------------------------------------------------------------------------------------
//      Directed Inferences
//---------------------------------------------------------------------------------------------------------
#pragma mark Directed Inferences

-(GLDedNode*)infer_allDirected:(GLFormula *)conclusion{
    GLDedNode* out;
    
    if ((out=[self infer_directed:conclusion withBlock:[GLDeductionBlocks CjI_Directed]])){}
    else if ((out=[self infer_directed:conclusion withBlock:[GLDeductionBlocks CjI_Directed]])){}
    else if ((out=[self infer_directed:conclusion withBlock:[GLDeductionBlocks DNI_Directed]])){}
    else if ((out=[self infer_directed:conclusion withBlock:[GLDeductionBlocks BcdI_Directed]])){}
    
    return out;
}

-(GLDedNode*)infer_directed:(GLFormula *)conclusion withBlock:(GLDeductionRuleDirected)block{
    GLDedNode* concNode = [self findNodeInSequence:conclusion];
    if (!concNode) {
        concNode = block(conclusion, self);
        [self appendNode:concNode];
    }
    return concNode;
}

//---------------------------------------------------------------------------------------------------------
//      Inference Block
//---------------------------------------------------------------------------------------------------------
#pragma mark Inference Block

-(GLDedNode *)infer_conclusion:(GLFormula *)conc inferenceBlock:(GLInferenceBlock)block{
    GLDedNode* out;
    if ((out=[self findNodeInSequence:conc])) {
        return out;
    }
    GLInferenceResult* result = block(conc);
    if (!result) return nil
        ;
    NSMutableArray<GLDedNode*>* steps = [[NSMutableArray alloc]init];
    for (NSInteger i=0; i<result.steps.count; i++) {
        GLDedNode* step = [self infer_conclusion:result.steps[i]];
        if (!step) return nil;
        else [steps addObject:step];
    }
    out = [GLDedNode infer:result.rule formula:conc withNodes:steps];
    [self appendNode:out];
    return out;
}

-(GLDedNode *)infer_conclusion:(GLFormula *)conc{
    GLDedNode* out;
    if ((out = [self findNodeInSequence:conc])) {}
    else if ((out = [self infer_conclusion:conc inferenceBlock:[GLDeductionBlocks ConjunctionI]])){}
    else if ((out = [self infer_conclusion:conc inferenceBlock:[GLDeductionBlocks DNI]])){}
    return out;
}

//---------------------------------------------------------------------------------------------------------
//      Prove Hard
//---------------------------------------------------------------------------------------------------------
#pragma mark Prove Hard

-(GLDedNode*)prove_Hard:(GLFormula*)conclusion{
    
    
    return nil;
}
@end

















