//
//  GLDeduction(Public).m
//  GLogic
//
//  Created by Thomas Gray on 17/03/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "GLDeduction+Public.h"
#import "GLDeduction+InferenceStack.h"

@interface GLDeduction (PublicPrivate)

+(NSArray<NSString*>*)stringsForDependencies:(NSArray<GLDedNode*>*)deduction;
+(NSArray<NSString*>*)stringsForInferences:(NSArray<GLDedNode*>*)deduction;
+(NSArray<NSString*>*)stringsForFormulas:(NSArray<GLDedNode*>*)deduction;

@end

@implementation GLDeduction (Public)

//---------------------------------------------------------------------------------------------------------
//      Prove
//---------------------------------------------------------------------------------------------------------
#pragma mark Prove

/**
 *  Call this method to simultaneously set the deduction's conclusion, call proveHard: on that conclusion and tidy the deduction if proven.<p/> Returns true if the conclusion is proved, false otherwise.
 *
 *  @param conclusion The Conclusion
 *
 *  @return TRUE if proven, FALSE if not
 */
-(BOOL)prove:(GLFormula *)conclusion{
    [self setConclusion:conclusion];
    return [self prove];
}

/**
 *  Prove the conclusion. Will throw an exception at some point if the conclusion is not set
 *
 *  @return TRUE if the conclusion is proven, FALSE otherwise
 */
-(BOOL)prove{
    [self proveHard:_rootInference];
    if (_rootInference.isProven) {
        [self tidyDeductionIncludingNodes:@[_rootInference.node]];
    }
    return _rootInference.isProven;
}

//---------------------------------------------------------------------------------------------------------
//      Tidying
//---------------------------------------------------------------------------------------------------------
#pragma mark Tidying

/**
 *  Removes nodes in the deduction if the parameter formulas are not dependent on those nodes
 *
 *  @param forms The formulas to be included in the deduction (as well as their dependent nodes)
 */
-(void)tidyDeductionIncludingFormulas:(NSArray<GLFormula *> *)forms{
    NSMutableArray<GLDedNode*>* nodes = [[NSMutableArray alloc]initWithCapacity:forms.count];
    for (NSInteger i=0; i<forms.count; i++) {
        GLDedNode* node = [self findAvailableNode:forms[i]];
        if (node) [nodes addObject:node];
    }
    if (nodes.count) {
        [self tidyDeductionIncludingNodes:nodes];
    }    
}

//---------------------------------------------------------------------------------------------------------
//      To String
//---------------------------------------------------------------------------------------------------------
#pragma mark To String

/**
 *  Returns a string in the following format:
 <ul>
 <li>
 P<sub>1</sub>, ... P<sub>N</sub> ⊢ Conclusion
 </li>
 </ul>
 *
 *  @return The string sequent for this deduction
 */
-(NSString *)sequentString{
    return [GLDeduction sequentString:self.premises conclusion:self.conclusion];
}

/*!
 *  Returns a string representation of the Deduction:<p/>
    Each node in the deduction is represented on a single line as follows:<br/>
    <ol>
    <li>LINE</li>
    <li>Dependencies: {DN<sub>0</sub>,...DN<sub>N</sub>}</li>
    <li>FORMULA</li>
    <li>Inferences: IN<sub>0</sub>,...IN<sub>N</sub>: INFERENCE</li>
    </ol>
 *  Subproofs are indented by 3 spaces.
 *
 *  @return The String representation of the deduction
 */
-(NSString *)toString{
    NSMutableString* out = [[NSMutableString alloc]init];
    NSArray<GLDedNode*>* linearSequence = self.sequence;
    NSArray<NSString*>* dependencies = [GLDeduction stringsForDependencies:linearSequence];
    NSArray<NSString*>* formulas = [GLDeduction stringsForFormulas:linearSequence];
    NSArray<NSString*>* inferences = [GLDeduction stringsForInferences:linearSequence];
    for (NSInteger i=0; i<linearSequence.count; i++) {
        NSString* lineString = [[NSString stringWithFormat:@"%ld", i+1]stringByPaddingToLength:5 withString:@" " startingAtIndex:0];
        NSString* depString = dependencies[i];
        NSString* formula = formulas[i];
        NSString* inference = inferences[i];
        [out appendFormat:@"%@%@%@%@", lineString, depString, formula, inference];
        if (i<linearSequence.count-1) [out appendString:@"\n"];
    }
    return out;
}



-(NSString *)description{
    return [NSString stringWithFormat:@"%@\n%@",[GLDeduction sequentString:self.premises conclusion:self.conclusion], [self toString]];
}

/*!
 *  For each Node in the parameter deduction, returns a string in the form:<br/>
 *  '1,...N: Inference Rule'<br/>
 *  Or alternatively<br/>
 *  'Inference Rule'<br/>
 *  If no inference nodes are present
 *
 *  @param deduction The deduction
 *
 *  @return Array of string representation of the inference: listing the inference numbers as well as specifying the inference rule
 */
+(NSArray<NSString *> *)stringsForInferences:(NSArray<GLDedNode *> *)deduction{
    NSMutableArray<NSString*>* out = [[NSMutableArray alloc]initWithCapacity:deduction.count];
    NSInteger maxLength = 0;
    for (NSInteger i=0; i<deduction.count; i++) {
        GLDedNode* node = deduction[i];
        NSMutableString* str = [[NSMutableString alloc]init];
        if (node.inferenceNodes.count) {
            for (NSInteger j=0; j<node.inferenceNodes.count; j++) {
                GLDedNode* infNode = node.inferenceNodes[j];
                NSInteger infLine = [deduction indexOfObjectIdenticalTo:infNode]+1;
                if (infLine<1) infLine = 0;
                if (j<node.inferenceNodes.count-1) {
                    [str appendFormat:@"%ld,", infLine];
                }else [str appendFormat:@"%ld: ", infLine];
            }
        }
        [str appendString:GLStringForRule(node.inferenceRule)];
        maxLength = str.length>maxLength? str.length : maxLength;
        [out addObject:[NSString stringWithString:str]];
    }
    for (NSInteger i=0; i<out.count; i++) {
        NSString* str = out[i];
        str = [str stringByPaddingToLength:maxLength withString:@" " startingAtIndex:0];
        out[i] = str;
    }
    return out;
}

/*!
 *  Returns an array, mapped 1-1 to the parameter array, of String representations of the parameter formulas.<p/> Each formula is mapped to its <code>description:</code> function.
 *
 *  @param deduction The deduction
 *
 *  @return A string array representing the Formulas in the parameter deduction
 */
+(NSArray<NSString *> *)stringsForFormulas:(NSArray<GLDedNode *> *)deduction{
    NSMutableArray<NSString*>* out = [[NSMutableArray alloc]initWithCapacity:deduction.count];
    NSInteger maxLength = 0;
    for (NSInteger i=0; i<deduction.count; i++) {
        GLDedNode* node = deduction[i];
        NSString* indent = [@"" stringByPaddingToLength:node.tier*2 withString:@"| " startingAtIndex:0];
        NSString* formString = [NSString stringWithFormat:@"%@%@", indent, node.formula];
        [out addObject:formString];
        maxLength = formString.length>maxLength ? formString.length: maxLength;
        
    }
    for (NSInteger i=0; i<out.count; i++) {
        NSString* str = out[i];
        str = [str stringByPaddingToLength:maxLength+5 withString:@" " startingAtIndex:0];
        out[i] = str;
    }
    return out;
}

/*!
 *  For each node in the parameter array, returns a string representatin of the node's dependency numbers.<p/> The return array is mapped 1-1 to the parameter array.<p/>
 *  Each Dependency String is writted in the form:<br/>
 *  '{1,2...,N}'<br/>
 *  Where Nodes 1...N (indexes 0 ... N-1) are dependencies of this particular node.
 *
 *  @param deduction The DedNode array whose dependency numbers are sought
 *
 *  @return A String array, index-index mapped to the parameter array, representing the dependency numbers of each DedNode
 */
+(NSArray<NSString *> *)stringsForDependencies:(NSArray<GLDedNode *> *)deduction{
    NSMutableArray<NSString*>* out = [[NSMutableArray alloc]initWithCapacity:deduction.count];
    NSInteger maxLength = 0;
    for (NSInteger i=0; i<deduction.count; i++) {
        GLDedNode* node = deduction[i];
        NSMutableString* str = [[NSMutableString alloc]initWithString:@"{"];
        NSMutableArray<NSNumber*>* depLines = [[NSMutableArray alloc]initWithCapacity:node.dependencies.count];
        //First make array of the line numbers
        for (NSInteger j=0; j<node.dependencies.count; j++) {
            GLDedNode* dep = node.dependencies[j];
            NSUInteger lineNumber = [deduction indexOfObjectIdenticalTo:dep];
            lineNumber = (lineNumber==NSNotFound)? 0: lineNumber+1;
            [depLines addObject:[NSNumber numberWithInteger:lineNumber]];
        }
        
        //order the array
        [depLines sortUsingSelector:@selector(compare:)];
        
        //then convert to string
        for (NSInteger j=0; j<depLines.count; j++) {
            [str appendFormat:@"%@", depLines[j]];
            if (j<depLines.count-1) [str appendString:@","];
        }
        
        [str appendString:@"}"];
        maxLength = str.length>maxLength? str.length : maxLength;
        [out addObject:str];
    }
    for (NSInteger i=0; i<out.count; i++) {
        NSString* str = out[i];
        str = [str stringByPaddingToLength:maxLength+1 withString:@" " startingAtIndex:0];
        out[i] = str;
    }
    return out;
}

/*!
 *  Returns a string in the form of "P<sub>0</sub>, ... P<sub>N</sub> ⊢ Conclusion" given premises P<sub>0</sub> to P<sub>N</sub> and Conclusion. If no premises are specified, the string "∅ ⊢ Conclusion" is returned. 
 
    @warning Non-Nullable conclusion parameter
 *
 *  @param premises The premises
 *  @param conc     The conclusion
 *
 *  @return "P<sub>0</sub>, ... P<sub>N</sub> ⊢ Conclusion"
 */
+(NSString *)sequentString:(NSArray<GLFormula *> *)premises conclusion:(GLFormula *)conc{
    NSMutableString* out = [[NSMutableString alloc]init];
    if (!premises.count) {
        [out appendString:@"∅ ⊢ "];
    }else{
        for (NSInteger i=0; i<premises.count; i++) {
            GLFormula* prem = premises[i];
            [out appendString:prem.description];
            if (i<premises.count-1) [out appendString:@", "];
            else [out appendString:@" ⊢ "];
        }
    }
    if (conc) {
        [out appendString:conc.description];
    }
    
    return [NSString stringWithString:out];
}


@end
