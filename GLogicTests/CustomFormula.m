//
//  CustomFormula.m
//  GLogic
//
//  Created by Thomas Gray on 16/03/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "CustomFormula.h"

@implementation CustomFormula

-(NSString *)stringForConnective:(GLConnective *)conn composits:(NSArray<NSString *> *)comps syntax:(GLSyntaxType)syntax language:(GLLanguageType)language{
    if (conn.isConjunction) {
        switch (syntax) {
            case GLSyntax_Polish:
                return [NSString stringWithFormat:@"&%@%@", comps.firstObject, comps.lastObject];
            case GLSyntax_Standard:
                return [NSString stringWithFormat:@"(%@&%@)", comps.firstObject, comps.lastObject];
            default:
                break;
        }
    }else return [super stringForConnective:conn composits:comps syntax:syntax language:language];
}
-(NSString *)stringForSentence:(GLSentence *)sentence syntax:(GLSyntaxType)syntax language:(GLLanguageType)language{
    unichar s = 'P';
    s += sentence.index;
    return [NSString stringWithFormat:@"%c", s];
}

@end
