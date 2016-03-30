//
//  GLDeductionCheckList.h
//  GLogic
//
//  Created by Thomas Gray on 20/03/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "GLDedNode.h"

@class GLCheckListItem;

@interface GLDeductionCheckList : NSObject <NSCopying>

@property NSMutableSet<GLCheckListItem*>* items;
@property NSMutableSet<GLFormula*>* tempRestrictions;
@property NSMutableSet<GLFormula*>* DERestrictions;

-(void)resetList;
-(BOOL)addRestriction:(GLFormula*)formula;
-(BOOL)liftRestriction:(GLFormula*)formula;
-(BOOL)addRestriction:(GLFormula *)formula forRule:(GLInferenceRule)rule;
-(BOOL)liftRestriction:(GLFormula *)formula forRule:(GLInferenceRule)rule;
-(BOOL)mayAttempt:(GLInferenceRule)rule conclusion:(GLFormula*)form;

-(BOOL)addDERestriction:(GLFormula*)disjunction;
-(BOOL)liftDERestriction:(GLFormula*)disjunctin;
-(BOOL)disjunctionIsRestrictedForDE:(GLFormula*)disjunction;

@end
