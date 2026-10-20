#import "PackageManager.h"

@implementation PackageManager
+ (instancetype)sharedManager {
    static PackageManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ manager = [[PackageManager alloc] init]; });
    return manager;
}
- (void)exportDictionary:(NSDictionary *)dictionary filename:(NSString *)filename completion:(void (^)(NSURL *, NSError *))completion {
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&error];
    if (!data) { completion(nil, error); return; }
    NSString *safeName = filename.length ? filename : @"yellowsn0w-package.json";
    NSURL *url = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:safeName]];
    if (![data writeToURL:url options:NSDataWritingAtomic error:&error]) { completion(nil, error); return; }
    completion(url, nil);
}
@end
