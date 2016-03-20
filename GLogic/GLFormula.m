//
//  GLFormula.m
//  GLogic
//
//  Created by Thomas Gray on 14/03/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "GLFormula.h"

@interface GLFormula (Private)

-(void)doComposition:(GLCompositor*)comp otherForm:(GLPrimeFormula*)pf keepLeft:(BOOL)left;
+(instancetype)makeComposite:(GLFormula*)f1 f2:(GLFormula*)f2 comp:(GLCompositor*)comp;

@end

@implementation GLFormula
@synthesize rootElement;
@synthesize children;

-(GLElement *)rootElement{
    return rootElement;
}
-(void)setRootElement:(GLElement *)root{
    rootElement = root;
}

-(instancetype)initWithPrimeFormula:(GLPrimeFormula *)form{
    self = [super init];
    if (self) {
        rootElement= form;
    }
    return self;
}

//---------------------------------------------------------------------------------------------------------
//      Basic Querying
//---------------------------------------------------------------------------------------------------------
#pragma mark Basic Querying

-(BOOL)isPrime{
    return rootElement.isPrimeFormula;
}
-(BOOL)isComposite{
    return rootElement.isCompositor;
}
-(BOOL)isNegation{
    return [self mainConnective:GLConnectiveType_Negation]!=nil;
}
-(BOOL)isDoubleNegation{
    return [self mainConnective:GLConnectiveType_Negation]!= nil &&
    [[self getDecomposition:0]mainConnective:GLConnectiveType_Negation]!=nil;
}
-(BOOL)isConjunction{
    return [self mainConnective:GLConnectiveType_Conjunction]!=nil;
}
-(BOOL)isDisjunction{
    return [self mainConnective:GLConnectiveType_Disjunction]!=nil;
}
-(BOOL)isConditional{
    return [self mainConnective:GLConnectiveType_Conditional]!=nil;
}
-(BOOL)isBiconditional{
    return [self mainConnective:GLConnectiveType_Biconditional]!=nil;
}
-(BOOL)isUniversalQualtifier{
    return [self mainQuantifier:GLQuantifierType_Universal]!=nil;
}
-(BOOL)isExistentialQuantifier{
    return [self mainQuantifier:GLQuantifierType_Existential]!=nil;
}

//---------------------------------------------------------------------------------------------------------
//      Advanced Querying
//---------------------------------------------------------------------------------------------------------
#pragma mark Advanced Querying

-(GLCompositor *)mainConnective{
    if (rootElement.isCompositor) {
        return (GLCompositor*)rootElement;
    }else return nil;
}

-(GLConnective *)mainConnective:(GLConnectiveType)type{
    if (rootElement.isConnective && ((GLConnective*)rootElement).type==type) {
        return (GLConnective*)rootElement;
    }else return nil;
}

-(GLQuantifier *)mainQuantifier:(GLQuantifierType)type{
    if (rootElement.isQuantifier && ((GLQuantifier*)rootElement).type==type) {
        return (GLQuantifier*)rootElement;
    }else return nil;
}

-(GLPrimeFormula*)primeFormula{
    if (rootElement.isPrimeFormula) {
        return (GLPrimeFormula*)rootElement;
    }else return nil;
}

-(instancetype)getDecomposition:(NSInteger)i{
    if (children && i<children.count) {
        return children[i];
    }else return nil;
}

-(instancetype)getDecompositionAtNode:(NSArray<NSNumber *> *)node{
    if (node==nil || node.count==0) {
        return self;
    }else{
        NSInteger i = node.firstObject.integerValue;
        NSArray<NSNumber*>* nextNode = [node subarrayWithRange:NSMakeRange(1, node.count-1)];
        return [children[i] getDecompositionAtNode:nextNode];
    }
}

-(BOOL)isEqual:(id)object{
    if ([object isKindOfClass:[GLFormula class]]) {
        GLFormula* f = (GLFormula*)object;
        if (![rootElement isEqual:f.rootElement]){
            return FALSE;
        }
        if (children==nil && f.children==nil){
            return TRUE;
        }
        else{
            return [children isEqualToArray:f.children];
        }
    }else return FALSE;
}


#pragma mark Building

-(void)doNegation{
    GLCompositor* mainConnective = [self mainConnective];
    if (mainConnective && mainConnective.isNegation) {
        rootElement = children[0].rootElement;
        children = children[0].children;
    }else{
        [self doNegationStrict];
    }
}

-(void)doNegationStrict{
    [self doComposition:[GLConnective makeNegation] otherForm:nil keepLeft:false];
}

/**
 * Augment the composition of the formula according to the specified parameter compositor. Also following the 'keepLeft' variable with the nilable 'otherForm' object (depending on the type of compositor)
 */
-(void)doComposition:(GLCompositor *)comp otherForm:(GLPrimeFormula *)pf keepLeft:(BOOL)left{
    GLFormula* originalChild = [[self.class alloc]init];
    [originalChild setRootElement:rootElement];
    [originalChild setChildren:children];
    
    rootElement = comp;
    
    if (pf) {
        GLFormula* addedChild = [[self.class alloc]init];
        [addedChild setRootElement:pf];
        children = left? @[originalChild, addedChild] : @[addedChild, originalChild];
    }else {
        children = @[originalChild];
    }
}
-(void)doConjunction:(GLPrimeFormula *)pf keepLeft:(BOOL)left{
    [self doComposition:[GLConnective makeConjunction] otherForm:pf keepLeft:left];
}
-(void)doDisjunction:(GLPrimeFormula *)pf keepLeft:(BOOL)left{
    [self doComposition:[GLConnective makeDisjunction] otherForm:pf keepLeft:left];
}
-(void)doConditional:(GLPrimeFormula *)pf keepLeft:(BOOL)left{
    [self doComposition:[GLConnective makeConditional] otherForm:pf keepLeft:left];
}
-(void)doBiconditional:(GLPrimeFormula *)pf keepLeft:(BOOL)left{
    [self doComposition:[GLConnective makeBiconditional] otherForm:pf keepLeft:left];
}
-(void)doQuantification:(GLQuantifier *)quant{
    [self doComposition:quant otherForm:nil keepLeft:false];
}

#pragma mark Constructing

+(instancetype)makeComposite:(GLFormula *)f1 f2:(GLFormula *)f2 comp:(GLCompositor *)comp{
    GLFormula* out = [[self alloc]init];
    out.rootElement = comp;
    if (f2 != nil) {
        out.children = @[f1.copy, f2.copy];
    }else out.children = @[f1.copy];
    return out;
}

+(instancetype)makeNegation:(GLFormula *)form{
    GLFormula* out = [form copy];
    [out doNegation];
    return out;
}
+(instancetype)makeNegationStrict:(GLFormula *)form{
    GLFormula* out = [form copy];
    [out doNegationStrict];
    return out;
}
+(instancetype)makeConjunction:(GLFormula *)f1 f2:(GLFormula *)f2{
    return [self makeComposite:f1 f2:f2 comp:[GLConnective makeConjunction]];
}
+(instancetype)makeDisjunction:(GLFormula *)f1 f2:(GLFormula *)f2{
    return [self makeComposite:f1 f2:f2 comp:[GLConnective makeDisjunction]];
}
+(instancetype)makeConditional:(GLFormula *)f1 f2:(GLFormula *)f2{
    return [self makeComposite:f1 f2:f2 comp:[GLConnective makeConditional]];
}
+(instancetype)makeBiconditional:(GLFormula *)f1 f2:(GLFormula *)f2{
    return [self makeComposite:f1 f2:f2 comp:[GLConnective makeBiconditional]];
}
+(instancetype)makeQuantification:(GLQuantifier *)quant formula:(GLFormula *)form{
    return [self makeComposite:form f2:nil comp:quant];
}


-(id)copyWithZone:(NSZone *)zone{
    GLFormula* out = [[self.class alloc]init];
    out.rootElement = rootElement.copy;
    out.children = children? [[NSArray alloc]initWithArray:children copyItems:YES]:nil;
    return out;
}




@end
