//
//  GLDeduction.h
//  GLogic
//
//  Created by Thomas Gray on 16/03/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "GLFormula(Operations).h"
#import "GLDedNode.h"
//#import "DeductionLogDelegate.h"

@class GLDeductionCheckList;
@class GLDeduction;


//---------------------------------------------------------------------------------------------------------
//      Log Delegate
//---------------------------------------------------------------------------------------------------------
#pragma mark Log Delegate

@protocol DeductionLogDelegate <NSObject>

-(void)logInfo:(NSDictionary<NSString*, id>*)info deduction:(GLDeduction*)deduction;

@end

#pragma mark 
//---------------------------------------------------------------------------------------------------------
//      Deduction
//---------------------------------------------------------------------------------------------------------
#pragma mark Deduction

@interface GLDeduction : NSObject <NSCopying>{
    GLDeductionCheckList* _checkList;
    NSInteger _currentTier;
}

@property NSMutableArray<GLDedNode*>* sequence;
@property GLFormula* conclusion;
@property NSArray<GLFormula*>* premises;


@property (weak) id <DeductionLogDelegate> logger;

-(instancetype)initWithPremises:(NSArray<GLFormula*>*)prems;
-(instancetype)initWithPremises:(NSArray<GLFormula *> *)prems conclusion:(GLFormula*)conc;

-(void)addPremises:(NSArray<GLFormula*> *)premises;

#pragma mark Querying

-(BOOL)containsFormula:(GLFormula*)f;

#pragma mark Getting

//-(NSArray<GLDedNode*>*)getNodesWithCriterion:(GLDedNodeCriterion)criterion;

@end




