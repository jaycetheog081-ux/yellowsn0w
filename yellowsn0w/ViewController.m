#import "ViewController.h"
#import "DeviceInfo.h"
#import "ThemeManager.h"
#import "SettingsManager.h"
#import "CapabilityChecker.h"
#import "PackageManager.h"
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

@interface ViewController () <UITableViewDataSource, UITableViewDelegate, UIDocumentPickerDelegate>
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIStackView *stack;
@property (nonatomic, strong) UILabel *pageTitle;
@property (nonatomic, strong) NSString *selectedTab;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.selectedTab = @"Home";
    self.view.backgroundColor = [UIColor secondarySystemBackgroundColor];
    [self buildInterface];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsChanged) name:@"YSSettingsChanged" object:nil];
}

- (void)dealloc { [[NSNotificationCenter defaultCenter] removeObserver:self]; }

- (void)settingsChanged {
    if ([SettingsManager.sharedManager.appearance isEqualToString:@"Dark"]) self.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;
    else if ([SettingsManager.sharedManager.appearance isEqualToString:@"Light"]) self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    else self.overrideUserInterfaceStyle = UIUserInterfaceStyleUnspecified;
    [self buildInterface];
}

- (void)buildInterface {
    [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UIColor *accent = SettingsManager.sharedManager.accentColor;
    self.view.backgroundColor = UIColor.systemBackgroundColor;

    UIView *header = [[UIView alloc] init];
    header.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:header];

    UILabel *brand = [[UILabel alloc] init];
    brand.text = @"yellowsn0w";
    brand.font = [UIFont systemFontOfSize:28 weight:UIFontWeightBlack];
    brand.translatesAutoresizingMaskIntoConstraints = NO;
    [header addSubview:brand];

    UILabel *subtitle = [[UILabel alloc] init];
    subtitle.text = @"MAKE iOS YOURS";
    subtitle.font = [UIFont systemFontOfSize:10 weight:UIFontWeightBold];
    subtitle.textColor = accent;
    subtitle.translatesAutoresizingMaskIntoConstraints = NO;
    [header addSubview:subtitle];

    UISegmentedControl *tabs = [[UISegmentedControl alloc] initWithItems:@[@"Home", @"Themes", @"Tools", @"Settings"]];
    tabs.selectedSegmentIndex = [@[@"Home", @"Themes", @"Tools", @"Settings"] indexOfObject:self.selectedTab];
    tabs.translatesAutoresizingMaskIntoConstraints = NO;
    [tabs addTarget:self action:@selector(tabChanged:) forControlEvents:UIControlEventValueChanged];
    [header addSubview:tabs];

    UIScrollView *scroll = [[UIScrollView alloc] init];
    scroll.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:scroll];
    UIStackView *stack = [[UIStackView alloc] init];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 14;
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    [scroll addSubview:stack];

    [NSLayoutConstraint activateConstraints:@[
        [header.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:10],
        [header.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [header.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [brand.topAnchor constraintEqualToAnchor:header.topAnchor],
        [brand.leadingAnchor constraintEqualToAnchor:header.leadingAnchor],
        [subtitle.topAnchor constraintEqualToAnchor:brand.bottomAnchor constant:1],
        [subtitle.leadingAnchor constraintEqualToAnchor:brand.leadingAnchor],
        [tabs.topAnchor constraintEqualToAnchor:subtitle.bottomAnchor constant:18],
        [tabs.leadingAnchor constraintEqualToAnchor:header.leadingAnchor],
        [tabs.trailingAnchor constraintEqualToAnchor:header.trailingAnchor],
        [tabs.bottomAnchor constraintEqualToAnchor:header.bottomAnchor],
        [scroll.topAnchor constraintEqualToAnchor:header.bottomAnchor constant:18],
        [scroll.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [scroll.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [scroll.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
        [stack.topAnchor constraintEqualToAnchor:scroll.contentLayoutGuide.topAnchor constant:4],
        [stack.leadingAnchor constraintEqualToAnchor:scroll.frameLayoutGuide.leadingAnchor constant:20],
        [stack.trailingAnchor constraintEqualToAnchor:scroll.frameLayoutGuide.trailingAnchor constant:-20],
        [stack.bottomAnchor constraintEqualToAnchor:scroll.contentLayoutGuide.bottomAnchor constant:-20]
    ]];

    self.scrollView = scroll;
    self.stack = stack;
    if ([self.selectedTab isEqualToString:@"Home"]) [self showHome];
    else if ([self.selectedTab isEqualToString:@"Themes"]) [self showThemes];
    else if ([self.selectedTab isEqualToString:@"Tools"]) [self showTools];
    else [self showSettings];
}

- (void)tabChanged:(UISegmentedControl *)sender {
    self.selectedTab = @[@"Home", @"Themes", @"Tools", @"Settings"][sender.selectedSegmentIndex];
    [self buildInterface];
}

- (UIView *)cardWithTitle:(NSString *)title subtitle:(NSString *)subtitle symbol:(NSString *)symbol {
    UIView *card = [[UIView alloc] init];
    card.backgroundColor = UIColor.secondarySystemBackgroundColor;
    card.layer.cornerRadius = 18;
    card.layer.borderWidth = 1;
    card.layer.borderColor = UIColor.separatorColor.CGColor;
    card.translatesAutoresizingMaskIntoConstraints = NO;
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:symbol]];
    icon.tintColor = SettingsManager.sharedManager.accentColor;
    icon.translatesAutoresizingMaskIntoConstraints = NO;
    UILabel *heading = [[UILabel alloc] init];
    heading.text = title;
    heading.font = [UIFont systemFontOfSize:17 weight:UIFontWeightBold];
    heading.translatesAutoresizingMaskIntoConstraints = NO;
    UILabel *detail = [[UILabel alloc] init];
    detail.text = subtitle;
    detail.font = [UIFont systemFontOfSize:13];
    detail.textColor = UIColor.secondaryLabelColor;
    detail.numberOfLines = 0;
    detail.translatesAutoresizingMaskIntoConstraints = NO;
    [card addSubview:icon]; [card addSubview:heading]; [card addSubview:detail];
    [NSLayoutConstraint activateConstraints:@[
        [card.heightAnchor constraintGreaterThanOrEqualToConstant:94],
        [icon.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:16],
        [icon.topAnchor constraintEqualToAnchor:card.topAnchor constant:18],
        [icon.widthAnchor constraintEqualToConstant:26],
        [icon.heightAnchor constraintEqualToConstant:26],
        [heading.leadingAnchor constraintEqualToAnchor:icon.trailingAnchor constant:12],
        [heading.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-14],
        [heading.topAnchor constraintEqualToAnchor:card.topAnchor constant:16],
        [detail.leadingAnchor constraintEqualToAnchor:heading.leadingAnchor],
        [detail.trailingAnchor constraintEqualToAnchor:heading.trailingAnchor],
        [detail.topAnchor constraintEqualToAnchor:heading.bottomAnchor constant:5],
        [detail.bottomAnchor constraintLessThanOrEqualToAnchor:card.bottomAnchor constant:-14]
    ]];
    return card;
}

- (void)addSectionTitle:(NSString *)title {
    UILabel *label = [[UILabel alloc] init];
    label.text = title.uppercaseString;
    label.font = [UIFont systemFontOfSize:11 weight:UIFontWeightHeavy];
    label.textColor = UIColor.secondaryLabelColor;
    [self.stack addArrangedSubview:label];
}

- (void)addAction:(NSString *)title detail:(NSString *)detail symbol:(NSString *)symbol action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:[NSString stringWithFormat:@"%@   ›", title] forState:UIControlStateNormal];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    [button setImage:[UIImage systemImageNamed:symbol] forState:UIControlStateNormal];
    button.tintColor = SettingsManager.sharedManager.accentColor;
    button.backgroundColor = UIColor.secondarySystemBackgroundColor;
    button.layer.cornerRadius = 14;
    button.contentEdgeInsets = UIEdgeInsetsMake(15, 15, 15, 15);
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [self.stack addArrangedSubview:button];
    if (detail.length) {
        UILabel *hint = [[UILabel alloc] init];
        hint.text = detail;
        hint.font = [UIFont systemFontOfSize:12];
        hint.textColor = UIColor.secondaryLabelColor;
        hint.numberOfLines = 0;
        [self.stack addArrangedSubview:hint];
    }
}

- (void)showHome {
    [self addSectionTitle:@"Your device"];
    NSDictionary *info = DeviceInfo.summary;
    for (NSString *key in info) {
        [self.stack addArrangedSubview:[self cardWithTitle:key subtitle:info[key] symbol:[key isEqualToString:@"Device"] ? @"iphone" : ([key isEqualToString:@"System"] ? @"gearshape.2" : @"app.badge")]];
    }
    [self addSectionTitle:@"Customize"];
    [self.stack addArrangedSubview:[self cardWithTitle:@"Theme Studio" subtitle:@"Build and save your own color themes." symbol:@"paintpalette"]];
    [self addAction:@"Open Themes" detail:nil symbol:@"paintbrush.pointed" action:@selector(openThemes)];
    [self addAction:@"Diagnostics" detail:@"See what this iOS environment exposes to the app." symbol:@"waveform.path.ecg" action:@selector(openTools)];
}

- (void)showThemes {
    [self addSectionTitle:@"Theme studio"];
    [self addAction:@"Create a theme" detail:@"Save a named theme with a hex color." symbol:@"plus.circle" action:@selector(createTheme)];
    [self addAction:@"Export themes" detail:@"Export your theme collection as JSON." symbol:@"square.and.arrow.up" action:@selector(exportThemes)];
    [self addAction:@"Import themes" detail:@"Import a yellowsn0w theme JSON file." symbol:@"square.and.arrow.down" action:@selector(importThemes)];
    [self addSectionTitle:@"Saved themes"];
    NSArray *themes = ThemeManager.sharedManager.themes;
    [themes enumerateObjectsUsingBlock:^(NSDictionary *theme, NSUInteger idx, BOOL *stop) {
        UIView *card = [self cardWithTitle:theme[@"name"] subtitle:theme[@"hex"] symbol:@"paintpalette"];
        [self.stack addArrangedSubview:card];
        UIButton *delete = [UIButton buttonWithType:UIButtonTypeSystem];
        [delete setTitle:@"Delete theme" forState:UIControlStateNormal];
        delete.tag = idx;
        [delete addTarget:self action:@selector(deleteTheme:) forControlEvents:UIControlEventTouchUpInside];
        [self.stack addArrangedSubview:delete];
    }];
}

- (void)showTools {
    [self addSectionTitle:@"Capability diagnostics"];
    for (NSDictionary *item in CapabilityChecker.capabilityReport) {
        [self.stack addArrangedSubview:[self cardWithTitle:[NSString stringWithFormat:@"%@ · %@", item[@"name"], item[@"status"]] subtitle:item[@"detail"] symbol:@"checkmark.shield"]];
    }
    [self addSectionTitle:@"Packages"];
    [self addAction:@"Export app configuration" detail:@"Save the current theme collection to a JSON package." symbol:@"shippingbox" action:@selector(exportPackage)];
}

- (void)showSettings {
    [self addSectionTitle:@"Appearance"];
    for (NSString *name in SettingsManager.accentColorNames) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setTitle:[NSString stringWithFormat:@"●   %@", name] forState:UIControlStateNormal];
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        button.contentEdgeInsets = UIEdgeInsetsMake(12, 14, 12, 14);
        button.tintColor = [SettingsManager colorForName:name];
        button.backgroundColor = UIColor.secondarySystemBackgroundColor;
        button.layer.cornerRadius = 12;
        [button addTarget:self action:@selector(selectAccent:) forControlEvents:UIControlEventTouchUpInside];
        button.accessibilityIdentifier = name;
        [self.stack addArrangedSubview:button];
    }
    [self addSectionTitle:@"Interface style"];
    for (NSString *style in @[@"System", @"Light", @"Dark"]) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setTitle:style forState:UIControlStateNormal];
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        button.contentEdgeInsets = UIEdgeInsetsMake(12, 14, 12, 14);
        button.backgroundColor = UIColor.secondarySystemBackgroundColor;
        button.layer.cornerRadius = 12;
        button.accessibilityIdentifier = style;
        [button addTarget:self action:@selector(selectAppearance:) forControlEvents:UIControlEventTouchUpInside];
        [self.stack addArrangedSubview:button];
    }
    [self addSectionTitle:@"About"];
    [self.stack addArrangedSubview:[self cardWithTitle:@"yellowsn0w 1.0" subtitle:@"Standalone iOS customization toolkit. Features that alter protected system components require compatible privileges and are not provided by the stock app." symbol:@"snowflake"]];
}

- (void)openThemes { self.selectedTab = @"Themes"; [self buildInterface]; }
- (void)openTools { self.selectedTab = @"Tools"; [self buildInterface]; }

- (void)createTheme {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"New Theme" message:@"Enter a name and a hex color (example: #FFD21C)." preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *field) { field.placeholder = @"Theme name"; }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *field) { field.placeholder = @"#FFD21C"; field.text = @"#FFD21C"; field.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters; }];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *name = alert.textFields[0].text ?: @"";
        NSString *hex = alert.textFields[1].text ?: @"";
        if ([self isValidHex:hex] && name.length) {
            [ThemeManager.sharedManager saveThemeNamed:name hexColor:hex.uppercaseString];
            [self buildInterface];
        } else {
            [self showMessage:@"Invalid theme" message:@"Enter a name and a color in #RRGGBB format."];
        }
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (BOOL)isValidHex:(NSString *)hex {
    if (hex.length != 7 || ![hex hasPrefix:@"#"]) return NO;
    NSCharacterSet *allowed = [NSCharacterSet characterSetWithCharactersInString:@"#0123456789ABCDEFabcdef"];
    return [hex rangeOfCharacterFromSet:allowed.invertedSet].location == NSNotFound;
}

- (void)deleteTheme:(UIButton *)sender {
    [ThemeManager.sharedManager deleteThemeAtIndex:sender.tag];
    [self buildInterface];
}

- (void)exportThemes {
    [ThemeManager.sharedManager exportThemesWithCompletion:^(NSURL *url, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (url) [self presentShareSheetForURL:url];
            else [self showMessage:@"Export failed" message:error.localizedDescription ?: @"Unknown error"];
        });
    }];
}

- (void)importThemes {
    UIDocumentPickerViewController *picker;
    if (@available(iOS 14.0, *)) picker = [[UIDocumentPickerViewController alloc] initForOpeningContentTypes:@[UTTypeJSON] asCopy:YES];
    else picker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.json"] inMode:UIDocumentPickerModeImport];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    NSURL *url = urls.firstObject;
    if (!url) return;
    [ThemeManager.sharedManager importThemesFromURL:url completion:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) { [self buildInterface]; [self showMessage:@"Imported" message:@"Theme collection imported successfully."]; }
            else [self showMessage:@"Import failed" message:error.localizedDescription ?: @"Invalid theme file."];
        });
    }];
}

- (void)exportPackage {
    NSDictionary *package = @{@"format": @"yellowsn0w-theme-package", @"version": @1, @"themes": ThemeManager.sharedManager.themes};
    [[PackageManager sharedManager] exportDictionary:package filename:@"yellowsn0w-package.json" completion:^(NSURL *url, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (url) [self presentShareSheetForURL:url];
            else [self showMessage:@"Package export failed" message:error.localizedDescription ?: @"Unknown error"];
        });
    }];
}

- (void)presentShareSheetForURL:(NSURL *)url {
    UIActivityViewController *share = [[UIActivityViewController alloc] initWithActivityItems:@[url] applicationActivities:nil];
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        share.popoverPresentationController.sourceView = self.view;
        share.popoverPresentationController.sourceRect = CGRectMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2, 1, 1);
    }
    [self presentViewController:share animated:YES completion:nil];
}

- (void)selectAccent:(UIButton *)sender {
    [SettingsManager.sharedManager setAccentColorName:sender.accessibilityIdentifier ?: @"Yellow"];
}

- (void)selectAppearance:(UIButton *)sender {
    [SettingsManager.sharedManager setAppearance:sender.accessibilityIdentifier ?: @"System"];
}

- (void)showMessage:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}
@end
