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

-(instancetype)initWithFormula:(GLFormula *)form inference:(GLInferenceRule)inf{
    self = [super init];
    if (self) {
        [self setInferenceRule:inf];
        [self setFormula:form];
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
        default:
            break;
    }
    return out;
}

@end
