
#import "GLDeduction.h"

@interface LogEvent : NSObject

@property NSDictionary<NSString*, id>* info;
@property GLDeduction* deduction;

+(instancetype)eventWithDeduction:(GLDeduction*)deduction info:(NSDictionary<NSString*, id>*)info;
+(NSArray<NSString*>*)establishedKeys;

@end