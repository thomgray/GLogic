//
//  GLDeductionCheckList.h
//  GLogic
//
//  Created by Thomas Gray on 20/03/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "GLDedNode.h"

@class GLCheckListItem;

@interface GLDeductionCheckList : NSObject{
    NSMutableArray<GLCheckListItem*>* items;
}

-(BOOL)checkInference:(GLInferenceRule)rule conclusion:(GLFormula*)conc index:(NSInteger)idx;
-(void)resetList;

@end
