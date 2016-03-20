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

@interface GLogicTests : XCTestCase
@property CustomFormula* biconditional;
@property CustomFormula* conjunction;
@end

@implementation GLogicTests
@synthesize conjunction;
@synthesize biconditional;

- (void)setUp {
    [super setUp];
    GLSentence* s1 = GLMakeSentence(0);
    GLSentence* s2 = GLMakeSentence(1);
    GLSentence* s3 = GLMakeSentence(2);
    
    conjunction = [[CustomFormula alloc]initWithPrimeFormula:s1];
    [conjunction doNegationStrict];
    [conjunction doNegationStrict];
    [conjunction doConjunction:s2 keepLeft:YES];
    
    biconditional = [[CustomFormula alloc]initWithPrimeFormula:s3];
    [biconditional doBiconditional:GLMakeSentence(1) keepLeft:YES];
    
    NSLog(@"Running test with formulas:");
    NSLog(@"F1 = %@", conjunction);
    NSLog(@"F2 = %@", biconditional);
    printf("\n");
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)test1{
    GLDeduction* ded = [[GLDeduction alloc]init];
    
    GLFormula* premise = [[GLFormula alloc]initWithPrimeFormula:GLMakeSentence(0)];
    
    [ded addPremises:@[premise]];
    
    GLFormula* conc = [premise copy];
    [conc doNegationStrict];
    [conc doNegationStrict];
    [conc doNegationStrict];
    [conc doNegationStrict];
    [conc doNegationStrict];
    [conc doNegationStrict];
    
    [ded infer_conclusion:conc];
    NSLog(@"%@", ded);
    
}

-(void)test2{
    GLSentence* s0 = GLMakeSentence(0);
    GLSentence* s1 = GLMakeSentence(1);
    GLSentence* s2 = GLMakeSentence(2);
    
    GLFormula * AaB = [[GLFormula alloc]initWithPrimeFormula:s0];
    [AaB doConjunction:s1 keepLeft:YES];
    
    GLFormula * AaB2 = [[GLFormula alloc]initWithPrimeFormula:s0];
    [AaB2 doConjunction:s1 keepLeft:YES];
    
    XCTAssert([AaB2 isEqual:AaB]);
    
    GLFormula* A = [[GLFormula alloc]initWithPrimeFormula:s0];
    XCTAssert([[AaB getDecomposition:0]isEqual:A]);
}

@end
