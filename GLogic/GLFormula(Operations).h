//
//  GLFormula(Operations).h
//  GLogic
//
//  Created by Thomas Gray on 16/03/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import "GLFormula.h"

/*! Block returning BOOL for a paramter GLFormula object
 */
typedef BOOL(^GLFormulaCriterion)(GLFormula* formula);

@interface GLFormula (Operations) 

-(instancetype)restrictToConjunctions;
-(instancetype)restrictToDisjunctions;
-(instancetype)restrictToConditionals;
-(instancetype)restrictToUniversalQuantifiers;
-(instancetype)restrictToExistentialQuantifiers;

-(instancetype)removeBiconditionals;
-(instancetype)replace:(GLConnectiveType)oldConnective with:(GLConnectiveType)newConnective;

@end