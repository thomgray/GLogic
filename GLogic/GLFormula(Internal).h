//
//  GLFormula(Internal).h
//  GLogic
//
//  Created by Thomas Gray on 16/03/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "GLFormula.h"

@interface GLFormula (Internal)

-(NSEnumerator<GLFormula*>*)enumerateComposition;
-(instancetype)compositAtNode:(NSArray<NSNumber*>*)node;

@end
