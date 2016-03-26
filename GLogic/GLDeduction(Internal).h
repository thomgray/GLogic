/*!
 @header GLDeduction(Internal).h
 @package GLogic
 
 The file containing the Internal category for the GLDeduction class. Contains methods appropriate for internal use. These are principally focuesed on deduction querying and getting relevant to inference methods defined in GLDeduction(Inference).h
 
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

-(void)tidyDeductionIncludingNodes:(NSArray<GLDedNode*>*)nodes;

-(instancetype)subProofWithAssumption:(GLDedNode*)assumption;

-(NSSet<GLFormula*>*)getAllFormulaDecompositions;
-(NSSet<GLFormula*>*)getAllFormulaDecompositions_includingNegations:(BOOL)includeNegations includingConclusion:(BOOL)includeConclusion;
-(NSSet<GLFormula*>*)getAllFormulaDecompositionsAndTheirNegations;
+(NSSet<GLFormula*>*)getAllFormulaDecompositions:(NSArray<GLFormula*>*)formulas;
+(NSSet<GLFormula*>*)getAllFormulasAndTheirNegations:(NSSet<GLFormula*>*)formulas;

@end