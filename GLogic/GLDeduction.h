//
//  GLDeduction.h
//  GLogic
//
//  Created by Thomas Gray on 16/03/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLFormula(Operations).h"
#import "GLDedNode.h"

@class GLDeductionCheckList;

@interface GLDeduction : NSObject{
    GLDeductionCheckList* _checkList;
}

@property NSMutableArray<GLDedNode*>* sequence;
@property GLFormula* conclusion;
@property (setter=addPremises:) NSArray<GLFormula*>* premises;

-(instancetype)initWithPremises:(NSArray<GLFormula*>*)prems;
-(instancetype)initWithPremises:(NSArray<GLFormula *> *)prems conclusion:(GLFormula*)conc;

#pragma mark Querying

-(BOOL)containsFormula:(GLFormula*)f;

#pragma mark Getting

-(GLDedNode*)findNodeInSequence:(GLFormula*)form;
-(NSArray<GLDedNode*>*)getNodesWithCriterion:(GLDedNodeCriterion)criterion;


@end
