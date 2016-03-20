//
//  GLDeductionSequence.m
//  GLogic
//
//  Created by Thomas Gray on 16/03/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "GLDeductionSequence.h"

@interface GLDeductionSequence (Private)

-(NSString*)stringForInferenceRule:(GLInferenceRule)inf;

@end

@implementation GLDeductionSequence
@synthesize sequence = _sequence;

-(instancetype)init{
    self = [super init];
    if (self) {
        _sequence = [[NSMutableArray alloc]init];
    }
    return self;
}


#pragma mark Getting / Setting

-(void)appendNode:(GLDedNode *)node{
    [_sequence addObject:node];
}

-(void)addPremises:(NSArray<GLFormula *> *)premises{
    for (NSInteger i=0; i<premises.count; i++) {
        GLDedNode* prem = [GLDedNode infer:GLInference_Premise formula:premises[i] withNodes:NULL];
        [self appendNode:prem];
    }
}

-(void)addReiteration:(NSArray<GLDedNode *> *)reiteration{
    for (NSInteger i=0; i<reiteration.count; i++) {
        GLDedNode* node = reiteration[i];
        GLDedNode* reiteration = [GLDedNode infer:GLInference_Reiteration formula:node.formula withNodes:@[node]];
        [self appendNode:reiteration];
    }
}

-(GLDedNode *)findNodeInSequence:(GLFormula *)form{
    for (NSInteger i=0; i<_sequence.count; i++) {
        GLDedNode* node = _sequence[i];
        if ([node.formula isEqual:form]) {
            return node;
        }
    }
    return NULL;
}

-(BOOL)containsFormula:(GLFormula *)f{
    for (NSInteger i=0; i<_sequence.count; i++) {
        GLDedNode* node = _sequence[i];
        if ([node.formula isEqual:f]) {
            return TRUE;
        }
    }
    return FALSE;
}

-(BOOL)isInformedBy:(GLFormula *)f{
    return ![self containsFormula:f];
}

#pragma mark Advanced Getting

-(GLDedNode *)nodeSatisfyingCriterion:(GLDedNodeCriterion)criterion{
    for (NSInteger i=0; i<_sequence.count; i++) {
        if (criterion(_sequence[i])) {
            return _sequence[i];
        }
    }
    return NULL;
}

-(NSArray<GLDedNode *> *)nodesSaisfyingCriterion:(GLDedNodeCriterion)criterion{
    NSMutableArray<GLDedNode*>* out = [[NSMutableArray alloc]init];
    for (NSInteger i=0; i<_sequence.count; i++) {
        GLDedNode* node = _sequence[i];
        if (criterion(node)) {
            [out addObject:node];
        }
    }
    return out.count>0 ? [NSArray arrayWithArray:out]:NULL;
}

-(NSArray<GLDedNode *> *)nodesWithConnective:(GLConnectiveType)type{
    return [self nodesSaisfyingCriterion:^BOOL(GLDedNode * node) {
        GLCompositor* comp = [node.formula mainConnective];
        if (comp && comp.isConnective) {
            return ((GLConnective*)comp).type == type;
        }else return FALSE;
    }];
}
-(NSArray<GLDedNode *> *)nodesWithQuantifier:(GLQuantifierType)type{
    return [self nodesSaisfyingCriterion:^BOOL(GLDedNode * node) {
        GLCompositor* comp = [node.formula mainConnective];
        if (comp && comp.isQuantifier) {
            return ((GLQuantifier*)comp).type == type;
        }else return FALSE;
    }];
}

#pragma mark To String

-(NSString *)description{
    NSMutableString* out = [[NSMutableString alloc]init];
    [out appendFormat:@"%@:\n", [super description]];
    for (NSInteger i=0; i<_sequence.count; i++) {
        GLDedNode* node = _sequence[i];
        NSInteger lineNumber = i+1;
        NSString* inferenceString = @"";
        NSString* dependencyNumbers = @"{";
        for (NSInteger j=0; j<node.inferenceNodes.count; j++) {
            GLDedNode* inf = node.inferenceNodes[j];
            inferenceString = [inferenceString stringByAppendingFormat:@"%ld", [_sequence indexOfObject:inf]+1];
            if (j==node.inferenceNodes.count-1) {
                inferenceString = [inferenceString stringByAppendingString:@": "];
            }
            else inferenceString = [inferenceString stringByAppendingString:@","];
        }
        inferenceString = [inferenceString stringByAppendingFormat:@"%@", [self stringForInferenceRule:node.inferenceRule]];
        for (NSInteger j=0; j<node.dependencies.count; j++) {
            GLDedNode* dep = node.dependencies[j];
            dependencyNumbers = [dependencyNumbers stringByAppendingFormat:@"%ld", [_sequence indexOfObject:dep]+1];
            if (j<node.dependencies.count-1) dependencyNumbers = [dependencyNumbers stringByAppendingString:@","];
        }
        dependencyNumbers = [dependencyNumbers stringByAppendingString:@"}"];
        dependencyNumbers = [dependencyNumbers stringByPaddingToLength:10 withString:@" " startingAtIndex:0];
        NSString* formString = [node.formula.description stringByPaddingToLength:60 withString:@" " startingAtIndex:0];
        NSString* lineString = [NSString stringWithFormat:@"%ld", lineNumber];
        lineString = [lineString stringByPaddingToLength:5 withString:@" " startingAtIndex:0 ];
        [out appendFormat:@"%@%@%@%@\n", lineString, dependencyNumbers, formString, inferenceString];
    }
    return out;
}

#pragma mark Private

-(NSString *)stringForInferenceRule:(GLInferenceRule)inf{
    switch (inf) {
        case GLInference_AssumptionCP:
            return @"Assumption (CP)";
        case GLInference_AssumptionDE:
            return @"Assumption (∨E)";
        case GLInference_AssumptionRAA:
            return @"Assumption (RAA)";
        case GLInference_BiconditionalElim:
            return @"⟷ Elimination";
        case GLInference_BiconditionalIntro:
            return @"⟷ Introduction";
        case GLInference_ConditionalProof:
            return @"Condiional Proof";
        case GLInference_ConditionalProofDE:
            return @"Conditional Proof (∨E)";
        case GLInference_ConjunctionElim:
            return @"∧ Elimination";
        case GLInference_ConjunctionIntro:
            return @"∧ Introduction";
        case GLInference_DisjunctionElim:
            return @"∨ Elimination";
        case GLInference_DisjunctionIntro:
            return @"∨ Introduction";
        case GLInference_DNE:
            return @"¬¬ Elimination";
        case GLInference_DNI:
            return @"¬¬ Introduction";
        case GLInference_ModusPonens:
            return @"Modus Ponens";
        case GLInference_ModusTollens:
            return @"Modus Tollens";
        case GLInference_Premise:
            return @"Premise";
        case GLInference_ReductioAA:
            return @"Reductio Ad Absurdum";
        case GLInference_Reiteration:
            return @"Reiteration";
        default:
            break;
    }
}

@end
