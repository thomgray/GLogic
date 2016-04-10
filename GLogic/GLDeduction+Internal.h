//
//  GLDeduction+Internal.h
//  GLogic
//
//  Created by Thomas Gray on 06/04/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "GLDeduction.h"

NS_ASSUME_NONNULL_BEGIN

@interface GLDeduction (Internal)

#pragma mark Modifying

-(void)appendNode:(GLDedNode*)node;
-(void)stepUp;
-(void)stepDown;


#pragma mark Querying

-(nullable GLDedNode*)findAvailableNode:(GLFormula*)formula;




@end

NS_ASSUME_NONNULL_END