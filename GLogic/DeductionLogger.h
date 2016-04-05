//
//  DeductionLogger.h
//  GLogic
//
//  Created by Thomas Gray on 04/04/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "LogEvent.h"

//---------------------------------------------------------------------------------------------------------
//      DeductionLogger
//---------------------------------------------------------------------------------------------------------
#pragma mark DeductionLogger

@class LogEvent;

@interface DeductionLogger : NSObject <DeductionLogDelegate>{
    NSMutableArray<BOOL(^)(NSDictionary* info, GLDeduction* ded)>* _criteria;
    NSString* _filePath;
    NSInteger _logCount;
}

@property GLDeduction* mainDeduction;
@property NSMutableArray<LogEvent*>* eventList;

@property NSString* fileName;
@property BOOL dynamicWriteLog;

-(void)addOutputCriteria:(BOOL(^)(NSDictionary* info, GLDeduction* deduction))criterion;

//-(void)addCommentsToOutput:(CommentCriterion)criterion;
//-(void)addInferenceEventsToOutput:(InferenceEventCriterion)criterion;
//-(void)addProofAttempsToOutput:(ProofAttemptEventCriterion)criterion;
-(void)resetOutputCriteria;

-(NSString*)outputLogString;
-(void)writeLogToFile;
-(void)writeLogToSTDErr;

@end

