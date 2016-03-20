//
//  GLFormula(Notation).m
//  GLogic
//
//  Created by Thomas Gray on 14/03/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "GLFormula(Notation).h"

@interface GLFormula (NotationPrivate)

-(NSString*)subscriptedIndex:(NSInteger)idx;
-(NSString*)stringForPrimeFormula:(GLPrimeFormula*)pf syntax:(GLSyntaxType)syntax language:(GLLanguageType)language;
-(NSString*)stringForTerm:(GLTerm*)term syntax:(GLSyntaxType)syntax language:(GLLanguageType)language;


@end

@implementation GLFormula (Notation)

-(GLSyntaxType)defaultSyntax{
    return GLSyntax_Standard;
}
-(GLLanguageType)defaultLanguage{
    return GLLanguage_Alphabetic;
}

-(NSString *)subscriptedIndex:(NSInteger)idx{
    NSString* intstring = [NSString stringWithFormat:@"%ld", idx];
    NSString* out = @"";
    for (NSInteger i=0; i<intstring.length; i++) {
        unichar c = [intstring characterAtIndex:i];
        switch (c) {
            case '0':
                out = [out stringByAppendingString:@"₀"];
                break;
            case '1':
                out = [out stringByAppendingString:@"₁"];
                break;
            case '2':
                out = [out stringByAppendingString:@"₂"];
                break;
            case '3':
                out = [out stringByAppendingString:@"₃"];
                break;
            case '4':
                out = [out stringByAppendingString:@"₄"];
                break;
            case '5':
                out = [out stringByAppendingString:@"₅"];
                break;
            case '6':
                out = [out stringByAppendingString:@"₆"];
                break;
            case '7':
                out = [out stringByAppendingString:@"₇"];
                break;
            case '8':
                out = [out stringByAppendingString:@"₈"];
                break;
            case '9':
                out = [out stringByAppendingString:@"₉"];
                break;
            default:
                @throw [NSException exceptionWithName:@"This can't happen" reason:NULL userInfo:NULL];
                break;
        }
    }
    return out;
}


-(NSString *)description{
    return [self stringWithSyntax:[self defaultSyntax] andLanguage:[self defaultLanguage]];
}

-(NSString *)stringWithSyntax:(GLSyntaxType)syntax andLanguage:(GLLanguageType)language{
    GLElement* root = self.rootElement;
    if (root.isPrimeFormula) {
        return [self stringForPrimeFormula:(GLPrimeFormula*)root syntax:syntax language:language];
    }else if (root.isConnective){
        NSMutableArray<NSString*>* args = [[NSMutableArray alloc]initWithCapacity: self.children.count];
        for (NSInteger i=0; i<self.children.count;i++) {
            GLFormula* f = [self.children objectAtIndex:i];
            [args addObject:[f stringWithSyntax:syntax andLanguage:language]];
        }
        return [self stringForConnective:(GLConnective*)root composits:args syntax:syntax language: language];
    }else if (root.isQuantifier){
        NSString* child = [self.children[0] stringWithSyntax:syntax andLanguage:language];
        NSString* var = [self stringForVariable:((GLQuantifier*)root).boundVariable syntax:syntax language:language];
        return [self stringForQuantifier:(GLQuantifier*)root composit:child variable:var syntax:syntax language:language];
    }else return NULL;
}

#pragma mark PrimeFormulas

-(NSString *)stringForPrimeFormula:(GLPrimeFormula *)pf syntax:(GLSyntaxType)syntax language:(GLLanguageType)language{
    if (pf.isRelation) {
        NSMutableArray<NSString*>* args = [[NSMutableArray alloc]init];
        GLRelation* rel = (GLRelation*)pf;
        for (NSInteger i=0; i<rel.arguments.count; i++) {
            [args addObject:[self stringForTerm:rel.arguments[i] syntax:syntax language:language]];
        }
        return [self stringForRelation:rel arguments:args syntax:syntax language:language];
    }else if (pf.isEquals){
        GLEquals* eq = (GLEquals*)pf;
        NSString* leftStr = [self stringForTerm:eq.leftTerm syntax:syntax language:language];
        NSString* rightStr = [self stringForTerm:eq.rightTerm syntax:syntax language:language];
        return [self stringForEquals:eq arguments:@[leftStr, rightStr] syntax:syntax language:language];
    }else if (pf.isSentence){
        return [self stringForSentence:(GLSentence*)pf syntax:syntax language:language];
    }else{
        @throw [NSException exceptionWithName:@"Unsupported prime formula" reason:NULL userInfo:NULL];
    }
}

-(NSString *)stringForSentence:(GLSentence *)sentence syntax:(GLSyntaxType)syntax language:(GLLanguageType)language{
    unichar s1 = 'A';
    switch (language) {
        case GLLanguage_Alphabetic:
            s1 += sentence.index;
            return [NSString stringWithFormat:@"%c", s1];
        case GLLanguage_Indexed:
            return [NSString stringWithFormat:@"S%@", [self subscriptedIndex:sentence.index]];
        default:
            @throw [NSException exceptionWithName:@"Unsupported Language" reason:NULL userInfo:NULL];
    }
}


-(NSString *)stringForRelation:(GLRelation *)rel arguments:(NSArray<NSString *> *)args syntax:(GLSyntaxType)syntax language:(GLLanguageType)language{
    NSString* relToken;
    unichar r1 = 'R';
    switch (language) {
        case GLLanguage_Indexed:
            relToken = [NSString stringWithFormat:@"R%@", [self subscriptedIndex:rel.index]];
            break;
        case GLLanguage_Alphabetic:
            r1 += rel.index;
            relToken = [NSString stringWithFormat:@"%c", r1];
            break;
        default:
            @throw [NSException exceptionWithName:@"This won't happen" reason:NULL userInfo:NULL];
    }
    NSString* argstring = @"";
    for (NSInteger i=0; i<args.count; i++) {
        argstring = [argstring stringByAppendingString:args[i]];
    }
    return [NSString stringWithFormat:@"%@%@", relToken, argstring];
}
-(NSString *)stringForEquals:(GLEquals *)equals arguments:(NSArray<NSString *> *)args syntax:(GLSyntaxType)syntax language:(GLLanguageType)language{
    switch (syntax) {
        case GLSyntax_Polish:
            return [NSString stringWithFormat:@"=%@%@", args.firstObject, args.lastObject];
            break;
        case GLSyntax_Standard:
            return [NSString stringWithFormat:@"%@=%@", args.firstObject, args.lastObject];
        default:
            @throw [NSException exceptionWithName:@"Unsupported syntax" reason:NULL userInfo:NULL];
    }
}

#pragma mark Terms

-(NSString *)stringForTerm:(GLTerm *)t syntax:(GLSyntaxType)syntax language:(GLLanguageType)language{
    if (t.isConstant) {
        return [self stringForConstant:(GLConstant*)t syntax:syntax language:language];
    }else if (t.isFunction){
        GLFunction* func = (GLFunction*)t;
        NSMutableArray<NSString*>* args = [[NSMutableArray alloc]initWithCapacity:func.arguments.count];
        for (NSInteger i=0; i<func.arguments.count; i++) {
            GLTerm* arg = func.arguments[i];
            [args addObject:[self stringForTerm:arg syntax:syntax language:language]];
        }
        return [self stringForFunction:(GLFunction*)t arguments:args syntax:syntax language:language];
    }else if (t.isVariable){
        return [self stringForVariable:(GLVariable*)t syntax:syntax language:language];
    }else return NULL;
}

-(NSString *)stringForVariable:(GLVariable *)var syntax:(GLSyntaxType)syntax language:(GLLanguageType)language{
    unichar v1 = 'x';
    switch (language) {
        case GLLanguage_Alphabetic:
            if (var.index<3) {
                v1 += var.index;
            }else{
                v1 += 2-var.index;
            }
            return [NSString stringWithFormat:@"%c", v1];
        case GLLanguage_Indexed:
            return [NSString stringWithFormat:@"v%@", [self subscriptedIndex:var.index]];
        default:
            @throw [NSException exceptionWithName:@"Unsupported language" reason:NULL userInfo:NULL];
    }
}
-(NSString *)stringForConstant:(GLConstant *)cons syntax:(GLSyntaxType)syntax language:(GLLanguageType)language{
    unichar c1 = 'a';
    switch (language) {
        case GLLanguage_Alphabetic:
            c1 += cons.index;
            return [NSString stringWithFormat:@"%c", c1];
        case GLLanguage_Indexed:
            return [NSString stringWithFormat:@"c%@", [self subscriptedIndex:cons.index]];
        default:
            @throw [NSException exceptionWithName:@"Unsupported language" reason:NULL userInfo:NULL];
    }
}
-(NSString *)stringForFunction:(GLFunction *)func arguments:(NSArray<NSString *> *)args syntax:(GLSyntaxType)syntax language:(GLLanguageType)language{
    unichar f1 = 'f';
    NSString* token = @"";
    switch (language) {
        case GLLanguage_Indexed:
            token = [NSString stringWithFormat:@"f%@", [self subscriptedIndex:func.index]];
            break;
        case GLLanguage_Alphabetic:
            f1 += func.index;
            token = [NSString stringWithFormat:@"%c", f1];
            break;
        default:
            break;
    }
    if (args.count==0) {
        return token;
    }
    NSString* argString = @"";
    for (NSInteger i=0; i<args.count; i++) {
        argString = [argString stringByAppendingString:args[i]];
    }
    return [NSString stringWithFormat:@"%@(%@)", token, argString];
}

#pragma mark Compositors

-(NSString *)stringForConnective:(GLConnective *)conn composits:(NSArray<NSString *> *)comps syntax:(GLSyntaxType)syntax language:(GLLanguageType)language{
    NSString* token;
    switch (conn.type) {
        case GLConnectiveType_Conditional:
            token = @"⟶";
            break;
        case GLConnectiveType_Biconditional:
            token = @"⟷";
            break;
        case GLConnectiveType_Conjunction:
            token = @"∧";
            break;
        case GLConnectiveType_Disjunction:
            token = @"∨";
            break;
        case GLConnectiveType_Negation:
            return [NSString stringWithFormat:@"¬%@", comps.firstObject];
        default:
            break;
    }
    return [NSString stringWithFormat:@"(%@%@%@)", comps.firstObject, token, comps.lastObject];
}

-(NSString *)stringForQuantifier:(GLQuantifier *)quant composit:(NSString *)comp variable:(NSString *)var syntax:(GLSyntaxType)syntax language:(GLLanguageType)language{
    NSString* token = quant.type==GLQuantifierType_Universal? @"∀" : @"∃";
    return [NSString stringWithFormat:@"%@%@%@", token, var, comp];
}































@end