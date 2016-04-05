//
//  LogAnalysis.m
//  GLogic
//
//  Created by Thomas Gray on 02/04/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "LogAnalysis.h"

@implementation LogAnalysis

@synthesize fileName = _fileName;

-(instancetype)initWithFile:(NSString *)fileName{
    self = [super init];
    if (self) {
        [self setFileName:fileName];
    }
    return self;
}

-(void)setFileName:(NSString *)fileName{
    _fileName = fileName;
    _filePath = [NSString stringWithFormat:@"/Users/thomdikdave/Projects/XCodeDepository/GLogic/TestLogs/%@Log.txt", _fileName];
    _logText = [NSString stringWithContentsOfFile:_filePath encoding:NSUTF8StringEncoding error:nil];
    if (_logText) {
        _logLines = [_logText componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    }else{
        NSLog(@"Error loading file %@", _filePath);
    }
}

-(NSString *)fileName{
    return _fileName;
}

-(NSArray<NSValue *> *)rangesOfRepeatingString:(NSString *)str{
    NSRange rng;
    NSRange searchRange = NSMakeRange(0, _logText.length);
    NSMutableArray<NSValue*>* out = [[NSMutableArray alloc]init];
    while ((rng=[_logText rangeOfString:str options:NSLiteralSearch range:searchRange]).location!=NSNotFound) {
        [out addObject:[NSValue valueWithRange:rng]];
        searchRange = NSMakeRange(rng.location+rng.length, _logText.length-rng.length-rng.location);
    }
    return out;
}

-(NSArray<NSValue *> *)rangesOfRepeatingLines:(NSRange)linesRange{
    NSArray<NSString*>* templateArray = [_logLines subarrayWithRange:linesRange];
    NSRange rng = linesRange;
    NSMutableArray<NSValue*>* out = [[NSMutableArray alloc]init];
    
    while (rng.location+rng.length<_logLines.count) {
        NSArray<NSString*>* subArray = [_logLines subarrayWithRange:rng];
        if ([subArray isEqualToArray:templateArray]) {
            [out addObject:[NSValue valueWithRange:rng]];
            rng.location = rng.location+rng.length;
        }else rng.location = rng.location+1;
    }
    return out;
}

-(NSString *)stringOfLinesInRange:(NSRange)rng{
    NSString* out = _logLines[rng.location];
    for (NSInteger i=rng.location+1; i<rng.location+rng.length; i++) {
        NSString* str = _logLines[i];
        out = [out stringByAppendingFormat:@"\n%@", str];
    }
    return out;
}

-(NSString *)findLongestRepeatingString{
    NSArray<NSValue*>* ranges;
    for (NSInteger maxLength=(_logLines.count>100? 100:_logLines.count/2); maxLength>20; maxLength--) {
        
        for (NSInteger i=0; i+maxLength<_logLines.count; i++) {
            
            ranges = [self rangesOfRepeatingLines:NSMakeRange(i, maxLength)];
            if (ranges.count>1) return [self stringOfLinesInRange:ranges.firstObject.rangeValue];
            
        }
        
    }
    return nil;
}

@end
