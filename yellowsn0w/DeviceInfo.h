#import <Foundation/Foundation.h>

@interface DeviceInfo : NSObject
+ (NSString *)deviceModel;
+ (NSString *)systemVersion;
+ (NSString *)systemName;
+ (NSString *)appVersion;
+ (NSDictionary<NSString *, NSString *> *)summary;
@end
