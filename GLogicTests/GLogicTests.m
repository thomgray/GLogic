//
//  GLogicTests.m
//  GLogicTests
//
//  Created by Thomas Gray on 14/03/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <GLogic/GLogic.h>
#import "CustomFormula.h"
#import "SampleFormulas.h"
#import <GLogic/GLDeduction(Internal).h>
#import <GLogic/GLDeduction+InferenceSoft.h>
#import <GLogic/GLDeduction+InferenceHard.h>


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
@property GLDeduction* deduction;

@end

@implementation GLogicTests
@synthesize deduction;

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
    deduction = [[GLDeduction alloc]init];
}

- (void)tearDown {
    [super tearDown];
}

-(void)test1{
    NSArray<Formula*>* prems = @[   _PcQ,
                                    _RcS,
                                    [Formula makeConditional:_Q f2:_R]
                                 ];
    [deduction addPremises:prems];
    Formula* conc = [Formula makeConditional: _P f2:_S];
    [deduction setConclusion:conc];
    [deduction proveSoftSafe:conc];
    [deduction tidyDeductionIncludingFormulas:@[conc]];
    NSLog(@"Prove P->S: %@", deduction);
    [self logTestResults];
}

-(void)test4{
    [deduction addPremises:@[_PaQ]];
    [deduction setConclusion:_P];
    [deduction proveSoftSafe:_P];
    
    NSLog(@"%@", deduction);
    [self logTestResults];
}

-(void)test2{
        NSArray<Formula*>* prems = @[
                                 [Formula makeConditional:_PaQ f2:_R],
                                 ];
    [deduction addPremises:prems];
    GLFormula* conc = [Formula makeConditional:_Q f2:_R];
    conc = [Formula makeConditional:_P f2:conc];
    [deduction setConclusion:conc];
    [deduction proveHard:conc];
    
//    [deduction tidyDeductionIncludingFormulas:@[_R]];
    NSLog(@"%@", deduction);
    [self logTestResults];
}

-(void)testUnprovable{
    [deduction addPremises:@[_PvQ,
                             _R
                             ]];
    [deduction setConclusion:_S];
    [deduction proveHard:_S];
    
    NSLog(@"%@", deduction);
    [self logTestResults];
}

-(void)testVeryHard{
    Formula* antecedent = _PcQ;
    antecedent = [Formula makeBiconditional:antecedent f2:_RaS];
    antecedent = [Formula makeNegationStrict:antecedent];
    Formula* consequent = [antecedent restrictToDisjunctions];
    Formula* conclusion = [Formula makeConditional:antecedent f2:consequent];
    [deduction setConclusion:conclusion];
    [deduction proveHard:conclusion];
    
    NSLog(@"%@", deduction);
    [self logTestResults];
}

-(void)testDE{
    Formula* PvQvR = [Formula makeDisjunction:_PvQ f2:_R];
    
    Formula* RcS = _RcS;
    Formula * PcS = [Formula makeConditional:_P f2:_S];
    Formula * SvQ = [Formula makeDisjunction:_S f2:_Q];
    
    [deduction addPremises:@[PvQvR, RcS, PcS]];
    [deduction setConclusion:SvQ];
    NSLog(@"%@", deduction);
    
    NSThread* newThread = [[NSThread alloc]initWithTarget:self selector:@selector(printDeduction) object:nil];
    [newThread start];
    
    [deduction proveHard:SvQ];
    [deduction tidyDeductionIncludingFormulas:@[SvQ]];
    
    NSLog(@"*******************************************************************");
    NSLog(@"%@", deduction);
    [self logTestResults];
}

-(void)printDeduction{
    while (true){
        NSLog(@"%@", deduction);
        [NSThread sleepForTimeInterval:1.0f];
    }
    
}

-(void)logTestResults{
    NSString* methodName = [self name];
    NSRange preRange = [methodName rangeOfString:@"-[GLogicTests "];
    methodName = [methodName substringFromIndex:preRange.length];
    methodName = [methodName substringToIndex:methodName.length-1];
    NSString* path =  [NSString stringWithFormat:@"/Users/thomdikdave/Projects/XCodeDepository/GLogic/TestLogs/%@.txt", methodName];
    NSString* dedString = [deduction sequentString];
    dedString = [dedString stringByAppendingFormat:@"\n\n%@", [deduction toString]];
    
    NSString* preample = [deduction containsFormula:deduction.conclusion] ? @"Proven" : @"Not Proven";
    
    NSString* logString = [NSString stringWithFormat:@"%@\n\n%@", preample, dedString];
    [logString writeToFile:path atomically:NO encoding:NSUTF8StringEncoding error:nil];    
}


@end
