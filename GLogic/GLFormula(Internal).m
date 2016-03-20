//
//  GLFormula(Internal).m
//  GLogic
//
//  Created by Thomas Gray on 16/03/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "GLFormula(Internal).h"

//---------------------------------------------------------------------------------------------------------
//      Enumerator
//---------------------------------------------------------------------------------------------------------
#pragma mark Enumerator

@interface GLFormulaEnumerator : NSEnumerator<GLFormula*>{
    NSArray<NSNumber*>* currentPosition;
}
@property GLFormula* formula;
-(instancetype)initWithFormula:(GLFormula*)form;
-(GLFormula*)formulaAtDecomposition:(NSArray<NSNumber*>*)ad;
@end

@implementation GLFormulaEnumerator
@synthesize formula;
-(GLFormula *)formula{return formula;}
-(void)setFormula:(GLFormula *)f{
    formula = f;
    currentPosition = @[];
}
-(instancetype)initWithFormula:(GLFormula *)form{
    self = [super init];
    if (self) {
        formula  = form;
    }
    return self;
}
-(id)nextObject{
    GLFormula* out = [self formulaAtDecomposition:currentPosition];
    
    return out;
}
-(GLFormula*)formulaAtDecomposition:(NSArray<NSNumber*>*)ad{
    GLFormula* out = formula;
    for (NSInteger i=0; i<ad.count; i++) {
        NSInteger index = ad[i].integerValue;
        out = [out getDecomposition:index];
    }
    return out;
}
@end

//---------------------------------------------------------------------------------------------------------
//      Formula Implementation
//---------------------------------------------------------------------------------------------------------
#pragma mark Formula Implementation

@implementation GLFormula (Internal)

-(NSEnumerator<GLFormula *> *)enumerateComposition{
    GLFormulaEnumerator * out = [[GLFormulaEnumerator alloc]initWithFormula:self];
    return out;
}

-(instancetype)compositAtNode:(NSArray<NSNumber *> *)node{
    if (!node || node.count==0) {
        return self;
    }else{
        NSInteger i = node.firstObject.integerValue;
        NSArray<NSNumber*>* further = [node subarrayWithRange:NSMakeRange(1, node.count-1)];
        GLFormula* comp = [self.children objectAtIndex:i];
        return [comp compositAtNode:further];
    }
}

@end


