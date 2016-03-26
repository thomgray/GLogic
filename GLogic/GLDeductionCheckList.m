//
//  GLDeductionCheckList.m
//  GLogic
//
//  Created by Thomas Gray on 20/03/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "GLDeductionCheckList.h"

@interface GLCheckListItem : NSObject
@property GLFormula* conclusion;
@property GLInferenceRule inferenceRule;
@end

@implementation GLCheckListItem



@end

//---------------------------------------------------------------------------------------------------------
//      Check List
//---------------------------------------------------------------------------------------------------------

@implementation GLDeductionCheckList
-(instancetype)init{
    self = [super init];
    if (self) {
        items = [[NSMutableArray alloc]init];
        tempRestrictions = [[NSMutableSet alloc]init];
    }
    return self;
}


/**
 *  Checks as follows:<br/>
        -# If the conclusion is temporarily restricted, returns FALSE
        -# If the conclusion is restricted for the specified inference rule, returns FALSE
        -# Otherwise, the formula is added to the rule restrictions (so will return false if checked again), then returns TRUE
 *
 *  @param rule The inference rule attempted
 *  @param form The conclusion attempted
 *
 *  @return TRUE if no retrictions have been made on the conclusion with the specified inference rule. FALSE if the conclusion is retricted in any way. If true is returned, the formula is added to the restriction check list for the specified inference rule.
 */
-(BOOL)mayAttempt:(GLInferenceRule)rule conclusion:(GLFormula *)conc{
    if ([tempRestrictions containsObject:conc]) {
        return false;
    }
    for (NSInteger i=0; i<items.count; i++) {
        GLCheckListItem* item = items[i];
        if ([item.conclusion isEqual:conc] && item.inferenceRule==rule) {
            return FALSE;
        }
    }
    GLCheckListItem* newItem = [[GLCheckListItem alloc]init];
    newItem.conclusion = conc;
    newItem.inferenceRule = rule;
    [items addObject:newItem];
    return TRUE;
}

-(void)addRestriction:(GLFormula *)formula{
    [tempRestrictions addObject:formula];
}
-(void)liftRestriction:(GLFormula *)formula{
    [tempRestrictions removeObject:formula];
}

-(void)resetList{
    [items removeAllObjects];
}

@end
