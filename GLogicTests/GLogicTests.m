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
#import "LogAnalysis.h"
#import <GLogic/GLDeduction(Internal).h>
#import <GLogic/GLDeduction+InferenceSoft.h>
#import <GLogic/GLDeduction+InferenceHard.h>
#import <GLogic/DeductionLogger.h>


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
@property Formula* RvS;
@property GLDeduction* deduction;
@property LogAnalysis* logAnalyser;
@property DeductionLogger* log;

@end

@implementation GLogicTests
@synthesize deduction;
@synthesize logAnalyser;

@synthesize log;


- (void)setUp {
    [super setUp];
    //make the formulas
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
    _RvS = [Formula makeDisjunction:_R f2:_S];
    
    deduction = [[GLDeduction alloc]init];
    log = [[DeductionLogger alloc]init];
    [log setFileName:[self methodName]];
    [log setMainDeduction:deduction];
    [deduction setLogger:log];
    [log setDynamicWriteLog:YES];
}

- (void)tearDown {
    

    [super tearDown];
}

-(void)proveEtc{
    if ([[self methodName]containsString:@"testUnprovable"]) {
        XCTAssert(![deduction prove:deduction.conclusion]);
    }else{
        XCTAssert([deduction prove:deduction.conclusion]);
    }
    
    [self logTestResults]; //write proof to file
    NSLog(@"%@", deduction); //write proof to stderr
    [log writeLogToSTDErr]; //write log to stderr;
}


//---------------------------------------------------------------------------------------------------------
//      Tests
//---------------------------------------------------------------------------------------------------------
#pragma mark Tests

-(void)test1{
    NSArray<Formula*>* prems = @[   _PcQ,
                                    _RcS,
                                    [Formula makeConditional:_Q f2:_R]
                                 ];
    [deduction addPremises:prems];
    Formula* conc = [Formula makeConditional: _P f2:_S];
    [deduction setConclusion:conc];
    [self proveEtc];
}

-(void)testPvnP{
    [deduction setConclusion:[Formula makeDisjunction:_P f2:_nP]];
    [self proveEtc];
}

-(void)test2{
        NSArray<Formula*>* prems = @[
                                 [Formula makeConditional:_PaQ f2:_R],
                                 ];
    [deduction addPremises:prems];
    GLFormula* conc = [Formula makeConditional:_Q f2:_R];
    conc = [Formula makeConditional:_P f2:conc];
    [deduction setConclusion:conc];
}

-(void)testUnprovable2{
    Formula* PvQvRvS = [Formula makeDisjunction:_PvQ f2:_R];
//    PvQvRvS = [Formula makeDisjunction:PvQvRvS f2:_S];
    [deduction addPremises:@[PvQvRvS]];
    [deduction setConclusion:[[Formula alloc]initWithPrimeFormula:GLMakeSentence(4)]];
    
//    [log addOutputCriteria:^BOOL(NSDictionary *info, GLDeduction *deduction) {
//    }];
    
    [self proveEtc];
}

-(void)testUnprovable{
    [deduction addPremises:@[_PcQ,
                             _R
                             ]];
    [deduction setConclusion:_S];
    [self proveEtc];
}

-(void)testVeryHard{
    Formula* antecedent = _PcQ;
    antecedent = [Formula makeBiconditional:antecedent f2:_RaS];
    antecedent = [Formula makeNegationStrict:antecedent];
    Formula* consequent = [antecedent restrictToDisjunctions];
    Formula* conclusion = [Formula makeConditional:antecedent f2:consequent];
    [deduction setConclusion:conclusion];
    [self proveEtc];
}

-(void)testDE{
    Formula* PvQvR = [Formula makeDisjunction:_PvQ f2:_R];
    
    Formula* RcS = _RcS;
    Formula * PcS = [Formula makeConditional:_P f2:_S];
    Formula * SvQ = [Formula makeDisjunction:_S f2:_Q];
    
    [deduction addPremises:@[PvQvR, RcS, PcS]];
    [deduction setConclusion:SvQ];
    [self proveEtc];
}

//---------------------------------------------------------------------------------------------------------
//      Delegate Methods
//---------------------------------------------------------------------------------------------------------
#pragma mark Delegate Methods

-(NSString*)methodName{
    NSString* methodName = [self name];
    NSRange preRange = [methodName rangeOfString:@"-[GLogicTests "];
    methodName = [methodName substringFromIndex:preRange.length];
    methodName = [methodName substringToIndex:methodName.length-1];
    return methodName;
}

-(void)logTestResults{
    NSString* methodName = [self methodName];
    NSString* path =  [NSString stringWithFormat:@"/Users/thomdikdave/Projects/XCodeDepository/GLogic/TestLogs/%@.txt", methodName];
    NSString* dedString = [deduction sequentString];
    dedString = [dedString stringByAppendingFormat:@"\n\n%@", [deduction toString]];
    
    NSString* preample = [deduction containsFormula:deduction.conclusion] ? @"Proven" : @"Not Proven";
    
    NSString* logString = [NSString stringWithFormat:@"%@\n\n%@", preample, dedString];
    [logString writeToFile:path atomically:NO encoding:NSUTF8StringEncoding error:nil];    
}

@end
