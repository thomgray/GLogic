//
//  GLDeductionCheckList.m
//  GLogic
//
//  Created by Thomas Gray on 20/03/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "GLDeductionCheckList.h"

@interface GLCheckListItem : NSObject <NSCopying>
@property GLFormula* conclusion;
@property GLInferenceRule inferenceRule;
@property NSMutableSet<NSNumber*>* rules;

-(instancetype)initWithFormula:(GLFormula*)form;

-(BOOL)addRule:(GLInferenceRule)rule;
-(BOOL)removeRule:(GLInferenceRule)rule;
-(BOOL)containtsRule:(GLInferenceRule)rule;

@end

@implementation GLCheckListItem

-(instancetype)init{
    self = [super init];
    if (self) {
        _rules = [[NSMutableSet alloc]init];
    }
    return self;
}

-(instancetype)initWithFormula:(GLFormula *)form{
    self = [super init];
    if (self) {
        _rules = [[NSMutableSet alloc]init];
        _conclusion = form;
    }
    return self;
}

-(BOOL)addRule:(GLInferenceRule)rule{
    NSNumber* i = [NSNumber numberWithInteger:rule];
    if (![_rules containsObject:i]) {
        [_rules addObject:i];
        return TRUE;
    }else return FALSE;
}
-(BOOL)removeRule:(GLInferenceRule)rule{
    NSNumber* i = [NSNumber numberWithInteger:rule];
    if ([_rules containsObject:i]) {
        [_rules removeObject:i];
        return TRUE;
    }else return  FALSE;
}
-(BOOL)containtsRule:(GLInferenceRule)rule{
    NSNumber* i = [NSNumber numberWithInteger:rule];
    return [_rules containsObject:i];
}

-(NSString *)description{
    NSMutableString* inferenceString = [[NSMutableString alloc]init];
    NSArray<NSNumber*>* infArray = _rules.allObjects;
    for (NSInteger i=0; i<infArray.count; i++) {
        GLInferenceRule rule = (GLInferenceRule)infArray[i].integerValue;
        [inferenceString appendFormat:@"%@, ", GLStringForRule(rule)];
    }
    return [NSString stringWithFormat:@"%@ : %@", self.conclusion, inferenceString];
}

-(BOOL)isEqual:(id)object{
    if ([object isKindOfClass:[GLCheckListItem class]]) {
        GLCheckListItem* listItem = (GLCheckListItem*)object;
        return self.inferenceRule==listItem.inferenceRule && [self.conclusion isEqual:listItem.conclusion] && [_rules isEqualToSet:listItem.rules];
    }else return FALSE;
}

-(NSUInteger)hash{
    return [self.conclusion hash] ^ (NSUInteger)self.inferenceRule ^ [_rules hash];
}

-(id)copyWithZone:(NSZone *)zone{
    GLCheckListItem* out = [[self.class alloc]initWithFormula:_conclusion];
    [out setRules:[self.rules copyWithZone:zone]];
    return out;
}

@end

//---------------------------------------------------------------------------------------------------------
//      Check List
//---------------------------------------------------------------------------------------------------------

@interface GLDeductionCheckList (Private)

-(void)copyItems:(NSMutableSet<GLCheckListItem*>*) items;
-(void)copyTempRestrictions:(NSMutableSet<GLFormula*>*) restricts;
-(void)copyDERestrictions:(NSMutableSet<GLFormula *> *)restricts;

-(GLCheckListItem*)itemForFormula:(GLFormula*)formula;

@end


@implementation GLDeductionCheckList

@synthesize items;
@synthesize tempRestrictions;
@synthesize restrictions = _restrictions;
@synthesize categoricalRestrictions = _categoricalRestrictions;

-(instancetype)init{
    self = [super init];
    if (self) {
        items = [[NSMutableSet alloc]init];
        tempRestrictions = [[NSMutableSet alloc]init];
        
        _DERestrictions = [[NSMutableSet alloc]init];
        _restrictions = [[NSMutableSet alloc]init];
        _categoricalRestrictions = [[NSMutableSet alloc]init];
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
    if ([_categoricalRestrictions containsObject:conc]) {
        return FALSE;
    }
    NSArray* restrictArray = _restrictions.allObjects;
    for (NSInteger i=0; i<restrictArray.count; i++) {
        GLCheckListItem* item = restrictArray[i];
        if ([item.conclusion isEqual:conc] && [item containtsRule:rule]) {
            return FALSE;
        }
    }
    

    GLCheckListItem* checkItem = [self itemForFormula:conc];
    if ([checkItem containtsRule:rule]) {
        return FALSE;
    }else{
        [checkItem addRule:rule];
        return TRUE;
    }
}

/*!
 Returns TRUE if the item is succesfully added, i.e. was not already restricted
 */
-(BOOL)addRestriction:(GLFormula *)formula{
    if (![_categoricalRestrictions containsObject:formula]) {
        [_categoricalRestrictions addObject:formula];
        return TRUE;
    }else return FALSE;
}

/*!
 Returns TRUE if the item is succesfully removed, i.e. was restricted in the first place
 */
-(BOOL)liftRestriction:(GLFormula *)formula{
    if ([_categoricalRestrictions containsObject:formula]) {
        [_categoricalRestrictions removeObject:formula];
        return TRUE;
    }else return FALSE;
}

/*!
 Returns TRUE if the item is succesfully added, i.e. was not already restricted
 */
-(BOOL)addRestriction:(GLFormula *)formula forRule:(GLInferenceRule)rule{
    GLCheckListItem* item = [self itemForFormula:formula];
    return [item addRule:rule];
}

/*!
 Returns TRUE if the item is succesfully removed, i.e. was restricted in the first place
 */
-(BOOL)liftRestriction:(GLFormula *)formula forRule:(GLInferenceRule)rule{
    GLCheckListItem* item = [self itemForFormula:formula];
    return [item removeRule:rule];
}

-(BOOL)addDERestriction:(GLFormula *)disjunction{
    if (![_DERestrictions containsObject:disjunction]) {
        [_DERestrictions addObject:disjunction];
        return TRUE;
    }else return FALSE;
}

-(BOOL)liftDERestriction:(GLFormula *)disjunction{
    if ([_DERestrictions containsObject:disjunction]) {
        [_DERestrictions removeObject:disjunction];
        return TRUE;
    }else return FALSE;
}

-(BOOL)disjunctionIsRestrictedForDE:(GLFormula *)disjunction{
    return [_DERestrictions containsObject:disjunction];
}

-(void)resetList{
    [items removeAllObjects];
}

-(id)copyWithZone:(NSZone *)zone{
    GLDeductionCheckList* out = [[self.class alloc]init];
    
    [out setCategoricalRestrictions:[[NSMutableSet alloc]initWithSet:_categoricalRestrictions copyItems:NO]];
    [out setRestrictions:[[NSMutableSet alloc]initWithSet:_restrictions copyItems:YES]];
    [out setDERestrictions:[[NSMutableSet alloc]initWithSet:_DERestrictions copyItems:NO]];
        
    [out copyTempRestrictions:tempRestrictions];
    [out copyItems:items];
    return out;
}

-(NSString *)description{
    return [NSString stringWithFormat:@"Deduction Check List\n\
            Categorical Restrictions: %@ \n\
            Cascading Restrictions: %@\n\
            Dynamic Restrictions: %@\n\
            DE Restrictions: %@", _categoricalRestrictions, _restrictions, self.items, _DERestrictions];    
}

//---------------------------------------------------------------------------------------------------------
//      Private
//---------------------------------------------------------------------------------------------------------
#pragma mark Private

-(void)copyItems:(NSMutableSet<GLCheckListItem *> *)its{
    items = [NSMutableSet setWithSet:its];
}
-(void)copyDERestrictions:(NSMutableSet<GLFormula *> *)restricts{
    _DERestrictions = [NSMutableSet setWithSet:restricts];
}
-(void)copyTempRestrictions:(NSMutableSet<GLFormula *> *)restricts{
    tempRestrictions = [NSMutableSet setWithSet:restricts];
}

/*!
 Returns the CheckListItem for the specified formula, or if one doesn't exist, returns a new item for the specified formula and adds it to the restrictions set.
 */
-(GLCheckListItem *)itemForFormula:(GLFormula *)formula{
    NSArray<GLCheckListItem*>* its = _restrictions.allObjects;
    for (NSInteger i=0; i<its.count; i++) {
        if ([its[i].conclusion isEqual:formula]) {
            return its[i];
        }
    }
    GLCheckListItem* out = [[GLCheckListItem alloc]initWithFormula:formula];
    [_restrictions addObject:out];
    return out;
}

@end
