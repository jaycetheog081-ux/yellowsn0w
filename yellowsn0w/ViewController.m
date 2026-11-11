#import "ViewController.h"
#import "DeviceInfo.h"
#import "ThemeManager.h"
#import "SettingsManager.h"
#import "CapabilityChecker.h"
#import "PackageManager.h"
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

@interface ViewController () <UIDocumentPickerDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIStackView *stack;
@property (nonatomic, copy) NSString *selectedTab;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.selectedTab = @"Home";
    self.view.backgroundColor = UIColor.blackColor;

    [self buildInterface];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(settingsChanged)
                                                 name:@"YSSettingsChanged"
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)settingsChanged {
    NSString *appearance = SettingsManager.sharedManager.appearance;

    if ([appearance isEqualToString:@"Dark"]) {
        self.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;
    } else if ([appearance isEqualToString:@"Light"]) {
        self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    } else {
        self.overrideUserInterfaceStyle = UIUserInterfaceStyleUnspecified;
    }

    [self buildInterface];
}

- (void)buildInterface {
    [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];

    for (CALayer *layer in [self.view.layer.sublayers copy]) {
        if ([layer.name isEqualToString:@"YSBackground"]) {
            [layer removeFromSuperlayer];
        }
    }

    UIColor *accent = SettingsManager.sharedManager.accentColor;

    // Original yellowsn0w background.
    CAGradientLayer *background = [CAGradientLayer layer];
    background.name = @"YSBackground";
    background.frame = self.view.bounds;
    background.colors = @[
        (id)[UIColor colorWithRed:0.045 green:0.060 blue:0.105 alpha:1].CGColor,
        (id)[UIColor colorWithRed:0.105 green:0.115 blue:0.165 alpha:1].CGColor,
        (id)[UIColor colorWithRed:0.025 green:0.035 blue:0.065 alpha:1].CGColor
    ];
    background.startPoint = CGPointMake(0, 0);
    background.endPoint = CGPointMake(1, 1);
    [self.view.layer insertSublayer:background atIndex:0];

    UIView *glow = [[UIView alloc] init];
    glow.translatesAutoresizingMaskIntoConstraints = NO;
    glow.backgroundColor = [accent colorWithAlphaComponent:0.09];
    glow.layer.cornerRadius = 150;
    glow.layer.shadowColor = accent.CGColor;
    glow.layer.shadowOpacity = 0.35;
    glow.layer.shadowRadius = 85;
    [self.view addSubview:glow];

    UIView *header = [[UIView alloc] init];
    header.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:header];

    UILabel *brand = [[UILabel alloc] init];
    brand.text = @"yellowsn0w";
    brand.textColor = UIColor.whiteColor;
    brand.font = [UIFont systemFontOfSize:31 weight:UIFontWeightBlack];
    brand.translatesAutoresizingMaskIntoConstraints = NO;
    [header addSubview:brand];

    UILabel *subtitle = [[UILabel alloc] init];
    subtitle.attributedText = [[NSAttributedString alloc]
        initWithString:@"iOS CUSTOMIZATION"
        attributes:@{
            NSForegroundColorAttributeName: accent,
            NSFontAttributeName: [UIFont systemFontOfSize:10 weight:UIFontWeightBold],
            NSKernAttributeName: @2.0
        }];
    subtitle.translatesAutoresizingMaskIntoConstraints = NO;
    [header addSubview:subtitle];

    UILabel *version = [[UILabel alloc] init];
    version.text = @"VERSION 1.0";
    version.textColor = [UIColor colorWithWhite:1 alpha:0.48];
    version.font = [UIFont monospacedSystemFontOfSize:10 weight:UIFontWeightMedium];
    version.translatesAutoresizingMaskIntoConstraints = NO;
    [header addSubview:version];

    UIView *status = [[UIView alloc] init];
    status.backgroundColor = [UIColor colorWithWhite:1 alpha:0.08];
    status.layer.cornerRadius = 12;
    status.translatesAutoresizingMaskIntoConstraints = NO;
    [header addSubview:status];

    UIView *dot = [[UIView alloc] init];
    dot.backgroundColor = [UIColor colorWithRed:0.35 green:0.88 blue:0.57 alpha:1];
    dot.layer.cornerRadius = 4;
    dot.translatesAutoresizingMaskIntoConstraints = NO;
    [status addSubview:dot];

    UILabel *statusLabel = [[UILabel alloc] init];
    statusLabel.text = @"READY";
    statusLabel.textColor = UIColor.whiteColor;
    statusLabel.font = [UIFont systemFontOfSize:9 weight:UIFontWeightBold];
    statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [status addSubview:statusLabel];

    UIScrollView *scroll = [[UIScrollView alloc] init];
    scroll.translatesAutoresizingMaskIntoConstraints = NO;
    scroll.showsVerticalScrollIndicator = NO;
    [self.view addSubview:scroll];

    UIStackView *stack = [[UIStackView alloc] init];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 13;
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    [scroll addSubview:stack];

    UIView *tabBar = [[UIView alloc] init];
    tabBar.backgroundColor = [UIColor colorWithWhite:1 alpha:0.075];
    tabBar.layer.cornerRadius = 18;
    tabBar.layer.borderWidth = 1;
    tabBar.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.10].CGColor;
    tabBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:tabBar];

    UIStackView *tabStack = [[UIStackView alloc] init];
    tabStack.axis = UILayoutConstraintAxisHorizontal;
    tabStack.distribution = UIStackViewDistributionFillEqually;
    tabStack.translatesAutoresizingMaskIntoConstraints = NO;
    [tabBar addSubview:tabStack];

    NSArray *names = @[@"Home", @"Themes", @"Tools", @"Settings"];
    NSArray *icons = @[
        @"house.fill",
        @"paintpalette",
        @"wrench.and.screwdriver",
        @"gearshape"
    ];

    for (NSUInteger i = 0; i < names.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];

        [button setImage:[UIImage systemImageNamed:icons[i]]
                forState:UIControlStateNormal];

        [button setTitle:[@"  " stringByAppendingString:names[i]]
                forState:UIControlStateNormal];

        button.titleLabel.font =
            [UIFont systemFontOfSize:10 weight:UIFontWeightSemibold];

        button.tintColor =
            [self.selectedTab isEqualToString:names[i]]
            ? accent
            : [UIColor colorWithWhite:1 alpha:0.52];

        button.tag = i;

        [button addTarget:self
                   action:@selector(tabButtonPressed:)
         forControlEvents:UIControlEventTouchUpInside];

        [tabStack addArrangedSubview:button];
    }

    [NSLayoutConstraint activateConstraints:@[
        [glow.widthAnchor constraintEqualToConstant:300],
        [glow.heightAnchor constraintEqualToConstant:300],
        [glow.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:130],
        [glow.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:100],

        [header.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:18],
        [header.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:24],
        [header.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-24],

        [brand.topAnchor constraintEqualToAnchor:header.topAnchor],
        [brand.leadingAnchor constraintEqualToAnchor:header.leadingAnchor],

        [subtitle.topAnchor constraintEqualToAnchor:brand.bottomAnchor constant:3],
        [subtitle.leadingAnchor constraintEqualToAnchor:brand.leadingAnchor],

        [version.centerYAnchor constraintEqualToAnchor:brand.centerYAnchor],
        [version.trailingAnchor constraintEqualToAnchor:header.trailingAnchor],

        [status.topAnchor constraintEqualToAnchor:subtitle.bottomAnchor constant:13],
        [status.leadingAnchor constraintEqualToAnchor:header.leadingAnchor],
        [status.heightAnchor constraintEqualToConstant:25],
        [status.bottomAnchor constraintEqualToAnchor:header.bottomAnchor],

        [dot.leadingAnchor constraintEqualToAnchor:status.leadingAnchor constant:9],
        [dot.centerYAnchor constraintEqualToAnchor:status.centerYAnchor],
        [dot.widthAnchor constraintEqualToConstant:8],
        [dot.heightAnchor constraintEqualToConstant:8],

        [statusLabel.leadingAnchor constraintEqualToAnchor:dot.trailingAnchor constant:7],
        [statusLabel.trailingAnchor constraintEqualToAnchor:status.trailingAnchor constant:-10],
        [statusLabel.centerYAnchor constraintEqualToAnchor:status.centerYAnchor],

        [scroll.topAnchor constraintEqualToAnchor:header.bottomAnchor constant:22],
        [scroll.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [scroll.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [scroll.bottomAnchor constraintEqualToAnchor:tabBar.topAnchor constant:-14],

        [stack.topAnchor constraintEqualToAnchor:scroll.contentLayoutGuide.topAnchor constant:4],
        [stack.leadingAnchor constraintEqualToAnchor:scroll.frameLayoutGuide.leadingAnchor constant:23],
        [stack.trailingAnchor constraintEqualToAnchor:scroll.frameLayoutGuide.trailingAnchor constant:-23],
        [stack.bottomAnchor constraintEqualToAnchor:scroll.contentLayoutGuide.bottomAnchor constant:-18],

        [tabBar.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:18],
        [tabBar.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-18],
        [tabBar.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-8],
        [tabBar.heightAnchor constraintEqualToConstant:58],

        [tabStack.leadingAnchor constraintEqualToAnchor:tabBar.leadingAnchor constant:5],
        [tabStack.trailingAnchor constraintEqualToAnchor:tabBar.trailingAnchor constant:-5],
        [tabStack.topAnchor constraintEqualToAnchor:tabBar.topAnchor constant:4],
        [tabStack.bottomAnchor constraintEqualToAnchor:tabBar.bottomAnchor constant:-4]
    ]];

    self.scrollView = scroll;
    self.stack = stack;

    if ([self.selectedTab isEqualToString:@"Home"]) {
        [self showHome];
    } else if ([self.selectedTab isEqualToString:@"Themes"]) {
        [self showThemes];
    } else if ([self.selectedTab isEqualToString:@"Tools"]) {
        [self showTools];
    } else {
        [self showSettings];
    }
}

- (void)tabButtonPressed:(UIButton *)sender {
    NSArray *names = @[@"Home", @"Themes", @"Tools", @"Settings"];

    if (sender.tag < names.count) {
        self.selectedTab = names[sender.tag];
        [self buildInterface];
    }
}

- (UIView *)cardWithTitle:(NSString *)title
                 subtitle:(NSString *)subtitle
                   symbol:(NSString *)symbol {

    UIView *card = [[UIView alloc] init];
    card.backgroundColor = [UIColor colorWithWhite:1 alpha:0.075];
    card.layer.cornerRadius = 17;
    card.layer.borderWidth = 1;
    card.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.09].CGColor;
    card.translatesAutoresizingMaskIntoConstraints = NO;

    UIImageView *icon = [[UIImageView alloc]
        initWithImage:[UIImage systemImageNamed:symbol]];

    icon.tintColor = SettingsManager.sharedManager.accentColor;
    icon.contentMode = UIViewContentModeScaleAspectFit;
    icon.translatesAutoresizingMaskIntoConstraints = NO;

    UILabel *heading = [[UILabel alloc] init];
    heading.text = title;
    heading.textColor = UIColor.whiteColor;
    heading.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    heading.translatesAutoresizingMaskIntoConstraints = NO;

    UILabel *detail = [[UILabel alloc] init];
    detail.text = subtitle;
    detail.textColor = [UIColor colorWithWhite:1 alpha:0.55];
    detail.font = [UIFont systemFontOfSize:12];
    detail.numberOfLines = 0;
    detail.translatesAutoresizingMaskIntoConstraints = NO;

    [card addSubview:icon];
    [card addSubview:heading];
    [card addSubview:detail];

    [NSLayoutConstraint activateConstraints:@[
        [card.heightAnchor constraintGreaterThanOrEqualToConstant:88],

        [icon.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:17],
        [icon.centerYAnchor constraintEqualToAnchor:card.centerYAnchor],
        [icon.widthAnchor constraintEqualToConstant:25],
        [icon.heightAnchor constraintEqualToConstant:25],

        [heading.leadingAnchor constraintEqualToAnchor:icon.trailingAnchor constant:15],
        [heading.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-15],
        [heading.topAnchor constraintEqualToAnchor:card.topAnchor constant:17],

        [detail.leadingAnchor constraintEqualToAnchor:heading.leadingAnchor],
        [detail.trailingAnchor constraintEqualToAnchor:heading.trailingAnchor],
        [detail.topAnchor constraintEqualToAnchor:heading.bottomAnchor constant:4],
        [detail.bottomAnchor constraintLessThanOrEqualToAnchor:card.bottomAnchor constant:-14]
    ]];

    return card;
}

- (void)addSectionTitle:(NSString *)title {
    UILabel *label = [[UILabel alloc] init];

    label.attributedText = [[NSAttributedString alloc]
        initWithString:title.uppercaseString
        attributes:@{
            NSForegroundColorAttributeName: [UIColor colorWithWhite:1 alpha:0.48],
            NSFontAttributeName: [UIFont systemFontOfSize:10 weight:UIFontWeightHeavy],
            NSKernAttributeName: @1.4
        }];

    [self.stack addArrangedSubview:label];
}

- (void)addAction:(NSString *)title
           detail:(NSString *)detail
           symbol:(NSString *)symbol
           action:(SEL)action {

    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];

    [button setTitle:[@"   " stringByAppendingString:title]
            forState:UIControlStateNormal];

    [button setImage:[UIImage systemImageNamed:symbol]
            forState:UIControlStateNormal];

    button.tintColor = SettingsManager.sharedManager.accentColor;
    button.backgroundColor = [UIColor colorWithWhite:1 alpha:0.10];
    button.layer.cornerRadius = 15;
    button.layer.borderWidth = 1;
    button.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.10].CGColor;
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
    button.contentEdgeInsets = UIEdgeInsetsMake(15, 16, 15, 16);

    [button addTarget:self
               action:action
     forControlEvents:UIControlEventTouchUpInside];

    [self.stack addArrangedSubview:button];

    if (detail.length) {
        UILabel *hint = [[UILabel alloc] init];
        hint.text = detail;
        hint.font = [UIFont systemFontOfSize:11];
        hint.textColor = [UIColor colorWithWhite:1 alpha:0.48];
        hint.numberOfLines = 0;
        [self.stack addArrangedSubview:hint];
    }
}

- (void)showHome {
    [self addSectionTitle:@"Your device"];

    NSDictionary *info = DeviceInfo.summary;

    for (NSString *key in info) {
        NSString *symbol =
            [key isEqualToString:@"Device"] ? @"iphone" :
            ([key isEqualToString:@"System"] ? @"gearshape.2" : @"app.badge");

        [self.stack addArrangedSubview:
            [self cardWithTitle:key subtitle:info[key] symbol:symbol]];
    }

    [self addSectionTitle:@"Customize"];

    [self.stack addArrangedSubview:
        [self cardWithTitle:@"Theme Studio"
                   subtitle:@"Create and save your own appearance themes."
                     symbol:@"paintpalette"]];

    [self addAction:@"Open Themes"
             detail:@"Manage your yellowsn0w themes."
             symbol:@"paintbrush.pointed"
             action:@selector(openThemes)];

    [self addAction:@"Diagnostics"
             detail:@"Inspect the capabilities exposed to this application."
             symbol:@"waveform.path.ecg"
             action:@selector(openTools)];
}

- (void)showThemes {
    [self addSectionTitle:@"Theme studio"];

    [self addAction:@"Create a theme"
             detail:@"Save a named theme with a custom hex color."
             symbol:@"plus.circle"
             action:@selector(createTheme)];

    [self addAction:@"Export themes"
             detail:@"Export your theme collection as JSON."
             symbol:@"square.and.arrow.up"
             action:@selector(exportThemes)];

    [self addAction:@"Import themes"
             detail:@"Import a yellowsn0w theme JSON file."
             symbol:@"square.and.arrow.down"
             action:@selector(importThemes)];

    [self addSectionTitle:@"Saved themes"];

    NSArray *themes = ThemeManager.sharedManager.themes;

    [themes enumerateObjectsUsingBlock:^(NSDictionary *theme,
                                          NSUInteger idx,
                                          BOOL *stop) {

        UIView *card = [self cardWithTitle:theme[@"name"]
                                  subtitle:theme[@"hex"]
                                    symbol:@"paintpalette"];

        [self.stack addArrangedSubview:card];

        UIButton *delete = [UIButton buttonWithType:UIButtonTypeSystem];
        [delete setTitle:@"Delete theme" forState:UIControlStateNormal];
        delete.tag = idx;

        [delete addTarget:self
                   action:@selector(deleteTheme:)
         forControlEvents:UIControlEventTouchUpInside];

        [self.stack addArrangedSubview:delete];
    }];
}

- (void)showTools {
    [self addSectionTitle:@"Capability diagnostics"];

    for (NSDictionary *item in CapabilityChecker.capabilityReport) {
        NSString *title = [NSString stringWithFormat:@"%@ · %@",
                           item[@"name"], item[@"status"]];

        [self.stack addArrangedSubview:
            [self cardWithTitle:title
                       subtitle:item[@"detail"]
                         symbol:@"checkmark.shield"]];
    }

    [self addSectionTitle:@"Packages"];

    [self addAction:@"Export app configuration"
             detail:@"Export your current theme collection."
             symbol:@"shippingbox"
             action:@selector(exportPackage)];
}

- (void)showSettings {
    [self addSectionTitle:@"Accent color"];

    for (NSString *name in SettingsManager.accentColorNames) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];

        [button setTitle:[NSString stringWithFormat:@"●   %@", name]
                forState:UIControlStateNormal];

        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        button.contentEdgeInsets = UIEdgeInsetsMake(13, 15, 13, 15);
        button.tintColor = [SettingsManager colorForName:name];
        button.backgroundColor = [UIColor colorWithWhite:1 alpha:0.08];
        button.layer.cornerRadius = 13;
        button.accessibilityIdentifier = name;

        [button addTarget:self
                   action:@selector(selectAccent:)
         forControlEvents:UIControlEventTouchUpInside];

        [self.stack addArrangedSubview:button];
    }

    [self addSectionTitle:@"Interface style"];

    for (NSString *style in @[@"System", @"Light", @"Dark"]) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];

        [button setTitle:style forState:UIControlStateNormal];
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        button.contentEdgeInsets = UIEdgeInsetsMake(13, 15, 13, 15);
        button.backgroundColor = [UIColor colorWithWhite:1 alpha:0.08];
        button.layer.cornerRadius = 13;
        button.accessibilityIdentifier = style;

        [button addTarget:self
                   action:@selector(selectAppearance:)
         forControlEvents:UIControlEventTouchUpInside];

        [self.stack addArrangedSubview:button];
    }

    [self addSectionTitle:@"About"];

    [self.stack addArrangedSubview:
        [self cardWithTitle:@"yellowsn0w 1.0"
                   subtitle:@"Standalone iOS customization toolkit."
                     symbol:@"snowflake"]];
}

- (void)openThemes {
    self.selectedTab = @"Themes";
    [self buildInterface];
}

- (void)openTools {
    self.selectedTab = @"Tools";
    [self buildInterface];
}

- (void)createTheme {
    UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:@"New Theme"
                                            message:@"Enter a name and a hex color."
                                     preferredStyle:UIAlertControllerStyleAlert];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *field) {
        field.placeholder = @"Theme name";
    }];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *field) {
        field.placeholder = @"#FFD21C";
        field.text = @"#FFD21C";
        field.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    }];

    [alert addAction:
        [UIAlertAction actionWithTitle:@"Cancel"
                                 style:UIAlertActionStyleCancel
                               handler:nil]];

    [alert addAction:
        [UIAlertAction actionWithTitle:@"Save"
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action) {

        NSString *name = alert.textFields[0].text ?: @"";
        NSString *hex = alert.textFields[1].text ?: @"";

        if ([self isValidHex:hex] && name.length) {
            [ThemeManager.sharedManager saveThemeNamed:name
                                              hexColor:hex.uppercaseString];
            [self buildInterface];
        } else {
            [self showMessage:@"Invalid theme"
                      message:@"Enter a name and a color in #RRGGBB format."];
        }
    }]];

    [self presentViewController:alert animated:YES completion:nil];
}

- (BOOL)isValidHex:(NSString *)hex {
    if (hex.length != 7 || ![hex hasPrefix:@"#"]) {
        return NO;
    }

    NSCharacterSet *allowed =
        [NSCharacterSet characterSetWithCharactersInString:
            @"#0123456789ABCDEFabcdef"];

    return [hex rangeOfCharacterFromSet:allowed.invertedSet].location == NSNotFound;
}

- (void)deleteTheme:(UIButton *)sender {
    [ThemeManager.sharedManager deleteThemeAtIndex:sender.tag];
    [self buildInterface];
}

- (void)exportThemes {
    [ThemeManager.sharedManager exportThemesWithCompletion:^(NSURL *url,
                                                              NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (url) {
                [self presentShareSheetForURL:url];
            } else {
                [self showMessage:@"Export failed"
                          message:error.localizedDescription ?: @"Unknown error"];
            }
        });
    }];
}

- (void)importThemes {
    UIDocumentPickerViewController *picker;

    if (@available(iOS 14.0, *)) {
        picker = [[UIDocumentPickerViewController alloc]
            initForOpeningContentTypes:@[UTTypeJSON]
            asCopy:YES];
    } else {
        picker = [[UIDocumentPickerViewController alloc]
            initWithDocumentTypes:@[@"public.json"]
            inMode:UIDocumentPickerModeImport];
    }

    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller
 didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {

    NSURL *url = urls.firstObject;
    if (!url) return;

    [ThemeManager.sharedManager importThemesFromURL:url
                                          completion:^(BOOL success, NSError *error) {

        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                [self buildInterface];
                [self showMessage:@"Imported"
                          message:@"Theme collection imported successfully."];
            } else {
                [self showMessage:@"Import failed"
                          message:error.localizedDescription ?: @"Invalid theme file."];
            }
        });
    }];
}

- (void)exportPackage {
    NSDictionary *package = @{
        @"format": @"yellowsn0w-theme-package",
        @"version": @1,
        @"themes": ThemeManager.sharedManager.themes
    };

    [[PackageManager sharedManager]
        exportDictionary:package
        filename:@"yellowsn0w-package.json"
        completion:^(NSURL *url, NSError *error) {

        dispatch_async(dispatch_get_main_queue(), ^{
            if (url) {
                [self presentShareSheetForURL:url];
            } else {
                [self showMessage:@"Package export failed"
                          message:error.localizedDescription ?: @"Unknown error"];
            }
        });
    }];
}

- (void)presentShareSheetForURL:(NSURL *)url {
    UIActivityViewController *share =
        [[UIActivityViewController alloc] initWithActivityItems:@[url]
                                          applicationActivities:nil];

    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        share.popoverPresentationController.sourceView = self.view;
        share.popoverPresentationController.sourceRect =
            CGRectMake(self.view.bounds.size.width / 2,
                       self.view.bounds.size.height / 2, 1, 1);
    }

    [self presentViewController:share animated:YES completion:nil];
}

- (void)selectAccent:(UIButton *)sender {
    [SettingsManager.sharedManager
        setAccentColorName:sender.accessibilityIdentifier ?: @"Yellow"];
}

- (void)selectAppearance:(UIButton *)sender {
    [SettingsManager.sharedManager
        setAppearance:sender.accessibilityIdentifier ?: @"System"];
}

- (void)showMessage:(NSString *)title message:(NSString *)message {
    UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:title
                                            message:message
                                     preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:
        [UIAlertAction actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                               handler:nil]];

    [self presentViewController:alert animated:YES completion:nil];
}

@end
