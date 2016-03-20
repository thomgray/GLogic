//
//  GLEquals.h
//  GLogic
//
//  Created by Thomas Gray on 14/03/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "GLPrimeFormula.h"
#import "GLTerm.h"

@interface GLEquals : GLPrimeFormula
@property (nonatomic) GLTerm* leftTerm;
@property (nonatomic) GLTerm* rightTerm;

@end
