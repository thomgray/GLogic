//
//  GLFormula(Operations).m
//  GLogic
//
//  Created by Thomas Gray on 16/03/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "GLFormula(Operations).h"

@interface GLFormula (OperationsPrivate)

-(void)recursivePerformBlock:(void(^)(GLFormula* comp))block;
-(void)recursivePerformSelector:(SEL)selector;

@end

@implementation GLFormula (Operations)

-(void)recursivePerformBlock:(void (^)(GLFormula *))block{
    block(self);
    if (self.children) {
        for (NSInteger i=0; i<self.children.count; i++) {
            [self.children[i] recursivePerformBlock:block];
        }
    }
}

-(void)recursivePerformSelector:(SEL)selector{
    [self performSelector:selector];
    if (self.children) {
        for (NSInteger i=0; i<self.children.count; i++) {
            [self.children[i] recursivePerformSelector:selector];
        }
    }
}

-(instancetype)removeBiconditionals{
    GLFormula* out = [self copy];
    [out recursivePerformBlock:^(GLFormula *comp) {
        GLCompositor* conn= comp.mainConnective;
        if (conn && conn.isBiconditional) {
            GLFormula* ant = [comp getDecomposition:0];
            GLFormula* cons = [comp getDecomposition:1];
            GLFormula* conjunct1 = [self.class makeConditional:ant f2:cons];
            GLFormula* conjunct2 = [self.class makeConditional:cons f2:ant];
            [comp setChildren:@[conjunct1, conjunct2]];
            [comp setRootElement:[GLConnective makeConjunction]];
        }
    }];
    return out;
}


/**
 * Produces a truth-functionally equivalent formula by replacing occurences of the <code>oldConnective</code> with <code>newConnective</code> types.
    <p/>These must allow for a functionally complete set of connectives, hence only:
    <ul>
        <li><code>GLConnectiveType_Conjunction</code></li>
        <li><code>GLConnectiveType_Disjunction</code></li>
        <li><code>GLConnectiveType_Conditional</code></li>
    </ul>
    may be specified. If any other is specified, the method will return a simple copy of the present formula;
 * @return instancetype: a truth-functionally equivalent formula of the current formula, eliminating the parameter <code>oldConnective</code> type, replacing with the <code>newConnective</code> type
 */
-(instancetype)replace:(GLConnectiveType)oldConnective with:(GLConnectiveType)newConnective{
    GLFormula* out;
    if (oldConnective==GLConnectiveType_Conditional) {
        out = [self removeBiconditionals];
    }else out = [self copy];
    
    void (^block)(GLFormula* comp);
    switch (oldConnective) {
        case GLConnectiveType_Disjunction:
            switch (newConnective) {
                case GLConnectiveType_Conjunction:
                    // PvQ = ~(~P & ~Q)
                    block = ^void(GLFormula* f){
                        GLCompositor* conn = [f mainConnective];
                        if (conn && conn.isDisjunction) {
                            GLFormula* left = [f getDecomposition:0];
                            GLFormula* right = [f getDecomposition:1];
                            [left doNegation];
                            [right doNegation];
                            [f setChildren:@[left, right]];
                            [f setRootElement:[GLConnective makeConjunction]];
                            [f doNegation];
                        }
                    };
                    break;
                case GLConnectiveType_Conditional:
                    // PvQ = ~P->Q
                    block = ^void(GLFormula* f){
                        GLCompositor* conn = [f mainConnective];
                        if (conn && conn.isDisjunction) {
                            GLFormula* left = [f getDecomposition:0];
                            GLFormula* right = [f getDecomposition:1];
                            [left doNegation];
                            [f setChildren:@[left, right]];
                            [f setRootElement:[GLConnective makeConditional]];
                        }
                    };
                    break;
                default:
                    break;
            }
            break;
        case GLConnectiveType_Conjunction:
            switch (newConnective) {
                case GLConnectiveType_Conditional:
                    // P&Q = ~(P->~Q)
                    block = ^void(GLFormula* f){
                        GLCompositor* conn = [f mainConnective];
                        if (conn && conn.isConjunction) {
                            GLFormula* left = [f getDecomposition:0];
                            GLFormula* right = [f getDecomposition:1];
                            [right doNegation];
                            [f setChildren:@[left, right]];
                            [f setRootElement:[GLConnective makeConditional]];
                            [f doNegation];
                        }
                    };
                    break;
                case GLConnectiveType_Disjunction:
                    // P&Q = ~(~Pv~Q)
                    block = ^void(GLFormula* f){
                        GLCompositor* conn = [f mainConnective];
                        if (conn && conn.isConjunction) {
                            GLFormula* left = [f getDecomposition:0];
                            GLFormula* right = [f getDecomposition:1];
                            [left doNegation];
                            [right doNegation];
                            [f setChildren:@[left, right]];
                            [f setRootElement:[GLConnective makeDisjunction]];
                            [f doNegation];
                        }
                    };
                    break;
                default:
                    break;
            }
            break;
        case GLConnectiveType_Conditional:
            switch (newConnective) {
                case GLConnectiveType_Disjunction:
                    // P->Q = ~PvQ
                    block = ^void(GLFormula* f){
                        GLCompositor* conn = f.mainConnective;
                        if (conn && conn.isConditional) {
                            GLFormula* ant = [f getDecomposition:0];
                            GLFormula* cons = [f getDecomposition:1];
                            [ant doNegation];
                            [f setChildren:@[ant, cons]];
                            [f setRootElement:[GLConnective makeDisjunction]];
                        }
                    };
                    break;
                case GLConnectiveType_Conjunction:
                    // P->Q = ~(P&~Q)
                    block = ^void(GLFormula* f){
                        GLCompositor* conn = f.mainConnective;
                        if (conn && conn.isConditional) {
                            GLFormula* ant = [f getDecomposition:0];
                            GLFormula* cons = [f getDecomposition:1];
                            [cons doNegation];
                            [f setRootElement:[GLConnective makeConjunction]];
                            [f setChildren:@[ant, cons]];
                            [f doNegation];
                        }
                    };
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }
    if (block) {
        [out recursivePerformBlock:block];
    }
    return out;
}

-(instancetype)restrictToConditionals{
    GLFormula* out = [self replace:GLConnectiveType_Conjunction with:GLConnectiveType_Conditional];
    return [out replace:GLConnectiveType_Disjunction with:GLConnectiveType_Conditional];
}
-(instancetype)restrictToConjunctions{
    GLFormula* out = [self replace:GLConnectiveType_Conditional with:GLConnectiveType_Conjunction];
    return [out replace:GLConnectiveType_Disjunction with:GLConnectiveType_Conjunction];
}
-(instancetype)restrictToDisjunctions{
    GLFormula* out = [self replace:GLConnectiveType_Conditional with:GLConnectiveType_Disjunction];
    return [out replace:GLConnectiveType_Conjunction with:GLConnectiveType_Disjunction];
}

@end