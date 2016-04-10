//
//  GLDeduction+Inference.h
//  GLogic
//
//  Created by Thomas Gray on 06/04/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "GLDeduction+Internal.h"

NS_ASSUME_NONNULL_BEGIN

@interface GLDeduction (Inference)

-(GLDedNode*)assume:(GLFormula*)assumption rule:(GLInferenceRule)rule;

#pragma mark Constructive Inferences
-(nullable GLDedNode*)infer_CI:(GLFormula*)conclusion;
-(nullable GLDedNode*)infer_BI:(GLFormula*)conclusion;
-(nullable GLDedNode*)infer_DI:(GLFormula*)conclusion;
-(nullable GLDedNode*)infer_DNI:(GLFormula*)conclusion;
-(nullable GLDedNode*)infer_CP:(GLFormula*)conclusion;


#pragma mark Deconstructive Inferences
-(nullable GLDedNode*)infer_CE:(GLFormula*)conclusion;
-(nullable GLDedNode*)infer_BE:(GLFormula*)conclusion;
-(nullable GLDedNode*)infer_DNE:(GLFormula*)conclusion;
-(nullable GLDedNode*)infer_MP:(GLFormula*)conclusion;
-(nullable GLDedNode*)infer_MT:(GLFormula*)conclusion;


#pragma mark DE & RAA
-(nullable GLDedNode*)infer_DE:(GLFormula*)conclusion;
-(nullable GLDedNode*)infer_RAA:(GLFormula*)conclusion;

@end

NS_ASSUME_NONNULL_END