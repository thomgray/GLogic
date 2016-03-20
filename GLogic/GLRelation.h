//
//  GLRelation.h
//  GLogic
//
//  Created by Thomas Gray on 14/03/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "GLPrimeFormula.h"
#import "GLTerm.h"

@interface GLRelation : GLPrimeFormula
@property (nonatomic) NSInteger index;
@property (nonatomic) NSArray<GLTerm*>* arguments;
@property (nonatomic, readonly) NSUInteger arity;

@end
