//
//  GLVariable.h
//  GLogic
//
//  Created by Thomas Gray on 14/03/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "GLTerm.h"

@interface GLVariable : GLTerm
-(instancetype)initWithIndex:(NSInteger)i;
@end

NS_INLINE GLVariable* GLMakeVariable(NSInteger i){
    return [[GLVariable alloc]initWithIndex:i];
}