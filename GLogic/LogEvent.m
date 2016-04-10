//
//  LogEvent.m
//  GLogic
//
//  Created by Thomas Gray on 04/04/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "LogEvent.h"


@implementation LogEvent

+(instancetype)eventWithDeduction:(GLDeduction *)deduction info:(NSDictionary<NSString *,id> *)info{
    LogEvent* out = [[self alloc]init];
    [out setDeduction:deduction];
    [out setInfo:info];
    return out;
}
+(NSArray<NSString *> *)establishedKeys{
    return @[@"Title", @"Conclusion", @"Node", @"Method", @"Recursion", @"Comment"];
}

-(NSString *)description{
    NSMutableString* out = [[NSMutableString alloc]init];
    NSArray<NSString*>* keys = [LogEvent establishedKeys];
    for (NSInteger i=0; i<keys.count; i++) {
        id value = [_info objectForKey:keys[i]];
        if (value) {
            [out appendFormat:@"%@-%@ / ",keys[i], value];
        }
    }
    NSArray* allkeys = _info.allKeys;
    for (NSInteger i=0; i<allkeys.count; i++) {
        if (![keys containsObject:allkeys[i]]) {
            [out appendFormat:@"%@-%@ / ", allkeys[i], [_info objectForKey:allkeys[i]]];
        }
    }
    return out;
}

@end