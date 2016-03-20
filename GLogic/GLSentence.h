//
//  GLSentence.h
//  GLogic
//
//  Created by Thomas Gray on 14/03/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "GLPrimeFormula.h"


@interface GLSentence : GLPrimeFormula
@property (nonatomic) NSInteger index;
-(instancetype)initWithIndex:(NSInteger)i;
@end

NS_INLINE GLSentence* GLMakeSentence(NSInteger i){
    return [[GLSentence alloc]initWithIndex:i];
};
