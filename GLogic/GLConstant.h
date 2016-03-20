//
//  GLConstant.h
//  GLogic
//
//  Created by Thomas Gray on 14/03/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "GLTerm.h"

@interface GLConstant : GLTerm
-(instancetype)initWithIndex:(NSInteger)i;
@end

NS_INLINE GLConstant* GLMakeConstant(NSInteger i){
    return [[GLConstant alloc]initWithIndex:i];
}
