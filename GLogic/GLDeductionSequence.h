//
//  GLDeductionSequence.h
//  GLogic
//
//  Created by Thomas Gray on 16/03/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLDedNode.h"

@interface GLDeductionSequence : NSObject

@property NSMutableArray<GLDedNode*>* sequence;

-(void)appendNode:(GLDedNode*)node;
-(void)addPremises:(NSArray<GLFormula*>*)premises;
-(void)addReiteration:(NSArray<GLDedNode*>*)reiteration;



-(GLDedNode*)findNodeInSequence:(GLFormula*)form;
-(BOOL)containsFormula:(GLFormula*)f;
-(BOOL)isInformedBy:(GLFormula*)f;


#pragma mark Advanced Getting

-(NSArray<GLDedNode*>*)nodesSaisfyingCriterion:(GLDedNodeCriterion)criterion;
-(GLDedNode*)nodeSatisfyingCriterion:(GLDedNodeCriterion)criterion;
-(NSArray<GLDedNode*>*)nodesWithConnective:(GLConnectiveType)type;
-(NSArray<GLDedNode*>*)nodesWithQuantifier:(GLQuantifierType)type;


@end
