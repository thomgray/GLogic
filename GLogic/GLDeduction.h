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
@class GLDeductionLogDelegate;

@interface GLDeduction : NSObject{
    GLDeductionCheckList* _checkList;
}

@property NSMutableArray<GLDedNode*>* sequence;
@property GLFormula* conclusion;
@property NSArray<GLFormula*>* premises;
@property NSInteger tier;

@property GLDeductionLogDelegate* logDelegate;

-(instancetype)initWithPremises:(NSArray<GLFormula*>*)prems;
-(instancetype)initWithPremises:(NSArray<GLFormula *> *)prems conclusion:(GLFormula*)conc;

-(void)addPremises:(NSArray<GLFormula*> *)premises;

#pragma mark Querying

-(BOOL)containsFormula:(GLFormula*)f;

#pragma mark Getting

-(GLDedNode*)findNodeInSequence:(GLFormula*)form;
-(NSArray<GLDedNode*>*)getNodesWithCriterion:(GLDedNodeCriterion)criterion;

-(NSArray<GLDedNode*>*)getLinearSequence;

@end

@protocol GLDeductionLogDelegate <NSObject>

-(void)log:(NSString*)string;
-(void)openSubproof:(GLFormula*)conclusion description:(NSString*)description;
-(void)openTempProof:(GLFormula*)conclusion description:(NSString*)description;
-(void)closeSubproof;
-(void)closeTempProof;

@end


