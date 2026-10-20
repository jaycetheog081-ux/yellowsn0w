#import <UIKit/UIKit.h>

@interface ThemeManager : NSObject
+ (instancetype)sharedManager;
@property (nonatomic, copy, readonly) NSArray<NSDictionary *> *themes;
- (void)saveThemeNamed:(NSString *)name hexColor:(NSString *)hexColor;
- (void)deleteThemeAtIndex:(NSUInteger)index;
- (void)exportThemesWithCompletion:(void (^)(NSURL * _Nullable url, NSError * _Nullable error))completion;
- (void)importThemesFromURL:(NSURL *)url completion:(void (^)(BOOL success, NSError * _Nullable error))completion;
@end
