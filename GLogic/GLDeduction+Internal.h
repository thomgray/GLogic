/*!
 @author Thomas Gray
 @copyright 2016. Thomas Gray
 */

#import "GLDeduction.h"
#import "GLDeductionCheckList.h"
#import "NSSet(Internal).h"

typedef NSInteger GLDeductionIndex;

@interface GLDeduction (Internal)

@property  GLDeductionCheckList* checkList;

#pragma mark Querying

-(BOOL)isInformedBy:(GLFormula*)f;
-(BOOL)mayAttempt:(GLInferenceRule)rule forConclusion:(GLFormula*)conclusion;
-(BOOL)mayAttempt:(GLInferenceRule)rule conclusion:(GLFormula *)conclusion;

-(GLDedNode*)findAvailableNode:(GLFormula*)fomula;
-(NSArray<GLDedNode*>*)availableNodes;
-(NSArray<GLDedNode*>*)availableNodesWithCriterion:(GLDedNodeCriterion) criterion;

-(GLDeductionIndex)currentIndex;

#pragma mark Modification

-(void)stepUp;
-(void)stepDown;

-(void)appendNode:(GLDedNode*)node;
-(void)removeNodesFrom:(GLDedNode*)node;
-(void)removeNodesFromIndex:(GLDeductionIndex)index;

-(void)tidyDeductionIncludingNodes:(NSArray<GLDedNode*>*)nodes;


-(NSMutableSet<GLFormula*>*)allFormulaDecompositions;
-(NSMutableSet<GLFormula*>*)allFormulaDecompositionsIncludingConclusion;

-(NSArray<GLFormula*>*)formulasForReductio;
-(NSArray<GLFormula*>*)formulasForMPWithConclusion:(GLFormula*)conclusion;
-(NSArray<GLFormula*>*)formulasForMTWithConclusion:(GLFormula *)conclusion;
-(NSArray<GLFormula*>*)formulasForCEWithConclusion:(GLFormula*)conclusion;
-(NSArray<GLFormula*>*)formulasForDE;


@end