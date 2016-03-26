//
//  GLogicTests.m
//  GLogicTests
//
//  Created by Thomas Gray on 14/03/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <GLogic/GLogic.h>
#import <GLogic/GLDeduction(Inference).h>
#import "CustomFormula.h"
#import "SampleFormulas.h"
#import <GLogic/GLDeduction(Internal).h>

typedef CustomFormula Formula;

@interface GLogicTests : XCTestCase

@property Formula* P;
@property Formula* Q;
@property Formula* R;
@property Formula* S;
@property Formula* nP;
@property Formula* PaQ;
@property Formula* PvQ;
@property Formula* PcQ;
@property Formula* PbQ;
@property Formula* RaS;
@property Formula* RcS;

@end

@implementation GLogicTests

- (void)setUp {
    [super setUp];
    _P = [[Formula alloc]initWithPrimeFormula:GLMakeSentence(0)];
    _Q = [[Formula alloc]initWithPrimeFormula:GLMakeSentence(1)];
    _R = [[Formula alloc]initWithPrimeFormula:GLMakeSentence(2)];
    _S = [[Formula alloc]initWithPrimeFormula:GLMakeSentence(3)];
    _nP = [Formula makeNegationStrict:_P];
    _PaQ = [Formula makeConjunction:_P f2:_Q];
    _PvQ = [Formula makeDisjunction:_P f2:_Q];
    _PcQ = [Formula makeConditional:_P f2:_Q];
    _PbQ = [Formula makeBiconditional:_P f2:_Q];
    _RaS = [Formula makeConjunction:_R f2:_S];
    _RcS = [Formula makeConditional:_R f2:_S];
}

- (void)tearDown {
    [super tearDown];
}

-(void)test1{
    GLDeduction* ded = [[GLDeduction alloc]init];
    
    NSArray<Formula*>* prems = @[
                                 [SampleFormulas PcQ],
                                 [SampleFormulas RcS],
                                 [Formula makeConditional:[SampleFormulas Q] f2:[SampleFormulas R]]
                                 ];
    [ded addPremises:prems];
    Formula* conc = [Formula makeConditional:[SampleFormulas P] f2:[SampleFormulas S]];
    [ded proveSoft:conc];
    [ded tidyDeductionIncludingFormulas:@[conc]];
    NSLog(@"Prove P->S: %@", ded);
}

-(void)test2{
    GLDeduction* ded = [[GLDeduction alloc]init];
    
    NSArray<Formula*>* prems = @[
                                 _PvQ,
                                 [Formula makeConditional:[SampleFormulas P] f2:[SampleFormulas R]],
                                 [Formula makeConditional:[SampleFormulas Q] f2:[SampleFormulas R]]
                                 ];
    [ded addPremises:prems];

    [ded proveSemiSoft:_R];
    [ded tidyDeductionIncludingFormulas:@[_R]];
    NSLog(@"Prove R: %@", ded);
}

-(void)testDecomps{
    Formula* f1 = _PcQ;
    f1 = [Formula makeBiconditional:f1 f2:_RaS];
    f1 = [Formula makeDisjunction:f1 f2:_Q];
    NSLog(@"Formula = %@", f1);
    NSSet<GLFormula*>* decomps = [f1 getAllDecompositions];
    NSLog(@"All decomps: %@", decomps);
    NSArray<GLFormula*>* array = [decomps allObjects];
    for (NSInteger i=0; i<array.count; i++) {
        GLFormula* f = array[i];
        for (NSInteger j=i+1; j<array.count; j++) {
            GLFormula* g = array[j];
            XCTAssert(![f isEqual:g]);
        }
    }
}

-(void)testDedNode{
    GLDedNode* prem = [GLDedNode infer:GLInference_Premise formula: _PaQ withNodes:nil];
    GLDedNode* prem2 = [GLDedNode infer:GLInference_Premise formula: _PcQ withNodes:nil];
    
    GLDedNode* conc = [GLDedNode infer_CE:prem leftFormula:YES];
    XCTAssert(conc!=nil);
    NSLog(@"%@", conc.formula);
}


@end
