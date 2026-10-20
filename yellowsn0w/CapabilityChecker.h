#import <Foundation/Foundation.h>

@interface CapabilityChecker : NSObject
+ (NSArray<NSDictionary<NSString *, NSString *> *> *)capabilityReport;
@end
