

#import "GLDeduction(Internal).h"

@interface GLDeduction (InternalPrivate)

-(void)recursiveTidyDeduction:(NSMutableArray<GLDedNode*>*)retainList;

@end

#pragma mark
@implementation GLDeduction (Internal)

-(GLDeductionCheckList *)checkList{
    return _checkList;
}
-(void)setCheckList:(GLDeductionCheckList *)checkList{
    _checkList = checkList;
}

//---------------------------------------------------------------------------------------------------------
//      Querying
//---------------------------------------------------------------------------------------------------------
#pragma mark Querying

-(BOOL)isInformedBy:(GLFormula *)f{
    return ![self containsFormula:f];
}

-(BOOL)mayAttempt:(GLInferenceRule)rule forConclusion:(GLFormula *)conclusion{
    return [_checkList mayAttempt:rule conclusion:conclusion];
}

//---------------------------------------------------------------------------------------------------------
//      Adding / Modifying
//---------------------------------------------------------------------------------------------------------
#pragma mark Adding / Modifying

-(void)appendNode:(GLDedNode *)node{
    //NSLog(@"Appended: %@", node);
    [self.sequence addObject:node];
    [_checkList resetList];
}

/**
    Appends reiterations of the parameter nodes to this array. New GLDedNode instances are created for each node with identical formulas and <code>GLInference_Reiteration</code> inference rules. The inference nodes of the reiterations are the nodes which they reiterate.<p/>
    To be called on creating a subproof
    _text_
    I am adding this line, then I will build this project. If this is updated int he appledoc then I know something is going right in the build rules
    @sa subProofWithAssumption:
 *
 *  @param reiteration The nodes to be reiterated
 */
-(void)addReiteration:(NSArray<GLDedNode *> *)reiteration{
    for (NSInteger i=0; i<reiteration.count; i++) {
        GLDedNode* node = reiteration[i];
        GLDedNode* reiteration = [GLDedNode infer:GLInference_Reiteration formula:node.formula withNodes:@[node]];
        [self appendNode:reiteration];
    }
}


/**
 Appends the specified conclusion to the deduction so long as the conclusion is informative.
 <p/>
 If the conclusion informative?
    <ul>
        <li>YES</li>
            <ul>
            <li>Creates a new DedNode with the parameter conclusion, inference rule and dependencies</li>
            <li>Appends the new node to the deduction</li>
            <li>returns the new node</li>
            </ul>
        <li>NO</li>
            <ul><li>returns nil</li></ul>
    </ul>
 * @param conc The conclusion to infer
 * @param rule The inference rule
 * @param nodes The dependencies to the conclusion
 * @return GLDedNode * <br/>The new node that has been added to the deduction, or nil if the conclusion was not inferred
 */
-(GLDedNode*)append:(GLFormula*)conc rule:(GLInferenceRule)rule dependencies:(NSArray<GLDedNode*>*)nodes{
    if ([self isInformedBy:conc]) {
        GLDedNode* node = [GLDedNode infer:rule formula:conc withNodes:nodes];
        [self appendNode:node];
        return node;
    }else return nil;
}

/*!
 Adds the nodes in the parameter deduction to this one starting at the specified index. Nodes are added only if they are not already present in the deduction sequence. <p/>
 This method should be used when doing a temporary deduction. If that deduction is successful, tidy the deduction so that it only includes the necessary steps to the conclusion, then assimilate using this method. <p/>
 When initialising deductions for temporary proofs, do not initialise with <code>subproofWithAssumption:</code>, instead, copy the present deduction sequence to the temporary deduction, and go from there.
 */
-(void)assimilateDeduction:(GLDeduction *)deduction fromLine:(NSInteger)line{
    for (NSInteger i=line; i<deduction.sequence.count; i++) {
        GLDedNode* node = deduction.sequence[i];
        if (![self.sequence containsObject:node]) {
            [self appendNode:node];
        }
    }
}

/**
 *  Iterates backwards through the deduction, retaining only nodes that:
 <ul><li>Are contained in the parameter <code>nodes</code> array <br/>OR</li>
 <li>Are included in the inference nodes of any retained node</li></ul>
 *
 *  @param nodes The nodes to be retained by the deduction
 */
-(void)tidyDeductionIncludingNodes:(NSArray<GLDedNode *> *)nodes{
    NSMutableArray<GLDedNode*>* retainList = [[NSMutableArray alloc]initWithArray:nodes];
    [self recursiveTidyDeduction:retainList];
}

/**
 *  Iterates backward through the deduction and includes only those DedNodes in the parameter <code>retailList</code>. If a node is to be included in the deduction, the inference nodes to that node are appended to the retain list.<p/>
    Should a node contain a subproof, the method is called on that proof, passing the present retail list to that method call, and hence (potentially) augmenting the retainList with nodes from any sub proof.<p/>
    This is carried out to the beginning of the deduction. <p/> This implies that an empty retail list is guaranteed to remove all objects from the deduction.
 *
 *  @param retainList A mutable array containing the nodes that are to be retained in the trimmed deduction
 */
-(void)recursiveTidyDeduction:(NSMutableArray<GLDedNode *> *)retainList{
    NSMutableArray<GLDedNode*>* newSequence = [[NSMutableArray alloc]init];
    for (NSInteger i=self.sequence.count-1; i>=0; i--) {
        GLDedNode* node = self.sequence[i];
        if ([retainList indexOfObjectIdenticalTo:node]!=NSNotFound) {
            [newSequence insertObject:node atIndex:0];
            [retainList addObjectsFromArray:node.inferenceNodes];
            if (node.subProof) {
                [node.subProof recursiveTidyDeduction:retainList];
            }
        }
    }
    [self setSequence:newSequence];
}

/**
 *  Creates a new subproof beginning with the specified assumptions and reiterating all formulas contained in this deduction
 *
 *  @param assumption The assumption with which to begin the subproof
 *
 *  @return GLDeduction subproof to this proof with the specified assumption
 */
-(instancetype)subProofWithAssumption:(GLDedNode *)assumption{
    GLDeduction* out = [[self.class alloc]init];
    [out setPremises:self.premises];
    [out setConclusion:self.conclusion];
    if (assumption) [out appendNode:assumption];
    [out addReiteration:self.sequence];
    [out.checkList setDERestrictions:[NSMutableSet setWithSet:_checkList.DERestrictions]];
    [out.checkList setTempRestrictions:[NSMutableSet setWithSet:_checkList.tempRestrictions]];
    [out setTier:self.tier+1];
    return out;
}

-(instancetype)tempProof{
    GLDeduction* out = [[self.class alloc]init];
    [out setPremises:self.premises];
    [out setConclusion:self.conclusion];
    [out setSequence:[NSMutableArray arrayWithArray:self.sequence]];
    [out setCheckList:[_checkList copy]];
    return out;
}

//---------------------------------------------------------------------------------------------------------
//      Formula Sets
//---------------------------------------------------------------------------------------------------------
#pragma mark Formula Sets

/*! 
 Returns all formula decompositions in the deduction. As well as the conclusion decompositions if specified, and their negations if specified.
    @param includeNegations whether to include the negations of the formulas in the return set
    @param includeConclusion whether to include the conclusion decompositions in the return set
    @return the set of all formula decompositions in the deduction (as well as the conclusion & negations if specified)
 */
-(NSSet<GLFormula *> *)getAllFormulaDecompositions_includingNegations:(BOOL)includeNegations includingConclusion:(BOOL)includeConclusion{
    NSMutableSet<GLFormula*>* out = [[NSMutableSet alloc]init];
    for (NSInteger i=0; i<self.sequence.count; i++) {
        GLDedNode* node = self.sequence[i];
        [out unionSet:[node.formula getAllDecompositions]];
    }
    if (includeConclusion && self.conclusion) {
        [out unionSet:[self.conclusion getAllDecompositions]];
    }
    if (includeNegations) {
        NSArray<GLFormula*>* allForms = [out allObjects];
        for (NSInteger i=0; i<allForms.count; i++) {
            GLFormula* f = allForms[i];
            GLFormula* negF = [f.class makeNegationStrict:f];
            [out addObject:negF];
        }
    }
    return [NSSet setWithSet:out];
}

/*!
 *  For a specified array of formulas, returns a set of all decompositions
 *
 *  @param formulas The array of formulas
 *
 *  @return NSSet<GLFormula*>* of all decompositions of the parameter formula array
 */
+(NSSet<GLFormula *> *)getAllFormulaDecompositions:(NSArray<GLFormula *> *)formulas{
    NSMutableSet<GLFormula*>* out = [[NSMutableSet alloc]init];
    for (NSInteger i=0; i<formulas.count; i++) {
        GLFormula* form = formulas[i];
        [out unionSet:[form getAllDecompositions]];
    }
    return [NSSet setWithSet:out];
}
/*!
 *  Returns a set representing the union of the parameter formulas set with the set of their strict negations:
 <ul>
 <li>For any formula P in the parameter set:</li>
 <li>{P, ~P} is included in the return set</li>
 </ul>
 *
 *  @param formulas The set of formulas
 *
 *  @return NSSet<GLFormula*>* union of the parameter formulas as well as their (strict) negations
 */
+(NSSet<GLFormula *> *)getAllFormulasAndTheirNegations:(NSSet<GLFormula *> *)formulas{
    NSMutableSet<GLFormula*>* out = [[NSMutableSet alloc]initWithSet:formulas];
    NSArray<GLFormula*>* allForms = [out allObjects];
    for (NSInteger i=0; i<allForms.count; i++) {
        GLFormula* f = allForms[i];
        GLFormula* negF = [f.class makeNegationStrict:f];
        [out addObject:negF];
    }
    return [NSSet setWithSet:out];
}

-(NSSet<GLFormula *> *)getAllFormulaDecompositions{
    NSMutableSet<GLFormula*>* out = [[NSMutableSet alloc]init];
    for (NSInteger i=0; i<self.sequence.count; i++) {
        GLDedNode* node = self.sequence[i];
        [out unionSet:[node.formula getAllDecompositions]];
    }
    return [NSSet setWithSet:out];
}

-(NSSet<GLFormula *> *)getAllFormulaDecompositionsAndTheirNegations{
    NSSet<GLFormula*>* out = [self getAllFormulaDecompositions];
    return [GLDeduction getAllFormulasAndTheirNegations:out];
}

-(NSArray<GLFormula *> *)formulasForReductio{
    NSMutableSet<GLFormula*>* prems = [NSMutableSet setWithSet:[GLDeduction getAllFormulaDecompositions:self.premises]];
    [prems unionSet:[self.conclusion getAllDecompositions]];
    prems = [prems subsetWithScheme:^BOOL(GLFormula *object) {
        return !object.isNegation;
    }];
    NSArray<GLFormula*>* formulaArray = [prems allObjects];
    formulaArray = [formulaArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSInteger f1nodes = [(GLFormula*)obj1 getAllDecompositions].count;
        NSInteger f2nodes = [(GLFormula*)obj2 getAllDecompositions].count;
        
        if (f1nodes>f2nodes) return NSOrderedDescending;
        else if (f1nodes<f2nodes) return NSOrderedAscending;
        else return NSOrderedSame;
    }];
    return formulaArray;    
}

@end
