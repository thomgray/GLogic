/*!
 @author Thomas Gray
 @copyright 2016. Thomas Gray
 */

#import "GLDeduction.h"
#import "GLDeductionCheckList.h"
#import "NSSet(Internal).h"

@interface GLDeduction (Internal)

@property  GLDeductionCheckList* checkList;

#pragma mark Querying

-(BOOL)isInformedBy:(GLFormula*)f;
-(BOOL)mayAttempt:(GLInferenceRule)rule forConclusion:(GLFormula*)conclusion;

#pragma mark Modification

-(void)appendNode:(GLDedNode*)node;
-(void)addReiteration:(NSArray<GLDedNode*>*)reiteration;
-(GLDedNode*)append:(GLFormula*)conc rule:(GLInferenceRule)rule dependencies:(NSArray<GLDedNode*>*)nodes;

-(void)assimilateDeduction:(GLDeduction*)deduction fromLine:(NSInteger)line;

-(void)tidyDeductionIncludingNodes:(NSArray<GLDedNode*>*)nodes;

-(instancetype)subProofWithAssumption:(GLDedNode*)assumption;
-(instancetype)tempProof;

//phase these out
-(NSSet<GLFormula*>*)getAllFormulaDecompositions;
-(NSSet<GLFormula*>*)getAllFormulaDecompositions_includingNegations:(BOOL)includeNegations includingConclusion:(BOOL)includeConclusion;
-(NSSet<GLFormula*>*)getAllFormulaDecompositionsAndTheirNegations;
+(NSSet<GLFormula*>*)getAllFormulaDecompositions:(NSArray<GLFormula*>*)formulas;
+(NSSet<GLFormula*>*)getAllFormulasAndTheirNegations:(NSSet<GLFormula*>*)formulas;

//keep these
-(NSMutableSet<GLFormula*>*)allFormulaDecompositions;
-(NSMutableSet<GLFormula*>*)allFormulaDecompositionsIncludingConclusion;

-(NSArray<GLFormula*>*)formulasForReductio;
-(NSArray<GLFormula*>*)formulasForMPWithConclusion:(GLFormula*)conclusion;
-(NSArray<GLFormula*>*)formulasForCEWithConclusion:(GLFormula*)conclusion;
-(NSArray<GLFormula*>*)formulasForDE;


@end