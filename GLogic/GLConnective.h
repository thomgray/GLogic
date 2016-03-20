//
//  GLConnective.h
//  GLogic
//
//  Created by Thomas Gray on 14/03/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "GLCompositor.h"

typedef enum _GLConnectiveType {
    GLConnectiveType_Conjunction, GLConnectiveType_Disjunction, GLConnectiveType_Negation, GLConnectiveType_Conditional, GLConnectiveType_Biconditional
} GLConnectiveType;

@interface GLConnective : GLCompositor
@property (nonatomic) GLConnectiveType type;

-(instancetype)initWithType:(GLConnectiveType)typ;

+(instancetype)makeNegation;
+(instancetype)makeConjunction;
+(instancetype)makeDisjunction;
+(instancetype)makeConditional;
+(instancetype)makeBiconditional;


@end
