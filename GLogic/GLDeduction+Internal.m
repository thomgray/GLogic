

#import "GLDeduction+Internal.h"

@interface GLDeduction (InternalPrivate)

-(NSComparisonResult(^)(GLFormula* f1, GLFormula* f2))formulaInDeductionComparator;
-(NSString*)callFromStack:(NSArray*)stack;

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
    NSArray<GLDedNode*>* availableNodes = [self availableNodes];
    for (NSInteger i=0; i<availableNodes.count; i++) {
        if ([availableNodes[i].formula isEqual:f]) {
            return FALSE;
        }
    }
    return TRUE;
}

-(BOOL)mayAttempt:(GLInferenceRule)rule forConclusion:(GLFormula *)conclusion{
    return [_checkList mayAttempt:rule conclusion:conclusion];
}


/*!
 *  Returns an array of nodes that are available from the current tier. No side effects
 *
 *  @return The nodes availabe from the current tier
 */
-(NSArray<GLDedNode *> *)availableNodes{
    NSMutableArray<GLDedNode*>* out = [[NSMutableArray alloc]init];
    for (NSInteger i=self.sequence.count-1; i>=0; i--) {
        GLDedNode* node = self.sequence[i];
        if (node.tier<_currentTier) break; //stop if stepping down
        else if (node.tier>_currentTier) continue; //continue if stepping up
        
        [out insertObject:node atIndex:0];
        if (GLInferenceIsAssumption(node.inferenceRule)) break;
    }
    return [NSArray arrayWithArray:out];
}

/*!
 *  Returns the node with the parameter formula if it is contained in the deduction AND it is available from the current tier. If the node is found but not at the current tier, then it is reiterated into the current tier before being returned
 *
 *  @param fomula The formula in question
 *
 *  @return The node with the parameter formula in the deduction within the scope of the current tier
 */
-(GLDedNode *)findAvailableNode:(GLFormula *)fomula{
    NSArray<GLDedNode*>* availableNode = [self availableNodes];
    for (NSInteger i=0; i<availableNode.count; i++) {
        GLDedNode* node = availableNode[i];
        if ([node.formula isEqual:fomula]) {
            return node;
        }
    }
    return nil;
}

-(NSArray<GLDedNode *> *)availableNodesWithCriterion:(GLDedNodeCriterion)criterion{
    NSArray<GLDedNode*>* nodes = [self availableNodes];
    NSMutableArray<GLDedNode*>* out = [[NSMutableArray alloc]init];
    for (NSInteger i=0; i<nodes.count; i++) {
        GLDedNode* node = nodes[i];
        if (criterion(node)) {
            [out addObject:node];
        }
    }
    return out;
}


/**
 *  Returns the index of the next node to be added, i.e: @c self.sequence.count. Hence this is not the index of any existing node.
 *
 *  @return Index of the next node in the sequence
 */
-(GLDeductionIndex)currentIndex{
    return self.sequence.count;
}

//---------------------------------------------------------------------------------------------------------
//      Adding / Modifying
//---------------------------------------------------------------------------------------------------------
#pragma mark Adding / Modifying

-(void)stepUp{
    _currentTier++;
}

-(void)stepDown{
    _currentTier--;
}

/**
 *  Appends the parameter node to the end of the sequence. <p/>
 Side effects:
 <ul>
 <li>The tier of the parameter node is set to the current tier</li>
 <li>The checklist is reset of dynamic restrictions</li>
 <li>If the inference closes a subproof, the deduction steps down</li>
 </ul>
 *
 *  @param node The node to be appended
 */
-(void)appendNode:(GLDedNode *)node{
    switch (node.inferenceRule) {
        case GLInference_ConditionalProof:
        case GLInference_ConditionalProofDE:
        case GLInference_DisjunctionElim:
        case GLInference_ReductioAA:
            [self stepDown];
        default:
            break;
    }
    [node setTier:_currentTier];
    [self.sequence addObject:node];
    [_checkList resetList];
}

/**
 *  Removes all nodes in the sequence from the parameter node (inclusively).<p/> As a side effect, the current tier is set to the tier of the last node in the sequence.
 *
 *  @param node The node from which the sequence is to be chopped
 */
-(void)removeNodesFrom:(GLDedNode *)node{
    NSInteger i = [self.sequence indexOfObjectIdenticalTo:node];
    if (i!=NSNotFound) {
        [self.sequence removeObjectsInRange:NSMakeRange(i, self.sequence.count-i)];
        _currentTier = self.sequence.lastObject.tier;
    }else @throw [NSException exceptionWithName:@"Node not in sequence" reason:nil userInfo:nil];
}

/**
 *  Removes all nodes in the sequence from and including the parameter index. The @c _currentTier property is then set to the tier of the new last node in the sequence
 *
 *  @param index The index from which to chop the sequence (inclusively)
 */
-(void)removeNodesFromIndex:(GLDeductionIndex)index{
    NSInteger length = self.sequence.count - index;
    [self.sequence removeObjectsInRange:NSMakeRange(index, length)];
    _currentTier = self.sequence.lastObject.tier;
}

-(NSString *)callFromStack:(NSArray *)stack{
    for (NSInteger i=1; i<stack.count; i++) {
        NSString* call = stack[i];
        NSRange rngOpen = [call rangeOfString:@"["];
        NSRange rngClose = [call rangeOfString:@"]"];
        NSString* callString = [call substringWithRange:NSMakeRange(rngOpen.location+1, rngClose.location-rngOpen.location-1)];
        callString = [callString componentsSeparatedByString:@" "].lastObject;
        if ([callString containsString:@"infer_"]) {
            return callString;
        }
    }
    return nil;
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
 *  Reiterates the parameter node:
 <ul>
 <li>If the node's tier == the current tier, the parameter node is returned with no effect</li>
 <li>Otherwise, a new node is appended to the sequence equal to the reiteration of the parameter node</li>
 </ul>
 *
 *  @param node The node to be reiterated
 *
 *  @return The reiteration node, or parameter node if reiteration is not necessary
 */
//-(GLDedNode *)reiterate:(GLDedNode *)node{
//    if (node.tier==_currentTier) {
//        return node;
//    }else{
//        GLDedNode* reiteration = [GLDedNode infer:GLInference_Reiteration formula:node.formula withNodes:@[node]];
//        [self appendNode:reiteration];
//        return reiteration;
//    }
//}

-(void)subProofWithAssumption:(GLDedNode *)assumption{
    NSArray<GLDedNode*>* nodes = [self availableNodes];
    [self stepUp];
    [self appendNode:assumption];
    for (NSInteger i=0; i<nodes.count; i++) {
        GLDedNode* reiteration = [GLDedNode infer:GLInference_Reiteration formula:nodes[i].formula withNodes:@[nodes[i]]];
        [self appendNode:reiteration];
    }
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
            [self.sequence addObject:node];
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
    NSMutableArray<GLDedNode*>* newSequence= [[NSMutableArray alloc]init];
    for (NSInteger i=self.sequence.count-1; i>=0; i--) {
        GLDedNode* node = self.sequence[i];
        if ([retainList indexOfObjectIdenticalTo:node]!=NSNotFound) {
            [newSequence insertObject:node atIndex:0];
            [retainList addObjectsFromArray:node.inferenceNodes];
        }
    }
    [self setSequence:newSequence];
}


-(instancetype)tempProof{
    GLDeduction* out = [[self.class alloc]init];
    [out setLogger:self.logger];
    
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

//---------------------------------------------------------------------------------------------------------
//      Formula Decompositions
//---------------------------------------------------------------------------------------------------------
#pragma mark Formula Decompositions

-(NSComparisonResult (^)(GLFormula *, GLFormula *))formulaInDeductionComparator{
    return ^(GLFormula* f1, GLFormula* f2){
        if ([self containsFormula:f1] && ![self containsFormula:f2]) {
            return NSOrderedAscending;
        }else if (![self containsFormula:f1] && [self containsFormula:f2]){
            return NSOrderedDescending;
        }
        
        NSInteger f1nodes = [f1 getAllDecompositions].count;
        NSInteger f2nodes = [f2 getAllDecompositions].count;
        
        if (f1nodes>f2nodes) return NSOrderedDescending;
        else if (f1nodes<f2nodes) return NSOrderedAscending;
        else return NSOrderedSame;

    };
}

-(NSMutableSet<GLFormula *> *)allFormulaDecompositions{
    NSMutableSet<GLFormula*>* out = [[NSMutableSet alloc]init];
    for (NSInteger i=0; i<self.sequence.count; i++) {
        [out unionSet:[self.sequence[i].formula getAllDecompositions]];
    }
    return out;
}

-(NSMutableSet<GLFormula *> *)allFormulaDecompositionsIncludingConclusion{
    NSMutableSet<GLFormula*>* out = [self allFormulaDecompositions];
    [out unionSet:[self.conclusion getAllDecompositions]];
    return out;
}

-(NSArray<GLFormula *> *)formulasForReductio{
    NSMutableSet<GLFormula*>* prems = [NSMutableSet setWithSet:[GLDeduction getAllFormulaDecompositions:self.premises]];
    [prems unionSet:[self.conclusion getAllDecompositions]];
    prems = [prems subsetWithScheme:^BOOL(GLFormula *object) {
        return !object.isNegation;
    }];
    NSArray<GLFormula*>* formulaArray = [prems allObjects];
    return [formulaArray sortedArrayUsingComparator:[self formulaInDeductionComparator]];
}

-(NSArray<GLFormula *> *)formulasForMPWithConclusion:(GLFormula *)conclusion{
    NSMutableSet<GLFormula*>* set = [self allFormulaDecompositions];
    set = [set subsetWithScheme:^BOOL(GLFormula *object) {
        return object.isConditional && [object.secondDecomposition isEqual:conclusion];
    }];
    NSArray<GLFormula*>* out = set.allObjects;
    return [out sortedArrayUsingComparator:[self formulaInDeductionComparator]];
}

-(NSArray<GLFormula *> *)formulasForCEWithConclusion:(GLFormula *)conclusion{
    NSMutableSet<GLFormula*>* set = [self allFormulaDecompositions];
    set = [set subsetWithScheme:^BOOL(GLFormula *object) {
        return object.isConjunction && ([conclusion isEqual:object.firstDecomposition] || [conclusion isEqual:object.secondDecomposition]);
    }];
    NSArray<GLFormula*>* out = set.allObjects;
    return [out sortedArrayUsingComparator:[self formulaInDeductionComparator]];
}

-(NSArray<GLFormula *> *)formulasForDE{
    NSMutableSet<GLFormula*>* set = [self allFormulaDecompositions];
    set = [set subsetWithScheme:^BOOL(GLFormula *object) {
        return object.isDisjunction;
    }];
    return [set.allObjects sortedArrayUsingComparator:[self formulaInDeductionComparator]];
}

@end
