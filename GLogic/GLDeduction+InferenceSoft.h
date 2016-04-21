//
//  GLDeduction+InferenceSoft.h
//  GLogic
//
//  Created by Thomas Gray on 26/03/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "GLDeduction+Internal.h"

@interface GLDeduction (InferenceSoft)

-(GLDedNode*)proveSoft:(GLFormula*)conclusion;
-(GLDedNode*)proveSoftSafe:(GLFormula*)conclusion;


//---------------------------------------------------------------------------------------------------------
//      Constructive
//---------------------------------------------------------------------------------------------------------
#pragma mark Constructive

-(GLDedNode*)infer_Soft_CI:(GLFormula*)conclusion;
-(GLDedNode*)infer_Soft_DI:(GLFormula*)conclusion;
-(GLDedNode*)infer_Soft_BI:(GLFormula*)conclusion;
-(GLDedNode*)infer_Soft_DNI:(GLFormula*)conclusion;
-(GLDedNode*)infer_Soft_CP:(GLFormula*)conclusion;

-(GLDedNode*)infer_Soft_DE:(GLFormula*)conclusion;
-(GLDedNode*)infer_Soft_RAA:(GLFormula*)conclusion;

//---------------------------------------------------------------------------------------------------------
//      Deconstructive
//---------------------------------------------------------------------------------------------------------
#pragma mark Deconstructive

-(GLDedNode*)infer_Soft_Generatives:(GLFormula*)conclusion;
-(BOOL)infer_Deconstructive_CE;
-(BOOL)infer_Deconstructive_DNE;
-(BOOL)infer_Deconstructive_BE;
-(BOOL)infer_Deconstructive_MP;
-(BOOL)infer_Deconstructive_MT;

@end
