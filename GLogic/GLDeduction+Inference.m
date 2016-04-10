//
//  GLDeduction+Inference.m
//  GLogic
//
//  Created by Thomas Gray on 06/04/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "GLDeduction+Inference.h"

@implementation GLDeduction (Inference)

/**
 *  Assumes the parameter formula given the parameter inference rule, which must be one of the following:
 <ul>
 <li>@c GLInferenceRule_AssumptionCP</li>
 <li>@c GLInferenceRule_AssumptionDE</li>
 <li>@c GLInferenceRule_AssumptionRAA</li>
 </ul>
 Calling this method triggers a @c stepUp call, incrementing the @c _currentTier by 1.<p/> The node is then added to the deductiom before being returned
 *
 *  @param assumption The formula being assumed
 *  @param rule       The assumption rule: either CP, DE or RAA
 *
 *  @return The assumption node
 */
-(GLDedNode *)assume:(GLFormula *)assumption rule:(GLInferenceRule)rule{
    if (rule!=GLInference_AssumptionCP &&
        rule!=GLInference_AssumptionDE &&
        rule!=GLInference_AssumptionRAA)
            @throw [NSException exceptionWithName:@"Must assume by an assumption rule"
                                           reason:nil userInfo:nil];
    
    GLDedNode* assumptionNode = [GLDedNode infer:rule formula:assumption withNodes:nil];
    [self stepUp];
    [self appendNode:assumptionNode];
    return assumptionNode;
}

//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//
#pragma mark Constructive Inferences
//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//
/**
 *  Infers the conclusion so long the conclusion is a conjunction and both conjuncts are available
 *
 *  @param conclusion The desired conclusion
 *
 *  @return the appended conclusion node or nil if not inferred
 */
-(GLDedNode *)infer_CI:(GLFormula *)conclusion{
    if (!conclusion.isConjunction) return nil;
        
    GLDedNode* cj1Node = [self findAvailableNode:conclusion.firstDecomposition];
    GLDedNode* cj2Node = [self findAvailableNode:conclusion.secondDecomposition];
    
    if (cj1Node && cj2Node) {
        GLDedNode* concNode = [GLDedNode infer:GLInference_ConjunctionIntro formula:conclusion withNodes:@[cj1Node, cj2Node]];
        [self appendNode:concNode];
        return concNode;
    }else return nil;
}

-(GLDedNode *)infer_BI:(GLFormula *)conclusion{
    if (!conclusion.isBiconditional) return nil;
    GLFormula* left = conclusion.firstDecomposition;
    GLFormula* right = conclusion.secondDecomposition;
    
    GLFormula* cond1 = [conclusion.class makeConditional:left f2:right];
    GLFormula* cond2 = [conclusion.class makeConditional:right f2:left];
    
    GLDedNode* cond1Node = [self findAvailableNode:cond1];
    GLDedNode* cond2Node = [self findAvailableNode:cond2];
    
    if (cond1Node && cond2Node) {
        GLDedNode* concNode = [GLDedNode infer:GLInference_BiconditionalIntro formula:conclusion withNodes:@[cond1Node, cond2Node]];
        [self appendNode:concNode];
        return concNode;
    }else return nil;
}

-(GLDedNode *)infer_DI:(GLFormula *)conclusion{
    if (!conclusion.isDisjunction) return nil;
    
    GLDedNode* dj = [self findAvailableNode:conclusion.firstDecomposition];
    if (!dj) dj = [self findAvailableNode:conclusion.secondDecomposition];
    
    if (dj) {
        GLDedNode* concNode = [GLDedNode infer:GLInference_DisjunctionIntro formula:conclusion withNodes:@[dj]];
        [self appendNode:concNode];
        return concNode;
    }else return nil;
}

-(GLDedNode *)infer_DNI:(GLFormula *)conclusion{
    if (!conclusion.isDoubleNegation) return nil;
    GLFormula* dne = [conclusion getDecompositionAtNode:@[@0,@0]];
    
    GLDedNode* dneNode = [self findAvailableNode:dne];
    if (dneNode) {
        GLDedNode* concNode = [GLDedNode infer:GLInference_DNI formula:conclusion withNodes:@[dneNode]];
        [self appendNode:concNode];
        return concNode;
    }else return nil;
}


@end