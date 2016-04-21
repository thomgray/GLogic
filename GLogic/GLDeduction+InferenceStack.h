//
//  GLDeduction+InferenceStack.h
//  GLogic
//
//  Created by Thomas Gray on 13/04/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "GLDeduction+InferenceSoft.h"
#import "GLInference.h"

@interface GLDeduction (InferenceStack)

-(BOOL)proveHard:(GLInference *)conclusion;

//Easy Constructions
-(BOOL)infer_Hard_CI:(GLInference *)conclusion;
-(BOOL)infer_Hard_DNI:(GLInference *)conclusion;
-(BOOL)infer_Hard_DI:(GLInference *)conclusion;
-(BOOL)infer_Hard_BI:(GLInference *)conclusion;
-(BOOL)infer_Hard_CP:(GLInference *)conclusion;

//Deconstructions
-(BOOL)infer_Hard_CE:(GLInference *)conclusion;
-(BOOL)infer_Hard_BE:(GLInference *)conclusion;
-(BOOL)infer_Hard_DNE:(GLInference *)conclusion;
-(BOOL)infer_Hard_MP:(GLInference *)conclusion;
-(BOOL)infer_Hard_MT:(GLInference *)conclusion;

//Complicated Ones
-(BOOL)infer_Hard_RAA:(GLInference *)conclusion;

-(BOOL)infer_Hard_DE:(GLInference *)conclusion;


@end
