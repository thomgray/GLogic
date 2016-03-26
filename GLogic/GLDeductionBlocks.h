//
//  GLDeductionBlocks.h
//  GLogic
//
//  Created by Thomas Gray on 17/03/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "GLDeduction.h"

//---------------------------------------------------------------------------------------------------------
//      GLInferenceResult
//---------------------------------------------------------------------------------------------------------
#pragma mark GLInferenceResult

@interface GLInferenceResult : NSObject

@property NSArray<GLFormula*>* steps;
@property GLInferenceRule rule;
+(instancetype)rule:(GLInferenceRule)rule steps:(NSArray<GLFormula*>*)steps;
@end

//typedef GLDedNode*(^GLDeductionRuleDirected)(GLFormula* conc, GLDeduction* ded);
/**
 * For some conclusion C, we are looking for criteria for the following inference rules:
 <dl>
    <dt>BE</dt>
    <dd>Where C = P->Q, either:<br/> P<->Q <br/>OR<br/>Q<->P</dd>
    <dt>CE</dt>
    <dd>For any formula P: <br/>P&C<br/>OR<br/> C&P</dd>
    <dt>DE</dt>
    <dd>Any disjunct (PvQ) <br/> AND <br/> P->C <br/>  AND <br/> Q->C </dd>
    <dt>DNE</dt>
    <dd>The formula ~~C</dd>
    <dt>MP</dt>
    <dd>Any conditional P->C <br/> AND <br/> The antecent P</dd>
    <dt>MT</dt>
    <dd>Given a formula P where C = ~P, any conditional P->Q <br/> AND <br/> ~Q</dd>
 </dl>
 <table>
 <tt>Something</tt>
 </table>
 */
@interface GLInferenceScheme : NSObject


@end



//---------------------------------------------------------------------------------------------------------
//      Block Definitions
//---------------------------------------------------------------------------------------------------------
/**
 *  @typedef GenerativeInferenceBlock
 *  Generative Inference Block. The block is used by iterating through a deduction sequence and passing each node in the sequence to this block. It expects to return an array (potentially nil) of nodes to be inferred from each node.
 *  @param node A node in the deduction
 *  @param ded  The deduction itself
 *  @see  GLDeduction(Inference)
 *  @return An array of DedNode's to be inferred given the specified node
 */
typedef NSArray<GLDedNode*>*(^GenerativeInferenceBlock)(GLDedNode* node, GLDeduction* ded);
typedef GLInferenceResult* (^DirectedInferenceBlock)(GLFormula* conclusion);

#pragma mark
//---------------------------------------------------------------------------------------------------------
//      GLDeduction Blocks
//---------------------------------------------------------------------------------------------------------
#pragma mark GLDeduction Blocks

@interface GLDeductionBlocks: NSObject
//---------------------------------------------------------------------------------------------------------
//      Generative Blocks
//---------------------------------------------------------------------------------------------------------
#pragma mark Generative Blocks

+(GenerativeInferenceBlock)generative_CE;
+(GenerativeInferenceBlock)generative_BE;
+(GenerativeInferenceBlock)generative_DNE;
+(GenerativeInferenceBlock)generative_MP;
+(GenerativeInferenceBlock)generative_MT;

//---------------------------------------------------------------------------------------------------------
//      Directed Blocks
//---------------------------------------------------------------------------------------------------------
#pragma mark Directed Blocks

//constructive
+(DirectedInferenceBlock)directed_CI;
+(DirectedInferenceBlock)directed_DNI;
+(DirectedInferenceBlock)directed_BI;
+(DirectedInferenceBlock)directed_DI;
+(DirectedInferenceBlock)directed_CP;
+(DirectedInferenceBlock)directed_CPDE;

//deconstructive
+(DirectedInferenceBlock)directed_DE;
+(DirectedInferenceBlock)directed_BE;
+(DirectedInferenceBlock)directed_CE;
+(DirectedInferenceBlock)directed_DNE;
+(DirectedInferenceBlock)directed_MP;
+(DirectedInferenceBlock)directed_MT;

+(DirectedInferenceBlock)directed_RAA;


@end

