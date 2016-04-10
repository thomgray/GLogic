//
//  GLDeduction.h
//  GLogic
//
//  Created by Thomas Gray on 06/04/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "GLDedNode.h"
#import "GLDeductionCheckList.h"

NS_ASSUME_NONNULL_BEGIN

@class GLDeduction;

@protocol DeductionLogDelegate <NSObject>
-(void)logInfo:(NSDictionary<NSString *,id> *)info deduction:(GLDeduction *)deduction;
@end

#pragma mark
//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//
#pragma mark GLDeduction
//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//

@interface GLDeduction : NSObject {
    NSMutableArray<GLDedNode*>* _sequence;
    GLDeductionCheckList* _checkList;
    NSInteger _currentTier;
}

@property NSArray<GLFormula*>* premises;
@property GLFormula* conclusion;

/*!
 *  Optional Test Logger paramter
 */
@property (weak) id<DeductionLogDelegate> _Nullable logger;


@end

NS_ASSUME_NONNULL_END
