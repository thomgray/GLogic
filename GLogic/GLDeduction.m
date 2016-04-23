//
//  GLDeduction.m
//  GLogic
//
//  Created by Thomas Gray on 16/03/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "GLDeduction.h"
#import "GLDeductionCheckList.h"
#import "GLInference.h"

@interface GLDeduction (Private)

-(void)setCheckList:(GLDeductionCheckList*)clist;
-(void)setCurrentTier:(NSInteger)currentTier;

@end

@implementation GLDeduction
@synthesize sequence = _sequence;
@synthesize premises = _premises;
@synthesize conclusion = _conclusion;

-(instancetype)init{
    self = [super init];
    if (self) {
        _sequence = [[NSMutableArray alloc]init];
        _checkList = [[GLDeductionCheckList alloc]init];
        _currentTier = 0;        
    }
    return self;
}

-(instancetype)initWithPremises:(NSArray<GLFormula *> *)prems{
    self = [self init];
    if (self) {
        [self addPremises:prems];
    }
    return self;
}

-(instancetype)initWithPremises:(NSArray<GLFormula *> *)prems conclusion:(GLFormula *)conc{
    self = [self initWithPremises:prems];
    if (self) {
        [self setConclusion:conc];
    }
    return self;
}

/**
 *  Appends each of the parameter premises to the deduction. Should only be called before any other formulas are appended to the deduction.
 *
 *  @param premises The formulas to be added to the deduction as premises
 */
-(void)addPremises:(NSArray<GLFormula *> *)premises{
    _premises = premises;    
    for (NSInteger i=0; i<premises.count; i++) {
        GLDedNode* prem = [GLDedNode infer:GLInference_Premise formula:premises[i] withNodes:nil];
        [_sequence addObject:prem];
    }
}

//---------------------------------------------------------------------------------------------------------
//      Getting / Querying
//---------------------------------------------------------------------------------------------------------
#pragma mark Getting / Querying

/**
*  Checks the ENTIRE deduction for a node with the parameter formula, returning that node if it exists. This does not check for availability, hence should not be used for internal inferential purposes
*
*  @param f The formula in question
*
*  @return The node with the parameter formula or nil if not in the deduciton
*/
-(BOOL)containsFormula:(GLFormula *)f{
    for (NSInteger i=0; i<self.sequence.count; i++) {
        GLDedNode* node = self.sequence[i];
        if ([node.formula isEqual:f]) {
            return TRUE;
        }
    }
    return FALSE;
}

-(id)copyWithZone:(NSZone *)zone{
    GLDeduction* out = [[self.class alloc]init];
    
    [out setPremises:self.premises];
    [out setConclusion:self.conclusion];
    [out setSequence:[[NSMutableArray alloc]initWithArray:self.sequence copyItems:YES]];
    
    [out setCheckList:_checkList.copy];
    [out setCurrentTier:_currentTier];
        
    return out;
}

//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//
#pragma mark Setting
//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//

-(void)setConclusion:(GLFormula *)conclusion{
    _conclusion = conclusion;
    _rootInference = [GLInference inferenceWithFormula:conclusion];
}
-(GLFormula *)conclusion{
    return _conclusion;
}

//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//
#pragma mark Private Copying Methods
//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//

-(void)setCheckList:(GLDeductionCheckList *)clist{
    _checkList = clist;
}

-(void)setCurrentTier:(NSInteger)currentTier{
    _currentTier = currentTier;
}

@end
