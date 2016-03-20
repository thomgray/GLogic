//
//  GLQuantifier.h
//  GLogic
//
//  Created by Thomas Gray on 14/03/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "GLCompositor.h"
#import "GLVariable.h"

typedef enum _GLQuantifierType {
    GLQuantifierType_Universal, GLQuantifierType_Existential
} GLQuantifierType;

@interface GLQuantifier : GLCompositor
@property (nonatomic) GLQuantifierType type;
@property (nonatomic) GLVariable* boundVariable;

-(instancetype)initWithType:(GLQuantifierType)type variable:(GLVariable*)var;
+(instancetype)makeUniversalQuantifierWithVariable:(NSInteger)idx;
+(instancetype)makeExistentialQuantifierWithVariable:(NSInteger)idx;

@end
