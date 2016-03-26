//
//  SampleFormulas.h
//  GLogic
//
//  Created by Thomas Gray on 20/03/2016.
//  Copyright © 2016 Thomas Gray. All rights reserved.
//

#import <GLogic/GLogic.h>
#import "CustomFormula.h"

@interface SampleFormulas : NSObject

+(CustomFormula*)P;
+(CustomFormula*)Q;
+(CustomFormula*)R;
+(CustomFormula*)S;

+(CustomFormula*)nnP;
+(CustomFormula*)PaQ;
+(CustomFormula*)PvQ;
+(CustomFormula*)PbQ;
+(CustomFormula*)PcQ;
+(CustomFormula*)nP;

+(CustomFormula*)RcS;
+(CustomFormula*)RaS;





@end
