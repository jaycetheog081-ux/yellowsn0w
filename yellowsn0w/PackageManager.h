#import <Foundation/Foundation.h>

@interface PackageManager : NSObject
+ (instancetype)sharedManager;
- (void)exportDictionary:(NSDictionary *)dictionary filename:(NSString *)filename completion:(void (^)(NSURL * _Nullable url, NSError * _Nullable error))completion;
@end
