//
//  SampleFormulas.m
//  GLogic
//
//  Created by Thomas Gray on 20/03/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "SampleFormulas.h"

@implementation SampleFormulas

+(CustomFormula *)P{
    return [[CustomFormula alloc]initWithPrimeFormula:GLMakeSentence(0)];
}
+(CustomFormula *)Q{
    return [[CustomFormula alloc]initWithPrimeFormula:GLMakeSentence(1)];
}
+(CustomFormula *)R{
    return [[CustomFormula alloc]initWithPrimeFormula:GLMakeSentence(2)];
}
+(CustomFormula *)S{
    return [[CustomFormula alloc]initWithPrimeFormula:GLMakeSentence(3)];
}

+(CustomFormula *)nP{
    return [CustomFormula makeNegationStrict:[self P]];
}
+(CustomFormula *)nnP{
    return [CustomFormula makeNegationStrict:[self nP]];
}
+(CustomFormula *)PaQ{
    return [CustomFormula makeConjunction:[self P] f2:[self Q]];
}
+(CustomFormula *)PbQ{
    return [CustomFormula makeBiconditional:[self P] f2:[self Q]];
}
+(CustomFormula *)PcQ{
    return [CustomFormula makeConditional:[self P] f2:[self Q]];
}
+(CustomFormula *)PvQ{
    return [CustomFormula makeDisjunction:[self P] f2:[self Q]];
}

+(CustomFormula *)RaS{
    return [CustomFormula makeConjunction:[self R] f2:[self S]];
}
+(CustomFormula *)RcS{
    return [CustomFormula makeConditional:[self R] f2:[self S]];
}

@end
