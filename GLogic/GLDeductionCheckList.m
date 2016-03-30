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

-(NSString *)description{
    return [NSString stringWithFormat:@"%@ : %@", self.conclusion.description, GLStringForRule(self.inferenceRule)];
}

-(BOOL)isEqual:(id)object{
    if ([object isKindOfClass:[GLCheckListItem class]]) {
        GLCheckListItem* listItem = (GLCheckListItem*)object;
        return self.inferenceRule==listItem.inferenceRule && [self.conclusion isEqual:listItem.conclusion];
    }else return FALSE;
}

-(NSUInteger)hash{
    return [self.conclusion hash] ^ (NSUInteger)self.inferenceRule;
}

@end

//---------------------------------------------------------------------------------------------------------
//      Check List
//---------------------------------------------------------------------------------------------------------

@interface GLDeductionCheckList (Private)

-(void)copyItems:(NSMutableSet<GLCheckListItem*>*) items;
-(void)copyTempRestrictions:(NSMutableSet<GLFormula*>*) restricts;
-(void)copyDERestrictions:(NSMutableSet<GLFormula *> *)restricts;

@end


@implementation GLDeductionCheckList
@synthesize items;
@synthesize tempRestrictions;
@synthesize DERestrictions;

-(instancetype)init{
    self = [super init];
    if (self) {
        items = [[NSMutableSet alloc]init];
        tempRestrictions = [[NSMutableSet alloc]init];
        DERestrictions = [[NSMutableSet alloc]init];
    }
    return self;
}


/*!
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
        return FALSE;
    }
    GLCheckListItem* checkItem = [[GLCheckListItem alloc]init];
    checkItem.conclusion = conc;
    checkItem.inferenceRule = rule;
    if ([items containsObject:checkItem]) {
        return FALSE;
    }else{
        [items addObject:checkItem];
        return TRUE;
    }
}

/*!
 Returns TRUE if the item is succesfully added, i.e. was not already restricted
 */
-(BOOL)addRestriction:(GLFormula *)formula{
    if (![tempRestrictions containsObject:formula]) {
        [tempRestrictions addObject:formula];
        return TRUE;
    }else return FALSE;
}

/*!
 Returns TRUE if the item is succesfully removed, i.e. was restricted in the first place
 */
-(BOOL)liftRestriction:(GLFormula *)formula{
    if ([tempRestrictions containsObject:formula]) {
        [tempRestrictions removeObject:formula];
        return TRUE;
    }else return FALSE;
}

/*!
 Returns TRUE if the item is succesfully added, i.e. was not already restricted
 */
-(BOOL)addRestriction:(GLFormula *)formula forRule:(GLInferenceRule)rule{
    GLCheckListItem* newItem = [[GLCheckListItem alloc]init];
    newItem.conclusion = formula;
    newItem.inferenceRule = rule;
    if (![items containsObject:newItem]) {
        [items addObject:newItem];
        return TRUE;
    }else return FALSE;
}

/*!
 Returns TRUE if the item is succesfully removed, i.e. was restricted in the first place
 */
-(BOOL)liftRestriction:(GLFormula *)formula forRule:(GLInferenceRule)rule{
    GLCheckListItem* newItem = [[GLCheckListItem alloc]init];
    newItem.conclusion = formula;
    newItem.inferenceRule = rule;
    
    if ([items containsObject:newItem]) {
        [items removeObject:newItem];
        return TRUE;
    }else return FALSE;

}

-(BOOL)addDERestriction:(GLFormula *)disjunction{
    if (![DERestrictions containsObject:disjunction]) {
        [DERestrictions addObject:disjunction];
        return TRUE;
    }else return FALSE;
}

-(BOOL)liftDERestriction:(GLFormula *)disjunction{
    if ([DERestrictions containsObject:disjunction]) {
        [DERestrictions removeObject:disjunction];
        return TRUE;
    }else return FALSE;
}

-(BOOL)disjunctionIsRestrictedForDE:(GLFormula *)disjunction{
    return [DERestrictions containsObject:disjunction];
}

-(void)resetList{
    [items removeAllObjects];
}

//---------------------------------------------------------------------------------------------------------
//      Private
//---------------------------------------------------------------------------------------------------------
#pragma mark Private

-(void)copyItems:(NSMutableSet<GLCheckListItem *> *)its{
    items = [NSMutableSet setWithSet:its];
}
-(void)copyDERestrictions:(NSMutableSet<GLFormula *> *)restricts{
    DERestrictions = [NSMutableSet setWithSet:restricts];
}
-(void)copyTempRestrictions:(NSMutableSet<GLFormula *> *)restricts{
    tempRestrictions = [NSMutableSet setWithSet:restricts];
}

-(id)copyWithZone:(NSZone *)zone{
    GLDeductionCheckList* out = [[self.class alloc]init];
    [out copyTempRestrictions:tempRestrictions];
    [out copyItems:items];
    [out copyDERestrictions:DERestrictions];
    return out;
}

@end
