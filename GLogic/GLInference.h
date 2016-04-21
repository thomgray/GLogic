//
//  GLInference.h
//  GLogic
//
//  Created by Thomas Gray on 13/04/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//
#import "GLDedNode.h"

NS_ASSUME_NONNULL_BEGIN

@class GLCheckListItem;

/**
 *  <b>GLInference : NSObject</b> <p/> 
 *  @description A container class for a number of properties relevant to a particular inference case.
 *  @discussion <dl><dt><code>GLFormula * formula</code>:</dt><dd>The inferred formula</dd><dt><code>GLInferenceRule: inferenceRule</code>:</dt><dd>The inference rule associated with the inference</dd><dt><code>NSArray<GLInference*>* subInferences</code>:</dt><dd>Sub inferences to this inference; may be nil</dd></dl>
 */
@interface GLInference : NSObject <NSCopying>{
    NSMutableSet<GLCheckListItem*>* _restrictions;
    NSMutableSet<GLFormula*>* _categoricalRestrictions;
}

/**
 *  The non-null formula property. The conclusion for the inference
 */
@property GLFormula* formula;

/**
 *  The node property, has a value if proven, nil if not proven.
 */
@property GLDedNode* _Nullable node;

/**
 *  Nullable array of sub-inferences. these represent auxilliary formulas that must be proven if the conclusion is to be inferred. In case the formula is in the deduction or simply doesn't require further inference recursions, then this value should be nil
 */
@property NSArray<GLInference*>* _Nullable subInferences;

/**
 *  The super inference to this inference. Null if this is the root inference
 */
@property (weak) GLInference* _Nullable superInference;

/**
 *  The rule of this inference
 */
@property GLInferenceRule inferenceRule;

//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//
#pragma mark Querying
//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//
-(BOOL)isProven;

//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//
#pragma mark Initialisers
//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//
-(instancetype)initWithFormula:(GLFormula*)formula;
+(instancetype)inferenceWithFormula:(GLFormula*)formula;

//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//
#pragma mark Restrictions
//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//

-(BOOL)addRestriction:(GLFormula*)formula;
-(BOOL)addRestriction:(GLFormula *)formula rule:(GLInferenceRule)rule;

-(BOOL)liftRestriction:(GLFormula*)formula;
-(BOOL)liftRestriction:(GLFormula *)formula rule:(GLInferenceRule)rule;

-(BOOL)mayAttempt:(GLFormula*)formula rule:(GLInferenceRule)rule;
-(BOOL)mayAttempt:(GLInferenceRule)rule;
-(BOOL)mayAttempt;

-(BOOL)mayAttempt_DE_withDisjunction:(GLFormula*)dj;

@end

NS_ASSUME_NONNULL_END
