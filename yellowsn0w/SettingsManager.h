#import <UIKit/UIKit.h>

@interface SettingsManager : NSObject
+ (instancetype)sharedManager;
@property (nonatomic, strong, readonly) UIColor *accentColor;
@property (nonatomic, copy, readonly) NSString *appearance;
- (void)setAccentColorName:(NSString *)name;
- (void)setAppearance:(NSString *)appearance;
+ (NSArray<NSString *> *)accentColorNames;
+ (UIColor *)colorForName:(NSString *)name;
@end
