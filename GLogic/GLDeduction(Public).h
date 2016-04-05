//
//  GLDeduction(Public).h
//  GLogic
//
//  Created by Thomas Gray on 17/03/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "GLDeduction.h"

@interface GLDeduction (Public)

-(void)tidyDeductionIncludingFormulas:(NSArray<GLFormula*>*)forms;

-(NSString*)toString;
-(NSString*)sequentString;

+(NSString*)sequentString:(NSArray<GLFormula*>*)premises conclusion:(GLFormula*)conc;

-(BOOL)prove:(GLFormula*)conclusion;

@end
