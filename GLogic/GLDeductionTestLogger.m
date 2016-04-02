//
//  GLDeductionTestLogger.m
//  GLogic
//
//  Created by Thomas Gray on 30/03/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "GLDeductionTestLogger.h"

@interface GLDeductionTestLogger (Private)

-(void)incrementCount;

@end

@implementation GLDeductionTestLogger

@synthesize fileName = _fileName;
@synthesize logString = _logString;

-(instancetype)init{
    self = [super init];
    if (self) {
        counter = 0;
        _logString = [[NSMutableString alloc]init];
        [self setFileName:@"unnamed"];
    }
    return self;
}

-(void)setFileName:(NSString *)fileName{
    _fileName = fileName;
    filePath = [NSString stringWithFormat:@"/Users/thomdikdave/Projects/XCodeDepository/GLogic/TestLogs/%@Log.txt", fileName];
}

-(NSString *)fileName{
    return _fileName;
}

-(void)writeToFile:(NSString *)name{
    [self setFileName:name];
    [_logString writeToFile:filePath atomically:NO encoding:NSUTF8StringEncoding error:nil];
}

-(void)log:(NSString *)string deduction:(GLDeduction *)ded{
    NSString* indent = [GLDeductionTestLogger indent:ded.tier];
    NSString* log = [NSString stringWithFormat:@"%@%@", indent, string];
    [_logString appendFormat:@"%@\n", log];
    [self incrementCount];
}

-(void)log:(NSString *)string annotation:(NSString *)annote deduction:(GLDeduction *)ded{
    NSString* indent = [GLDeductionTestLogger indent:ded.tier];
//    NSString* log = [NSString stringWithFormat:@"%@%@", indent, string];
    [_logString appendFormat:@"%@%@     ##  %@\n", indent, string, annote!=nil? annote:@""];
    [self incrementCount];
}

-(void)logNote:(NSString *)note deduction:(GLDeduction *)ded{
    [_logString appendFormat:@"%@## %@ ##\n",[GLDeductionTestLogger indent:ded.tier] ,note];
    [self incrementCount];
}

-(void)incrementCount{
    counter++;
    if (counter%100==0) {
        [self writeToFile:_fileName];
    }
}

+(NSString *)indent:(NSInteger)i{
    return [[@"" stringByPaddingToLength:i*3 withString:@" " startingAtIndex:0] stringByAppendingString:@"| "];
}

@end
