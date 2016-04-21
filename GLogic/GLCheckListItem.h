//
//  GLCheckListItem.h
//  GLogic
//
//  Created by Thomas Gray on 15/04/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "GLDedNode.h"

@interface GLCheckListItem : NSObject <NSCopying>
@property GLFormula* conclusion;
@property GLInferenceRule inferenceRule;
@property NSMutableSet<NSNumber*>* rules;

-(instancetype)initWithFormula:(GLFormula*)form;

-(BOOL)addRule:(GLInferenceRule)rule;
-(BOOL)removeRule:(GLInferenceRule)rule;
-(BOOL)containtsRule:(GLInferenceRule)rule;

@end