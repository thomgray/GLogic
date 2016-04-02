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
        _tier = 0;
    }
    return self;
}
-(instancetype)initWithPremises:(NSArray<GLFormula *> *)prems{
    self = [super init];
    if (self) {
        _sequence = [[NSMutableArray alloc]init];
        _checkList = [[GLDeductionCheckList alloc]init];
        _tier = 0;
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
        [self.logDelegate log:[prem description] deduction:self];
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

-(GLDedNode *)findNodeInSequence:(GLFormula *)form{
    for (NSInteger i=0; i<self.sequence.count; i++) {
        GLDedNode* node = self.sequence[i];
        if ([node.formula isEqual:form]) {
            return node;
        }
    }
    return nil;
}

-(NSArray<GLDedNode *> *)getNodesWithCriterion:(GLDedNodeCriterion)criterion{
    NSMutableArray<GLDedNode*>* out = [[NSMutableArray alloc]init];
    for (NSInteger i=0; i<self.sequence.count; i++) {
        GLDedNode* node = self.sequence[i];
        if (criterion(node)) {
            [out addObject:node];
        }
    }
    return out;
}

/*!
 Returns an array of arrays. The inner arrays contain [DedNode, NSNumber(of NSInteger)]. The first object is the dednode, the second is the tier
 */
-(NSArray<GLDedNode *> *)getLinearSequence{
    NSMutableArray<GLDedNode*>* out = [[NSMutableArray alloc]init];
    for (NSInteger i=0; i<_sequence.count; i++) {
        GLDedNode* node = _sequence[i];
        if (node.subProof) {
            [out addObjectsFromArray:[node.subProof getLinearSequence]];
        }
        [out addObject:node];
    }
    return out;
}


@end
