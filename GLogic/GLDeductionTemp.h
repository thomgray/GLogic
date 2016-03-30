/*!
 @class A temporary deduction list intended to hold a 'working out' of an inference, to be assimilated into a deduction proper
 */

#import "GLDedNode.h"

@interface GLDeductionTemp : NSObject

@property NSMutableArray<GLDedNode*>* nodes;

-(instancetype)initWithInheritedNodes:(NSArray<GLDedNode*>*)inheritedNodes;
-(void)appendNode:(GLDedNode*)node;

@end
