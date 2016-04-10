//
//  GLDeduction.m
//  GLogic
//
//  Created by Thomas Gray on 06/04/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "GLDeduction.h"

@implementation GLDeduction

-(instancetype)init{
    self = [super init];
    if (self) {
        _sequence = [[NSMutableArray alloc]init];
        _checkList = [[GLDeductionCheckList alloc]init];
    }
    return self;
}

@end
