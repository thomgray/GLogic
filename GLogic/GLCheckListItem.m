//
//  GLCheckListItem.m
//  GLogic
//
//  Created by Thomas Gray on 15/04/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "GLCheckListItem.h"

@implementation GLCheckListItem

-(instancetype)init{
    self = [super init];
    if (self) {
        _rules = [[NSMutableSet alloc]init];
    }
    return self;
}

-(instancetype)initWithFormula:(GLFormula *)form{
    self = [super init];
    if (self) {
        _rules = [[NSMutableSet alloc]init];
        _conclusion = form;
    }
    return self;
}

-(BOOL)addRule:(GLInferenceRule)rule{
    NSNumber* i = [NSNumber numberWithInteger:rule];
    if (![_rules containsObject:i]) {
        [_rules addObject:i];
        return TRUE;
    }else return FALSE;
}
-(BOOL)removeRule:(GLInferenceRule)rule{
    NSNumber* i = [NSNumber numberWithInteger:rule];
    if ([_rules containsObject:i]) {
        [_rules removeObject:i];
        return TRUE;
    }else return  FALSE;
}
-(BOOL)containtsRule:(GLInferenceRule)rule{
    NSNumber* i = [NSNumber numberWithInteger:rule];
    return [_rules containsObject:i];
}

-(NSString *)description{
    NSMutableString* inferenceString = [[NSMutableString alloc]init];
    NSArray<NSNumber*>* infArray = _rules.allObjects;
    for (NSInteger i=0; i<infArray.count; i++) {
        GLInferenceRule rule = (GLInferenceRule)infArray[i].integerValue;
        [inferenceString appendFormat:@"%@, ", GLStringForRule(rule)];
    }
    return [NSString stringWithFormat:@"%@ : %@", self.conclusion, inferenceString];
}

-(BOOL)isEqual:(id)object{
    if ([object isKindOfClass:[GLCheckListItem class]]) {
        GLCheckListItem* listItem = (GLCheckListItem*)object;
        return self.inferenceRule==listItem.inferenceRule && [self.conclusion isEqual:listItem.conclusion] && [_rules isEqualToSet:listItem.rules];
    }else return FALSE;
}

-(NSUInteger)hash{
    return [self.conclusion hash] ^ (NSUInteger)self.inferenceRule ^ [_rules hash];
}

-(id)copyWithZone:(NSZone *)zone{
    GLCheckListItem* out = [[self.class alloc]initWithFormula:_conclusion];
    
    [out setRules:[NSMutableSet setWithSet:_rules]];
    return out;
}

@end
