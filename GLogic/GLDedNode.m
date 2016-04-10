//
//  GLDedNode.m
//  GLogic
//
//  Created by Thomas Gray on 16/03/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "GLDedNode.h"

@interface GLDedNode (Private)
@end

@implementation GLDedNode

@synthesize dependencies = _deps;
@synthesize inferenceNodes = _infs;
@synthesize inferenceRule = _rule;

-(instancetype)initWithFormula:(GLFormula *)form inference:(GLInferenceRule)inf{
    self = [super init];
    if (self) {
        _rule = inf;
        _formula = form;
    }
    return self;
}

-(void)inheritDependencies:(NSArray<GLDedNode *> *)nodes{
    NSMutableArray<GLDedNode*>* deps = [[NSMutableArray alloc]init];
    for (NSInteger i=0; i<nodes.count; i++) {
        GLDedNode* node = nodes[i];
        if (!node.dependencies) continue;
        for (NSInteger j=0; j<node.dependencies.count; j++) {
            GLDedNode* dep = node.dependencies[j];
            if (![deps containsObject:dep]){
                [deps addObject:dep];
            }
        }
    }
    [self setDependencies:[[NSArray alloc]initWithArray:deps]];
}

-(void)dischargeDependency:(GLDedNode *)node{
    NSMutableArray<GLDedNode*>* newDeps = [[NSMutableArray alloc]initWithArray:_deps];
    [newDeps removeObject:node];
    _deps = [NSArray arrayWithArray:newDeps];
}

-(NSString *)description{
    return [NSString stringWithFormat:@"%@ : %@", self.formula, GLStringForRule(self.inferenceRule)];
}

-(BOOL)isEqual:(id)object{
    if ([object isKindOfClass:[GLDedNode class]]) {
        GLDedNode* otherNode = (GLDedNode*)object;
        if (![_formula isEqual:otherNode.formula]) return FALSE;
        else if (_rule!=otherNode.inferenceRule) return FALSE;
        else if (![_deps isEqualToArray:otherNode.dependencies]) return FALSE;
        else if (![_infs isEqualToArray:otherNode.inferenceNodes]) return FALSE;
        else if (!_tier==otherNode.tier) return FALSE;
        return TRUE;
    }else return FALSE;
}

//---------------------------------------------------------------------------------------------------------
//      Inferences
//---------------------------------------------------------------------------------------------------------
#pragma mark Inferences

/**
 *  Returns a GLDedNode with the parameter formula property, inference property and inference nodes. The return node also inherits dependencies from the parameter node.
 <p/>
 If the inference rule is an assumption, reiteration or premise, the <code>nodes</code> parameter should be set to nil, and the node adds itself to its dependencies.
 <p/>
 If the inference rule is a reiteration, and the node being reiterated is itself a reiteration, the node reiterates the reiteration's reiteration rather than reiterating the reiteration. How could it be simpler
 <p/>
 Is the inference rule is a conditional proof or reductio ad absurdum, the first node (which must be an assumption) is discharged before being returned. (Consequently, the return node does not include the assumption in the return node's dependencies, though does of course keep the assumption in its inference nodes).
 *
 *  @param inf   Inference Rule
 *  @param form  The Formula for the new node
 *  @param nodes The Inference nodes to the new node
 *
 *  @return GLDedNode with the parameter inference, formula and inference nodes, inheriting the dependencies of the inference nodes.
 */
+(instancetype)infer:(GLInferenceRule)inf formula:(GLFormula *)form withNodes:(NSArray<GLDedNode *> *)nodes{
    GLDedNode * out = [[GLDedNode alloc]initWithFormula:form inference:inf];
    [out inheritDependencies:nodes];
    [out setInferenceNodes:nodes];
    switch (inf) {
        case GLInference_Premise:
        case GLInference_AssumptionCP:
        case GLInference_AssumptionDE:
        case GLInference_AssumptionRAA:
            [out setDependencies:@[out]];
            break;
        case GLInference_Reiteration:
            if (nodes[0].inferenceRule==GLInference_Reiteration) {
                [out setInferenceNodes: nodes[0].inferenceNodes ];
            }
            break;
        case GLInference_ConditionalProof:
        case GLInference_ConditionalProofDE:
        case GLInference_ReductioAA:
            [out dischargeDependency:nodes.firstObject];
            break;
        case GLInference_DisjunctionElim:
            [out dischargeDependency:nodes[1]];
            [out dischargeDependency:nodes[3]];
            break;
        default:
            break;
    }
    return out;
}
//
///**
// *  Returns the DNE inference of the parameter Node. Paramater node must be a double negation. Otherwise, the method returns nil <p/>
//    <ul>
//        <li>Return node inference field is set to GLInference_DNE</li>
//        <li>Parameter node is added to the return node's inference</li>
//        <li>Return node inherits dependencies from the parameter node</li>
//    </ul>
// *
// *
// *  @param dn The DedNode to be DNE'd
// *  @return GLDedNode that is DNE to the parameter node, set to the relevant inference and dependency. Nil is parameter node is not double negation
// */
//+(instancetype)infer_DNE:(GLDedNode *)dn{
//    if (dn.formula.isDoubleNegation) {
//        GLFormula* form = [[dn.formula getDecomposition:0] getDecomposition:0];
//        return [self infer:GLInference_DNE formula:form withNodes:@[dn]];
//    }else return nil;
//}
//
///**
// *  Returns the DNI to the parameter node.
// *  <ul>
//         <li>Return node inference field is set to GLInference_DNI</li>
//         <li>Parameter node is added to the return node's inference</li>
//         <li>Return node inherits dependencies from the parameter node</li>
//    </ul>
// *  @param node The GLDedNode to be DNI'd
// *
// *  @return GLDedNode that is DNI to the parameter node, set to the relevant inference an dependency
// */
//+(instancetype)infer_DNI:(GLDedNode *)node{
//    GLFormula* negForm = [node.formula.class makeNegationStrict:node.formula];
//    negForm = [node.formula.class makeNegationStrict:negForm];
//    negForm = [node.formula.class makeNegationStrict:negForm];
//    return [self infer:GLInference_DNI formula:negForm withNodes:@[node]];
//}
//
///**
// *  Returns a Conjunction Introduction of the parameter <code>leftNode</code> and <code>rightNode</code>
// *  <ul>
//        <li>Return node inference field is set to GLInference_CI</li>
//        <li>Parameter nodes are added to the return node's inference</li>
//        <li>Return node inherits dependencies from the parameter nodes</li>
//    </ul>
// *
// *  @param leftNode  The left node
// *  @param rightNode The right node
// *
// *  @return A GLDedNode that is the conjunction of the parameter nodes, set to the relevant inference rule and dependencies
// */
//+(instancetype)infer_CI:(GLDedNode *)leftNode right:(GLDedNode *)rightNode{
//    GLFormula* form = [leftNode.formula.class makeConjunction:leftNode.formula f2:rightNode.formula];
//    return [self infer:GLInference_ConjunctionIntro formula:form withNodes:@[leftNode, rightNode]];
//}
//
///**
// *  Returns a Conjunction Elimination of the parameter node (left or right conjunct depending on the value of the <code>left</code> parameter), or nil if the parameter node is not a conjunction.
//    <ul>
//        <li>Return node inference field is set to GLInference_CE</li>
//        <li>Parameter node is added to the return node's inferences</li>
//        <li>Return node inherits dependencies from the parameter node</li>
//        <li>Return node's formula is set to the parameter nodes left conjunct if the <code>left</code> parameter is <code>TRUE</code>, and the right conjunct if the <code>left</code> parameter is set to <code>FALSE</code></li>
//    </ul>
// *
// *  @param conjunction The conjunction node to be deconstructed
// *  @param left        Specifies whether the left conjunct should be returned (TRUE = left conjunct, FALSE = right conjunct)
// *
// *  @return A GLDedNode that is the conjunction elimination of the parameter node, set to the relevant inference rule and dependencies. Returns the left conjunct if the <code>left</code> parameter is TRUE, otherwise the right conjunct is returned. If the parameter node is not a conjunction, returns nil
// */
//+(instancetype)infer_CE:(GLDedNode *)conjunction leftFormula:(BOOL)left{
//    if (conjunction.formula.isConjunction) {
//        GLFormula* form = [conjunction.formula getDecomposition:(left? 0:1)];
//        return [self infer:GLInference_ConjunctionElim formula:form withNodes:@[conjunction]];
//    }else return nil;
//}
//
//
//+(instancetype)infer_BE:(GLDedNode *)node leftToRight:(BOOL)leftToRight{
//    if (node.formula.isBiconditional) {
//        GLFormula* leftForm = [node.formula getDecomposition: (leftToRight? 0:1)];
//        GLFormula* rightForm = [node.formula getDecomposition: (leftToRight? 1:0)];
//        Class formulaClass = node.formula.class;
//        GLFormula* formula = [formulaClass makeConditional:leftForm f2:rightForm];
//        return [self infer:GLInference_BiconditionalElim formula:formula withNodes:@[node]];
//    }else return nil;
//}
//
///**
// *  Given parameter formulas:
//    <ul><li>cd1 = P->Q and </li> <li>cd2 = Q->P</li></ul> 
//    returns a biconditional introduction GLDedNode with the formula: <ul><li> P<->Q </li></ul> with the relevant inference rule and dependenciees set.<p/>
//    Returns <code>nil</code> if the parameter nodes do not validly imply a biconditional introduction.<p/>
//    Note left/right the ordering of return biconditional is equivalent to the ordering of the cd1 parameter conditional
// *
// *  @param cd1 A conditional in the form P->Q
// *  @param cd2 A conditional in the form Q->P
// *
// *  @return A biconditional GLDedNode in the form P<->Q
// */
//+(instancetype)infer_BI:(GLDedNode *)cd1 conditional2:(GLDedNode *)cd2{
//    if (cd1.formula.isConditional && cd2.formula.isConditional) {
//        GLFormula* leftFormula = [cd1.formula getDecomposition:0];
//        GLFormula* rightFormula = [cd1.formula getDecomposition:1];
//        if (![[cd2.formula getDecomposition:1] isEqual:leftFormula] ||
//            ![[cd2.formula getDecomposition:0] isEqual:rightFormula] ) {
//            return nil;
//        }
//        Class formulaClass = cd1.formula.class;
//        GLFormula* outFormula = [formulaClass makeBiconditional:leftFormula f2:rightFormula];
//        return [self infer:GLInference_BiconditionalIntro formula:outFormula withNodes:@[cd1, cd2]];
//    }else return nil;
//}
//
///**
// *  Given parameter nodes:
//    <ul><li>assumption = P</li>
//    <li>minorConc = Q</li></ul>
//    returns a conditional proof GLDedNode equivalent to:
//    <ul><li>P->Q</li></ul>
//    With the relevant inference rule and dependencies set.
//    <p>
//    The dependency of the assumption is discharged on return, but the subproof to the conclusion remains to be set.
// *
// *  @param assumption The assumption of the conditional proof
// *  @param minorConc  The minor conclusion of the conditional proof
// *
// *  @return A GLDedNode equivalent to the conditional proof the parameter assumption and minor conclusion
//    @warning The subproof to the conclusion remains to be set upon return
// */
//+(instancetype)infer_CP:(GLDedNode *)assumption minorConc:(GLDedNode *)minorConc{
//    GLFormula* outFormula = [assumption.formula.class makeConditional:assumption.formula f2:minorConc.formula];
//    GLDedNode* outNode = [self infer:GLInference_ConditionalProof formula:outFormula withNodes:@[assumption, minorConc]];
//    [outNode dischargeDependency:assumption];
//    return outNode;
//    
//}
//
//+(instancetype)infer_MP:(GLDedNode *)conditinal antecedent:(GLDedNode *)ant{
//    if (conditinal.formula.isConditional && [[conditinal.formula getDecomposition:0]isEqual:ant]) {
//        GLFormula* outForm = [conditinal.formula getDecomposition:1];
//        return [self infer:GLInference_ModusPonens formula:outForm withNodes:@[conditinal, ant]];
//    }return nil;
//}
//
//+(instancetype)infer_MT:(GLDedNode *)conditional negConsequent:(GLDedNode *)cons{
//    if (conditional.formula.isConditional) {
//        GLFormula* consequent = [conditional.formula getDecomposition:1];
//        GLFormula* negConsequent = [consequent.class makeNegationStrict:consequent];
//        if (![negConsequent isEqual:cons]) return nil;
//        GLFormula* negAntecedent = [consequent.class makeNegationStrict:[conditional.formula getDecomposition:0]];
//        return [self infer:GLInference_ModusTollens formula:negAntecedent withNodes:@[conditional, cons]];
//    }else return nil;
//}
//
///**
// *  Returns a GLDedNode disjunction, given parameters:
//    <ul><li>node.formula = P</li>
//    <li>dj2 = Q</li></ul>
//    in the form:
//    <ul><li>PvQ if <code>left=TRUE</code><br/> OR</li><li>QvP if <code>left=FALSE</code></li></ul>
// *
// *  @param node A node to be introduced to a disjunction
// *  @param dj2  A formula representing the other disjunct
// *  @param left specifies whether the node formula should be placed at the left hand side of the return disjunction
// *
// *  @return GLDedNode equivalent to the disjunction of the parameter node and the paramter formula, ordered depending on the value of the <code>left</code> parameter.
// */
//+(instancetype)infer_DI:(GLDedNode *)node otherDisjunct:(GLFormula *)dj2 keepLeft:(BOOL)left{
//    GLFormula* outFormula = [node.formula.class makeDisjunction:(left? node.formula:dj2) f2:(left? dj2:node.formula)];
//    return [self infer:GLInference_DisjunctionIntro formula:outFormula withNodes:@[node]];
//}
//
//+(instancetype)infer_DE:(GLDedNode *)disjunction conditional1:(GLDedNode *)c1 conditional2:(GLDedNode *)c2{
//    if (!disjunction.formula.isDisjunction) return nil;
//    GLFormula* leftDJ = [disjunction.formula getDecomposition:0];
//    GLFormula* rightDJ = [disjunction.formula getDecomposition:1];
//    if (!c1.formula.isConditional || !c2.formula.isConditional) return nil;
//    GLFormula* concFormula = [c1.formula getDecomposition:1];
//    if (![concFormula isEqual:[c2.formula getDecomposition:1]]) return nil;
//    GLFormula* c1Antecedent = [c1.formula getDecomposition:0];
//    GLFormula* c2Antecedent = [c2.formula getDecomposition:0];
//    if (([leftDJ isEqual:c1Antecedent] && [rightDJ isEqual:c2Antecedent]) ||
//        ([leftDJ isEqual:c2Antecedent] && [rightDJ isEqual:c1Antecedent]) ){
//        return [self infer:GLInference_DisjunctionElim formula:concFormula withNodes:@[disjunction, c1, c2]];
//    }else return nil;
//}
//
//
///**
// *  Given parameters:
//    <ul><li>assumption = P</li>
//    <li>contra = Q & ~Q OR ~Q & Q</li></ul>
//    Returns a GLDedNode in the form:
//    <ul><li>~P</li></ul> 
//    with the relevant inference rule and dependencies set. The return assumption dependency is discharged before returning.
// *
// *  @param assumption An assumption
// *  @param contra     A contradiction
// *
// *  @return The GLDedNode equivalent to a reductio ad absurdum of the assumption parameter, given the parameter contradiction. Or <code>nil</code> if RAA is not a valid inference given the parameters.
// */
//+(instancetype)infer_RAA:(GLDedNode *)assumption contradiction:(GLDedNode *)contra{
//    if (contra.formula.isConjunction) {
//        GLFormula* leftConjunct = [contra.formula getDecomposition:0];
//        GLFormula* rightConjunct = [contra.formula getDecomposition:1];
//        if ((leftConjunct.isNegation && [[leftConjunct getDecomposition:0]isEqual:rightConjunct]) ||
//            (rightConjunct.isNegation && [[rightConjunct getDecomposition:0]isEqual:leftConjunct]) ) {
//            GLFormula* concFormula = [assumption.formula.class makeNegationStrict:assumption.formula];
//            GLDedNode* concNode = [self infer:GLInference_ReductioAA formula:concFormula withNodes:@[assumption, contra]];
//            [concNode dischargeDependency:assumption];
//            return concNode;
//        }else return  nil;
//    }else return nil;
//}

@end
