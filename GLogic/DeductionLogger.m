//
//  DeductionLogger.m
//  GLogic
//
//  Created by Thomas Gray on 04/04/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "DeductionLogger.h"

#define establishedKeys @[@"Comclusion", @"Node"]


#pragma mark
//---------------------------------------------------------------------------------------------------------
//      Deduction Logger
//---------------------------------------------------------------------------------------------------------
#pragma mark Deduction Logger

@interface DeductionLogger (Private)

-(void)tickOver;
-(BOOL)checkEvent:(LogEvent *) event;

@end

@implementation DeductionLogger

@synthesize fileName = _fileName;

-(instancetype)init{
    self = [super init];
    if (self) {
        _eventList = [[NSMutableArray alloc]init];
        
        _criteria = [[NSMutableArray alloc]init];
        _logCount = 0;
    }
    return self;
}

//---------------------------------------------------------------------------------------------------------
//      User Methods
//---------------------------------------------------------------------------------------------------------
#pragma mark User Methods

-(void)setFileName:(NSString *)fileName{
    _fileName = fileName;
    _filePath = [NSString stringWithFormat:@"/Users/thomdikdave/Projects/XCodeDepository/GLogic/TestLogs/%@Log.txt", fileName];
}
-(NSString *)fileName{
    return _fileName;
}

//---------------------------------------------------------------------------------------------------------
//      Protocol Methods
//---------------------------------------------------------------------------------------------------------
#pragma mark Protocol Methods


-(void)logInfo:(NSDictionary<NSString *,id> *)info deduction:(GLDeduction *)deduction{
    LogEvent* event = [LogEvent eventWithDeduction:deduction info:info];
    [_eventList addObject:event];
    [self tickOver];
}

//---------------------------------------------------------------------------------------------------------
//      Output Control
//---------------------------------------------------------------------------------------------------------
#pragma mark Output Control

-(void)addOutputCriteria:(BOOL (^)(NSDictionary *, GLDeduction *))criterion{
    [_criteria addObject:criterion];
}

-(void)resetOutputCriteria{
    [_criteria removeAllObjects];
}

//---------------------------------------------------------------------------------------------------------
//      Output
//---------------------------------------------------------------------------------------------------------
#pragma mark Output

-(NSString *)outputLogString{
    NSMutableString* out = [[NSMutableString alloc]init];
    for (NSInteger i=0; i<_eventList.count; i++) {
        LogEvent* event = _eventList[i];
        if ([self checkEvent:event]) {
            [out appendFormat:@"%@\n", event.description];
        }
    }
    return out;
}

-(void)writeLogToFile{
    NSString* logString = [self outputLogString];
    [logString writeToFile:_filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

-(void)writeLogToSTDErr{
    NSLog(@"Log for %@:\n%@", _fileName, [self outputLogString]);
}

//---------------------------------------------------------------------------------------------------------
//      Private Methods
//---------------------------------------------------------------------------------------------------------
#pragma mark Private Methods


-(void)tickOver{
    _logCount++;
    if (_logCount%40 && _fileName) {
        [self writeLogToFile];
    }
}

-(BOOL)checkEvent:(LogEvent *)event{
    if (_criteria.count==0) {
        return TRUE;
    }
    for (NSInteger i=0; i<_criteria.count; i++) {
        BOOL(^criterion)(NSDictionary* info, GLDeduction* deduction) = _criteria[i];
        if (criterion(event.info, event.deduction)) {
            return TRUE;
        }
    }
    return FALSE;
}


@end
