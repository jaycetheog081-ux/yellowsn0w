#import "CapabilityChecker.h"
#import "DeviceInfo.h"
#import <UIKit/UIKit.h>
#import <sys/stat.h>

@implementation CapabilityChecker

+ (NSArray<NSDictionary<NSString *,NSString *> *> *)capabilityReport {
    NSString *version = DeviceInfo.systemVersion;
    BOOL alternateIcons = [UIApplication.sharedApplication respondsToSelector:@selector(setAlternateIconName:completionHandler:)];
    struct stat st;
    BOOL jailbreakMarker = (stat("/var/jb", &st) == 0) || (stat("/Applications/Cydia.app", &st) == 0);
    return @[
        @{@"name": @"Device information", @"status": @"Available", @"detail": @"Read through public iOS APIs."},
        @{@"name": @"Theme storage", @"status": @"Available", @"detail": @"Themes are stored inside the app sandbox."},
        @{@"name": @"Alternate app icons", @"status": alternateIcons ? @"API available" : @"Unavailable", @"detail": @"Requires alternate icon assets declared by the app."},
        @{@"name": @"System-wide UI changes", @"status": @"Restricted", @"detail": @"An ordinary app cannot change protected system interface elements."},
        @{@"name": @"Enhanced environment", @"status": jailbreakMarker ? @"Marker detected" : @"Not detected", @"detail": @"A marker check is not proof of jailbreak status or usable privileges."},
        @{@"name": @"OS version", @"status": version, @"detail": @"Feature support must be checked individually at runtime."}
    ];
}
@end
