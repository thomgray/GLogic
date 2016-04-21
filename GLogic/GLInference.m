//
//  GLInference.m
//  GLogic
//
//  Created by Thomas Gray on 13/04/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "GLInference.h"
#import "GLCheckListItem.h"

//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//
#pragma mark GLInference
//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//

@interface GLInference (Private)

-(GLCheckListItem*)itemForFormula:(GLFormula*)formula makeIfNeccessary:(BOOL)make;

-(BOOL)mayAttemptPrivate:(GLFormula *)formula rule:(GLInferenceRule)rule;

-(BOOL)mayAttemptDEForDisjunction:(GLFormula*)dj;

-(NSString*)toStringWithIndent:(NSString*)indent;

@end

//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//
#pragma mark GLInference Implementation
//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//
@implementation GLInference

@synthesize subInferences = _subInferences;


//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//
#pragma mark Querying
//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//

-(BOOL)isProven{
    return _node!=nil;
}

/**
 *  Checks whether the conclusion is appropriate for the specified rule first, then checks to see if the parameter formula is restricted for the parameter rule. First for this inference, and recursivly for all super inferences. If the inference is blocked in any way, returns false, otherwise returns true
 *
 *  @param formula The formula in question
 *  @param rule    The rule in question
 *
 *  @return True if there are no restrictions, False otherwise
 */
-(BOOL)mayAttempt:(GLFormula *)formula rule:(GLInferenceRule)rule{
    if (!GLInferenceIsAppropriate(formula, rule)) return FALSE;
    return [self mayAttemptPrivate:formula rule:rule];
}

/**
 *  Calls @c mayAttempt:rule: for the inference's formula property given the specified rule
 *
 *  @param rule The rule in quesion
 *
 *  @return True is may attempt, false otherwise
 */
-(BOOL)mayAttempt:(GLInferenceRule)rule{
    return [self mayAttempt:_formula rule:rule];
}

/**
 *  Calls @c mayAttempt:rule: for the inference's formula and inferenceRule properties
 *
 *  @return True if may attempt, False otherwise
 */
-(BOOL)mayAttempt{
    return [self mayAttempt:_formula rule:_inferenceRule];
}

-(BOOL)mayAttempt_DE_withDisjunction:(GLFormula *)dj{
    if (_superInference) {
        return [_superInference mayAttemptDEForDisjunction:dj];
    }else return TRUE;
}


-(BOOL)mayAttemptPrivate:(GLFormula *)formula rule:(GLInferenceRule)rule{
    if ([_categoricalRestrictions containsObject:formula]) return FALSE;
    NSArray<GLCheckListItem*>* restrictions = _restrictions.allObjects;
    for (NSInteger i=0; i<restrictions.count; i++) {
        if ([restrictions[i].conclusion isEqual:formula] && [restrictions[i] containtsRule:rule])
            return FALSE;
    }
    
    if (_superInference) {
        return [_superInference mayAttempt:formula rule:rule];
    }else return TRUE;
}

-(BOOL)mayAttemptDEForDisjunction:(GLFormula *)dj{
    if (_inferenceRule==GLInference_DisjunctionElim && [_subInferences.firstObject.formula isEqual:dj]) {
        return FALSE;
    }else if (_superInference){
        return [_superInference mayAttemptDEForDisjunction:dj];
    }else return TRUE;
}


//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//
#pragma mark Initialising
//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//

-(instancetype)initWithFormula:(GLFormula *)formula{
    self = [super init];
    if (self) {
        _formula = formula;
    }
    return self;
}

+(instancetype)inferenceWithFormula:(GLFormula *)formula{
    return [[GLInference alloc]initWithFormula:formula];
}

/**
 *  Sets the sub inferences to this inference to the parameter inferences. As a side effect, the super inferences to the sub inferences are set to this.
 *
 *  @param subInferences The new sub inferences
 */
-(void)setSubInferences:(NSArray<GLInference *> *)subInferences{
    _subInferences = subInferences;
    for (NSInteger i=0; i<subInferences.count; i++) {
        [subInferences[i] setSuperInference:self];
    }
}
-(NSArray<GLInference *> *)subInferences{
    return _subInferences;
}

//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//
#pragma mark Restrictions
//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//

-(BOOL)addRestriction:(GLFormula *)formula{
    if (!_categoricalRestrictions) _categoricalRestrictions = [[NSMutableSet alloc]init];
    
    if (![_categoricalRestrictions containsObject:formula]) {
        [_categoricalRestrictions addObject:formula];
        return TRUE;
    }else return FALSE;
}

-(BOOL)addRestriction:(GLFormula *)formula rule:(GLInferenceRule)rule{
    if (!_restrictions) _restrictions = [[NSMutableSet alloc]init];
    GLCheckListItem* item = [self itemForFormula:formula makeIfNeccessary:YES];
    return [item addRule:rule];
}

-(BOOL)liftRestriction:(GLFormula *)formula{
    if (_categoricalRestrictions && [_categoricalRestrictions containsObject:formula]) {
        [_categoricalRestrictions removeObject:formula];
        return TRUE;
    }else return FALSE;
}

-(BOOL)liftRestriction:(GLFormula *)formula rule:(GLInferenceRule)rule{
    if (_restrictions) {
        GLCheckListItem* item = [self itemForFormula:formula makeIfNeccessary:NO];
        if (item && [item containtsRule:rule]) {
            [item removeRule:rule];
            return TRUE;
        }else return FALSE;
    }else return FALSE;
}

-(GLCheckListItem *)itemForFormula:(GLFormula *)formula makeIfNeccessary:(BOOL)make{
    NSArray<GLCheckListItem*>* items = _restrictions.allObjects;
    for (NSInteger i=0; i<items.count; i++) {
        GLCheckListItem* item = items[i];
        if ([item.conclusion isEqual:formula]) {
            return item;
        }
    }
    if (make) {
        GLCheckListItem* item = [[GLCheckListItem alloc]initWithFormula:formula];
        [_restrictions addObject:item];
        return item;
    }else return nil;
}

-(NSString *)description{
    return [NSString stringWithFormat:@"\n%@", [self toStringWithIndent:@""]];
}

-(NSString *)toStringWithIndent:(NSString *)indent{
    NSMutableString* out = [[NSMutableString alloc]initWithString:indent];
    [out appendString:_formula.description];
    if (_subInferences && _subInferences.count) {
        [out appendFormat:@" - (%@)", GLStringForRule(_inferenceRule)];
        NSString* indent2 = [indent stringByAppendingString:@"    "];
        for (NSInteger i=0; i<_subInferences.count; i++) {
            [out appendFormat:@"\n%@", [_subInferences[i] toStringWithIndent:indent2]];
        }
    }
    return out;
}

//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//
#pragma mark Equality
//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//

-(BOOL)isEqual:(id)object{
    if (![object isKindOfClass:[GLInference class]]) return FALSE;
    GLInference* inf = (GLInference*)object;
    
    if (![inf.formula isEqual:_formula]) return FALSE;
    if (!_inferenceRule==inf.inferenceRule) return FALSE;
    
    if (_node && inf.node) {
        if (![_node isEqual:inf.node]) return FALSE;
    }else if (!(!_node && !inf.node)) return FALSE;
    
    if (!_subInferences && !inf.subInferences) {
    }else if (_subInferences && inf.subInferences && _subInferences.count==inf.subInferences.count){
        if (![_subInferences isEqualToArray:inf.subInferences]) {
            return FALSE;
        }
    }else return FALSE;
    
    return TRUE;
}

-(NSUInteger)hash{
    return _formula.hash*2 ^ (NSUInteger)_inferenceRule*3 ^ _node.hash*4 ^ _subInferences.hash*5;
}

//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//
#pragma mark Copying
//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//
-(id)copyWithZone:(NSZone *)zone{
    GLInference* out = [[self.class alloc]initWithFormula:_formula];
    [out setInferenceRule:_inferenceRule];
    [out setSubInferences:[[NSArray alloc]initWithArray:_subInferences copyItems:YES]];
    [out setNode:_node];
    
    return out;
}

@end
