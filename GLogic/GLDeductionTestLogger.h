//
//  GLDeductionTestLogger.h
//  GLogic
//
//  Created by Thomas Gray on 30/03/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "GLDeduction+InferenceHard.h"

@interface GLDeductionTestLogger : NSObject <GLDeductionLogDelegate>{
    NSString * filePath;
    NSInteger counter;
}

@property NSString* fileName;
@property NSMutableString* logString;
@property GLDeduction* mainDeduction;

-(void)writeToFile:(NSString*)name;

+(NSString*)indent:(NSInteger)i;

@end
