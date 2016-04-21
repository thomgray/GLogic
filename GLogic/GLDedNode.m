//
//  GLDedNode.m
//  GLogic
//
//  Created by Thomas Gray on 16/03/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "GLDedNode.h"

@interface GLDedNode (Private)
@end

@implementation GLDedNode

@synthesize dependencies = _deps;
@synthesize inferenceNodes = _infs;
@synthesize inferenceRule = _rule;

-(instancetype)initWithFormula:(GLFormula *)form inference:(GLInferenceRule)inf{
    self = [super init];
    if (self) {
        _rule = inf;
        _formula = form;
    }
    return self;
}

-(void)inheritDependencies:(NSArray<GLDedNode *> *)nodes{
    NSMutableArray<GLDedNode*>* deps = [[NSMutableArray alloc]init];
    for (NSInteger i=0; i<nodes.count; i++) {
        GLDedNode* node = nodes[i];
        if (!node.dependencies) continue;
        for (NSInteger j=0; j<node.dependencies.count; j++) {
            GLDedNode* dep = node.dependencies[j];
            if (![deps containsObject:dep]){
                [deps addObject:dep];
            }
        }
    }
    [self setDependencies:[[NSArray alloc]initWithArray:deps]];
}

-(void)dischargeDependency:(GLDedNode *)node{
    NSMutableArray<GLDedNode*>* newDeps = [[NSMutableArray alloc]initWithArray:_deps];
    [newDeps removeObject:node];
    _deps = [NSArray arrayWithArray:newDeps];
}

-(NSString *)description{
    return [NSString stringWithFormat:@"%@ : %@", self.formula, GLStringForRule(self.inferenceRule)];
}

-(BOOL)isEqual:(id)object{
    if ([object isKindOfClass:[GLDedNode class]]) {
        GLDedNode* otherNode = (GLDedNode*)object;
        if (![_formula isEqual:otherNode.formula]) return FALSE;
        else if (_rule!=otherNode.inferenceRule) return FALSE;
        else if (![_deps isEqualToArray:otherNode.dependencies]) return FALSE;
        else if (![_infs isEqualToArray:otherNode.inferenceNodes]) return FALSE;
        else if (!_tier==otherNode.tier) return FALSE;
        return TRUE;
    }else return FALSE;
}

//---------------------------------------------------------------------------------------------------------
//      Inferences
//---------------------------------------------------------------------------------------------------------
#pragma mark Inferences

/**
 *  Returns a GLDedNode with the parameter formula property, inference property and inference nodes. The return node also inherits dependencies from the parameter node.
 <p/>
 If the inference rule is an assumption, reiteration or premise, the <code>nodes</code> parameter should be set to nil, and the node adds itself to its dependencies.
 <p/>
 If the inference rule is a reiteration, and the node being reiterated is itself a reiteration, the node reiterates the reiteration's reiteration rather than reiterating the reiteration. How could it be simpler
 <p/>
 Is the inference rule is a conditional proof or reductio ad absurdum, the first node (which must be an assumption) is discharged before being returned. (Consequently, the return node does not include the assumption in the return node's dependencies, though does of course keep the assumption in its inference nodes).
 *
 *  @param inf   Inference Rule
 *  @param form  The Formula for the new node
 *  @param nodes The Inference nodes to the new node
 *
 *  @return GLDedNode with the parameter inference, formula and inference nodes, inheriting the dependencies of the inference nodes.
 */
+(instancetype)infer:(GLInferenceRule)inf formula:(GLFormula *)form withNodes:(NSArray<GLDedNode *> *)nodes{
    GLDedNode * out = [[GLDedNode alloc]initWithFormula:form inference:inf];
    [out inheritDependencies:nodes];
    [out setInferenceNodes:nodes];
    switch (inf) {
        case GLInference_Premise:
        case GLInference_AssumptionCP:
        case GLInference_AssumptionDE:
        case GLInference_AssumptionRAA:
            [out setDependencies:@[out]];
            break;
        case GLInference_Reiteration:
            if (nodes[0].inferenceRule==GLInference_Reiteration) {
                [out setInferenceNodes: nodes[0].inferenceNodes ];
            }
            break;
        case GLInference_ConditionalProof:
        case GLInference_ConditionalProofDE:
        case GLInference_ReductioAA:
            [out dischargeDependency:nodes.firstObject];
            break;
        case GLInference_DisjunctionElim:
            [out dischargeDependency:nodes[1]];
            [out dischargeDependency:nodes[3]];
            break;
        default:
            break;
    }
    return out;
}

// !!!: NEEDS IMPLEMENTING
/**
 *  Returns a NSNumber array representing the integer values of each defined GLInferenceRule. This can be used to iterate over all inferenceRules. To do so, cast each NSInteger value of each NSNumber to GLInferenceRule.
 *  @return A NSNumber array representing all defined GLInferenceRule enums
 */
+(NSArray<NSNumber *> *)allInferenceRules{
    return nil;
}

@end
