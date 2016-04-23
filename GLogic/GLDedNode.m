//
//  GLDedNode.m
//  GLogic
//
//  Created by Thomas Gray on 16/03/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "GLDedNode.h"
#import "NSWeakArray.h"

@interface GLDedNode (Private)
@end

@implementation GLDedNode

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
    if (nodes){
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
        [self setDependencies:deps];
    }
}

-(void)dischargeDependency:(GLDedNode *)node{
    NSMutableArray<GLDedNode*>* newDeps = [[NSMutableArray alloc]initWithArray:[self dependencies]];
    [newDeps removeObject:node];
    [self setDependencies:newDeps];
}

-(NSString *)description{
    return [NSString stringWithFormat:@"%@ : %@", self.formula, GLStringForRule(self.inferenceRule)];
}

-(BOOL)isEqual:(id)object{
    if ([object isKindOfClass:[GLDedNode class]]) {
        GLDedNode* otherNode = (GLDedNode*)object;
        if (![_formula isEqual:otherNode.formula]) return FALSE;
        else if (_rule!=otherNode.inferenceRule) return FALSE;
        else if (![self.dependencies isEqualToArray:otherNode.dependencies]) return FALSE;
        else if (![self.inferenceNodes isEqualToArray:otherNode.inferenceNodes]) return FALSE;
        else if (!_tier==otherNode.tier) return FALSE;
        return TRUE;
    }else return FALSE;
}

//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//
#pragma mark Weak Reference Collection Querying
//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//

-(void)setInferenceNodes:(NSArray<GLDedNode *> *)inferenceNodes{
    _weakInferences = inferenceNodes? [NSWeakArray arrayWithArray:inferenceNodes] : nil;
}

-(NSArray<GLDedNode *> *)inferenceNodes{
    return _weakInferences? _weakInferences.toArray:nil;
}

-(void)setDependencies:(NSArray<GLDedNode *> *)dependencies{
    _weakDependencies = [NSWeakArray arrayWithArray:dependencies];
}

-(NSArray<GLDedNode *> *)dependencies{
    return _weakDependencies.toArray;
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
    GLDedNode * owt = [[self alloc]initWithFormula:form inference:inf];
    [owt setFormula:form];
    [owt infer:inf nodes:nodes];
    return owt;
}

-(void)infer:(GLInferenceRule)rule nodes:(NSArray<GLDedNode *> *)nodes{
    [self setInferenceRule:rule];
    [self inheritDependencies:nodes];
    [self setInferenceNodes:nodes];
    switch (rule) {
        case GLInference_Premise:
        case GLInference_AssumptionCP:
        case GLInference_AssumptionDE:
        case GLInference_AssumptionRAA:
            [self setDependencies:@[self]];
            break;
        case GLInference_Reiteration:
            if (nodes[0].inferenceRule==GLInference_Reiteration) {
                [self setInferenceNodes: nodes[0].inferenceNodes ];
            }
            break;
        case GLInference_ConditionalProof:
        case GLInference_ConditionalProofDE:
        case GLInference_ReductioAA:
            [self dischargeDependency:nodes.firstObject];
            break;
        case GLInference_DisjunctionElim:
            [self dischargeDependency:nodes[1]];
            [self dischargeDependency:nodes[3]];
            break;
        default:
            break;
    }
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
