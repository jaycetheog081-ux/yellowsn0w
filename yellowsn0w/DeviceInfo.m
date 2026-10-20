#import "DeviceInfo.h"
#import <UIKit/UIKit.h>
#import <sys/utsname.h>

@implementation DeviceInfo

+ (NSString *)deviceModel {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *identifier = [NSString stringWithUTF8String:systemInfo.machine];
    NSDictionary *models = @{
        @"iPhone14,5": @"iPhone 13",
        @"iPhone14,7": @"iPhone 14",
        @"iPhone15,2": @"iPhone 14 Pro",
        @"iPhone15,4": @"iPhone 15",
        @"iPhone16,1": @"iPhone 15 Pro",
        @"iPad13,18": @"iPad (10th generation)",
        @"iPad14,8": @"iPad Air 11-inch (M2)"
    };
    return models[identifier] ?: identifier;
}

+ (NSString *)systemVersion { return UIDevice.currentDevice.systemVersion ?: @"Unknown"; }
+ (NSString *)systemName { return UIDevice.currentDevice.systemName ?: @"iOS"; }

+ (NSString *)appVersion {
    return [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"] ?: @"1.0";
}

+ (NSDictionary<NSString *,NSString *> *)summary {
    return @{
        @"Device": self.deviceModel,
        @"System": [NSString stringWithFormat:@"%@ %@", self.systemName, self.systemVersion],
        @"App Version": self.appVersion
    };
}
@end
