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
@property NSInteger index;
@end

//@implementation GLCheckListItem
//
//
//
//@end

//---------------------------------------------------------------------------------------------------------
//      Check List
//---------------------------------------------------------------------------------------------------------

@implementation GLDeductionCheckList
-(instancetype)init{
    self = [super init];
    if (self) {
        items = [[NSMutableArray alloc]init];
    }
    return self;
}

/**
 * Checks to see whether the specified formula has been considered with the specified rule. If not, the method returns false and adds the specified inference to the checklist (so will return true if queried again)
 * @param rule: The inference rule
 * @param conc: The conclusion
 * @return BOOL: TRUE if the inference has been previously checked, FALSE otherwise
 */
-(BOOL)checkInference:(GLInferenceRule)rule conclusion:(GLFormula *)conc index:(NSInteger)idx{
    for (NSInteger i=0; i<items.count; i++) {
        GLCheckListItem* item = items[i];
        if ([item.conclusion isEqual:conc] && item.inferenceRule==rule && item.index==idx) {
            return TRUE;
        }
    }
    GLCheckListItem* newItem = [[GLCheckListItem alloc]init];
    newItem.conclusion = conc;
    newItem.inferenceRule = rule;
    newItem.index = idx;
    [items addObject:newItem];
    return FALSE;
}

-(void)resetList{
    [items removeAllObjects];
}

@end
