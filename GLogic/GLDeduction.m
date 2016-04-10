//
//  GLDeduction.m
//  GLogic
//
//  Created by Thomas Gray on 16/03/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "GLDeduction.h"
#import "GLDeductionCheckList.h"

@implementation GLDeduction
@synthesize sequence = _sequence;
@synthesize premises = _premises;

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

-(BOOL)containsFormula:(GLFormula *)f{
    for (NSInteger i=0; i<self.sequence.count; i++) {
        GLDedNode* node = self.sequence[i];
        if ([node.formula isEqual:f]) {
            return TRUE;
        }
    }
    return FALSE;
}




@end
