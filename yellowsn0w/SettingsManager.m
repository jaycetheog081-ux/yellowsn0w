#import "SettingsManager.h"

static NSString * const YSAccentKey = @"ys.accent";
static NSString * const YSAppearanceKey = @"ys.appearance";

@implementation SettingsManager

+ (instancetype)sharedManager {
    static SettingsManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ manager = [[SettingsManager alloc] init]; });
    return manager;
}

+ (NSArray<NSString *> *)accentColorNames {
    return @[@"Yellow", @"Blue", @"Purple", @"Green", @"Pink", @"Orange"];
}

+ (UIColor *)colorForName:(NSString *)name {
    NSDictionary *colors = @{
        @"Yellow": [UIColor colorWithRed:1.0 green:0.82 blue:0.12 alpha:1.0],
        @"Blue": [UIColor colorWithRed:0.22 green:0.52 blue:1.0 alpha:1.0],
        @"Purple": [UIColor colorWithRed:0.65 green:0.36 blue:1.0 alpha:1.0],
        @"Green": [UIColor colorWithRed:0.20 green:0.78 blue:0.48 alpha:1.0],
        @"Pink": [UIColor colorWithRed:1.0 green:0.34 blue:0.62 alpha:1.0],
        @"Orange": [UIColor colorWithRed:1.0 green:0.48 blue:0.16 alpha:1.0]
    };
    return colors[name] ?: colors[@"Yellow"];
}

- (UIColor *)accentColor {
    return [SettingsManager colorForName:[[NSUserDefaults standardUserDefaults] stringForKey:YSAccentKey] ?: @"Yellow"];
}

- (NSString *)appearance {
    return [[NSUserDefaults standardUserDefaults] stringForKey:YSAppearanceKey] ?: @"System";
}

- (void)setAccentColorName:(NSString *)name {
    [[NSUserDefaults standardUserDefaults] setObject:name forKey:YSAccentKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"YSSettingsChanged" object:nil];
}

- (void)setAppearance:(NSString *)appearance {
    [[NSUserDefaults standardUserDefaults] setObject:appearance forKey:YSAppearanceKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"YSSettingsChanged" object:nil];
}

@end
