//
//  GLDeductionCheckList.h
//  GLogic
//
//  Created by Thomas Gray on 20/03/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "GLDedNode.h"

@interface GLDeductionCheckList : NSObject{
    NSMutableArray* items;
    NSMutableSet<GLFormula*>* tempRestrictions;
}

//-(BOOL)checkInference:(GLInferenceRule)rule conclusion:(GLFormula*)conc;
-(void)resetList;
-(void)addRestriction:(GLFormula*)formula;
-(void)liftRestriction:(GLFormula*)formula;
-(BOOL)mayAttempt:(GLInferenceRule)rule conclusion:(GLFormula*)form;

@end
