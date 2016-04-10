//
//  GLDeduction+Internal.m
//  GLogic
//
//  Created by Thomas Gray on 06/04/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "GLDeduction+Internal.h"

@implementation GLDeduction (Internal)

//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//
        #pragma mark Modifying
//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//

/*!
 *  Appends the parameter node to the Deduction with the following side effects:
 <ul>
 <li>Sets the tier of the Node to the <code>_currentTier</code></li>
 </ul>
 *
 *  @param node Node to be appended
 */
-(void)appendNode:(GLDedNode *)node{
    [node setTier:_currentTier];
    
    [_sequence addObject:node];
}

/**
 *  Increments the current tier
 */
-(void)stepUp{
    _currentTier++;
}

/**
 *  Decrements the current tier
 */
-(void)stepDown{
    _currentTier--;
}


//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//
        #pragma mark Querying
//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//

/*!
 *  Returns a node in the deduction with the parameter formula available given the <code>_currentTier</code>. This method assumes you want the node available for inference from the current tier. The following are potential side effects:
 <ul>
  <li>If the tier of the Node is less than the current tier, the node is reiterated before being returned</li>
 </ul>
 *
 *  @param formula The desired formula
    @return The node matching the parameter formula, or nil if not available
 */

-(GLDedNode*)findAvailableNode:(GLFormula *)formula{
    NSInteger tier = _currentTier;
    for (NSInteger i=_sequence.count-1; i>=0; i--) {
        GLDedNode* node = _sequence[i];
        if (node.tier>tier) continue;
        else if (node.tier<tier) tier = node.tier;
        
        if ([node.formula isEqual:formula]) {
            if (node.tier<_currentTier) {
                GLDedNode* reiteration = [GLDedNode infer:GLInference_Reiteration formula:formula withNodes:@[node]];
                [self appendNode:reiteration];
                node = reiteration;
            }
            return node;
        }
    }
    return nil;
}

@end
