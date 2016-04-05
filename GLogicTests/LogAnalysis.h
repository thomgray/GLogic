//
//  LogAnalysis.h
//  GLogic
//
//  Created by Thomas Gray on 02/04/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LogAnalysis : NSObject{
    NSString* _filePath;
    NSArray<NSString*>* _logLines;
    NSString* _logText;
}

@property NSString* fileName;

-(instancetype)initWithFile:(NSString*)fileName;

-(NSArray<NSValue*>*)rangesOfRepeatingString:(NSString*)str;
-(NSArray<NSValue*>*)rangesOfRepeatingLines:(NSRange)linesRange;
-(NSString*)stringOfLinesInRange:(NSRange)rng;
-(NSString*) findLongestRepeatingString;

@end
