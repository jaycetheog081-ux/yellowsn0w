#import "ThemeManager.h"

static NSString * const YSThemesKey = @"ys.savedThemes";

@implementation ThemeManager

+ (instancetype)sharedManager {
    static ThemeManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ manager = [[ThemeManager alloc] init]; });
    return manager;
}

- (NSArray<NSDictionary *> *)themes {
    NSArray *saved = [[NSUserDefaults standardUserDefaults] arrayForKey:YSThemesKey];
    if (saved) return saved;
    return @[
        @{@"name": @"Midnight", @"hex": @"#11131A"},
        @{@"name": @"Solar", @"hex": @"#FFD21C"},
        @{@"name": @"Frost", @"hex": @"#A7D8FF"}
    ];
}

- (void)persist:(NSArray *)themes {
    [[NSUserDefaults standardUserDefaults] setObject:themes forKey:YSThemesKey];
}

- (void)saveThemeNamed:(NSString *)name hexColor:(NSString *)hexColor {
    NSString *cleanName = [name stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (cleanName.length == 0 || hexColor.length == 0) return;
    NSMutableArray *updated = [self.themes mutableCopy];
    [updated addObject:@{@"name": cleanName, @"hex": hexColor}];
    [self persist:updated];
}

- (void)deleteThemeAtIndex:(NSUInteger)index {
    NSMutableArray *updated = [self.themes mutableCopy];
    if (index < updated.count) {
        [updated removeObjectAtIndex:index];
        [self persist:updated];
    }
}

- (void)exportThemesWithCompletion:(void (^)(NSURL *, NSError *))completion {
    NSData *data = [NSJSONSerialization dataWithJSONObject:self.themes options:NSJSONWritingPrettyPrinted error:nil];
    if (!data) {
        completion(nil, [NSError errorWithDomain:@"yellowsn0w" code:1 userInfo:@{NSLocalizedDescriptionKey: @"Could not serialize themes."}]);
        return;
    }
    NSURL *url = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"yellowsn0w-themes.json"]];
    NSError *error = nil;
    [data writeToURL:url options:NSDataWritingAtomic error:&error];
    completion(error ? nil : url, error);
}

- (void)importThemesFromURL:(NSURL *)url completion:(void (^)(BOOL, NSError *))completion {
    BOOL scoped = [url startAccessingSecurityScopedResource];
    NSError *error = nil;
    NSData *data = [NSData dataWithContentsOfURL:url options:0 error:&error];
    if (scoped) [url stopAccessingSecurityScopedResource];
    if (!data) { completion(NO, error); return; }
    id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (![object isKindOfClass:NSArray.class]) {
        completion(NO, error ?: [NSError errorWithDomain:@"yellowsn0w" code:2 userInfo:@{NSLocalizedDescriptionKey: @"Theme file must contain a JSON array."}]);
        return;
    }
    NSMutableArray *valid = [NSMutableArray array];
    for (id item in (NSArray *)object) {
        if ([item isKindOfClass:NSDictionary.class] && [item[@"name"] isKindOfClass:NSString.class] && [item[@"hex"] isKindOfClass:NSString.class]) {
            [valid addObject:@{@"name": item[@"name"], @"hex": item[@"hex"]}];
        }
    }
    [self persist:valid];
    completion(YES, nil);
}
@end
