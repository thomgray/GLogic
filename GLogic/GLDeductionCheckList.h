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
/*!
 Set of CheckListItems mapping formulas to restricted rules
 */
@property NSMutableSet<GLCheckListItem*>* restrictions;
/*!
 Set of Formulas restricted for any rule
 */
@property NSMutableSet<GLFormula*>* categoricalRestrictions;

@property NSMutableSet<GLFormula*>* tempRestrictions;
/*!
 Set of Disjunctions restricted for DE
 */
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
