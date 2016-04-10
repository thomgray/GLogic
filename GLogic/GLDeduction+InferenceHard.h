//
//  GLDeduction+InferenceHard.h
//  GLogic
//
//  Created by Thomas Gray on 26/03/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "GLDeduction+InferenceSoft.h"

@interface GLDeduction (InferenceHard)

-(GLDedNode*)proveHard:(GLFormula*)conclusion;

//Easy Constructions
-(GLDedNode *)infer_Hard_CI:(GLFormula *)conclusion;
-(GLDedNode *)infer_Hard_DNI:(GLFormula *)conclusion;
-(GLDedNode *)infer_Hard_DI:(GLFormula *)conclusion;
-(GLDedNode *)infer_Hard_BI:(GLFormula *)conclusion;
-(GLDedNode *)infer_Hard_CP:(GLFormula *)conclusion;

//Deconstructions
-(GLDedNode *)infer_Hard_CE:(GLFormula *)conclusion;
-(GLDedNode *)infer_Hard_BE:(GLFormula *)conclusion;
-(GLDedNode *)infer_Hard_DNE:(GLFormula *)conclusion;
-(GLDedNode *)infer_Hard_MP:(GLFormula *)conclusion;
-(GLDedNode *)infer_Hard_MT:(GLFormula *)conclusion;

//Complicated Ones
-(GLDedNode *)infer_Hard_RAA:(GLFormula *)conclusion;

-(GLDedNode *)infer_Hard_DE:(GLFormula *)conclusion;
-(GLDedNode *)infer_Hard_DE:(GLFormula *)conclusion withDisjunction:(GLDedNode*)node;



@end
