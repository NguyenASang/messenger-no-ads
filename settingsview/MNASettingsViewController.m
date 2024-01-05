#import "MNASettingsViewController.h"
#import "TOInsetGroupedTableView.h"
#import "UtilityFunctions.h"

@implementation MNASettingsViewController

- (instancetype)initWithFrame:(CGRect)frame isDarkMode:(BOOL)isDarkMode {
    self = [super init];
    if (self) {
        self.isDarkMode = isDarkMode;

        self.title = @"Messenger No Ads";
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:LOC(@"APPLY") style:UIBarButtonItemStyleDone target:self action:@selector(close)];

        self.navigationItem.titleView = [UIView new];
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        titleLabel.font = [UIFont boldSystemFontOfSize:17];
        titleLabel.text = @"Messenger No Ads";
        titleLabel.textColor = self.isDarkMode ? [UIColor whiteColor] : [UIColor blackColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.navigationItem.titleView addSubview:titleLabel];

        [NSLayoutConstraint activateConstraints:@[
            [titleLabel.topAnchor constraintEqualToAnchor:self.navigationItem.titleView.topAnchor],
            [titleLabel.leadingAnchor constraintEqualToAnchor:self.navigationItem.titleView.leadingAnchor],
            [titleLabel.trailingAnchor constraintEqualToAnchor:self.navigationItem.titleView.trailingAnchor],
            [titleLabel.bottomAnchor constraintEqualToAnchor:self.navigationItem.titleView.bottomAnchor],
        ]];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // set switches color
    [UISwitch appearanceWhenContainedInInstancesOfClasses:@[self.class]].onTintColor = colorWithHexString(@"#B787FF");

    // set original settings so we can deal with changes later
    originalSettings = [MNAUtil getCurrentSettingsFromPlist];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setShadowImage:nil];
    [self.navigationController.navigationBar setTitleTextAttributes:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // init table view
    CGRect tableFrame = self.view.frame;
    _tableView = [[TOInsetGroupedTableView alloc] initWithFrame:tableFrame isDarkMode:YES];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    _tableView.backgroundColor = self.isDarkMode ? colorWithHexString(@"#000000") : colorWithHexString(@"#EFEFF4");
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:_tableView];
    [NSLayoutConstraint activateConstraints:@[
        [_tableView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [_tableView.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
        [_tableView.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
        [_tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];

    // setup table image header
    headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    headerImageView.contentMode = (IS_iPAD || self.view.bounds.size.width > self.view.bounds.size.height) ? UIViewContentModeScaleAspectFit : UIViewContentModeScaleAspectFill;
    headerImageView.translatesAutoresizingMaskIntoConstraints = NO;
    headerImageView.image = IMAGE(@"Banner");
    headerImageView.clipsToBounds = YES;

    [headerView addSubview:headerImageView];
    [NSLayoutConstraint activateConstraints:@[
        [headerImageView.topAnchor constraintEqualToAnchor:headerView.topAnchor],
        [headerImageView.leadingAnchor constraintEqualToAnchor:headerView.leadingAnchor],
        [headerImageView.trailingAnchor constraintEqualToAnchor:headerView.trailingAnchor],
        [headerImageView.bottomAnchor constraintEqualToAnchor:headerView.bottomAnchor],
    ]];

    _tableView.tableHeaderView = headerView;

    // setup table rows
    [self initTableData];
}

- (void)initTableData {
    tableData = [@[] mutableCopy];

    MNACellModel *mainPreferencesCell = [[MNACellModel alloc] initWithType:StaticText withLabel:@" " withSubtitle:[LOC(@"MAIN_PREFERENCES") uppercaseString]];
    MNACellModel *noAdsSwitchCell = [[MNACellModel alloc] initWithType:Switch withLabel:LOC(@"NO_ADS")];
    noAdsSwitchCell.prefKey = @"noads";
    noAdsSwitchCell.defaultValue = @"true";
    MNACellModel *disableReadReceiptSwitchCell = [[MNACellModel alloc] initWithType:Switch withLabel:LOC(@"DISABLE_READ_RECEIPT")];
    disableReadReceiptSwitchCell.prefKey = @"disablereadreceipt";
    disableReadReceiptSwitchCell.defaultValue = @"true";
    MNACellModel *disableTypingIndicatorSwitchCell = [[MNACellModel alloc] initWithType:Switch withLabel:LOC(@"DISABLE_TYPING_INDICATOR")];
    disableTypingIndicatorSwitchCell.prefKey = @"disabletypingindicator";
    disableTypingIndicatorSwitchCell.defaultValue = @"true";
    MNACellModel *disableStorySeenReceiptSwitchCell = [[MNACellModel alloc] initWithType:Switch withLabel:LOC(@"DISABLE_STORY_SEEN_RECEIPT")];
    disableStorySeenReceiptSwitchCell.prefKey = @"disablestoryseenreceipt";
    disableStorySeenReceiptSwitchCell.defaultValue = @"true";
    MNACellModel *canSaveFriendsStorySwitchCell = [[MNACellModel alloc] initWithType:Switch withLabel:LOC(@"CAN_SAVE_FRIENDS_STORY")];
    canSaveFriendsStorySwitchCell.prefKey = @"cansavefriendsstory";
    canSaveFriendsStorySwitchCell.defaultValue = @"true";
    MNACellModel *hideSearchBarSwitchCell = [[MNACellModel alloc] initWithType:Switch withLabel:LOC(@"HIDE_SEARCH_BAR")];
    hideSearchBarSwitchCell.prefKey = @"hidesearchbar";
    hideSearchBarSwitchCell.defaultValue = @"false";
    hideSearchBarSwitchCell.isRestartRequired = TRUE;

    MNACellModel *hideStoriesRowSwitchCell = [[MNACellModel alloc] initWithType:Switch withLabel:LOC(@"HIDE_STORIES_ROW")];
    hideStoriesRowSwitchCell.prefKey = @"hidestoriesrow";
    hideStoriesRowSwitchCell.defaultValue = @"false";
    MNACellModel *hidePeopleTabSwitchCell = [[MNACellModel alloc] initWithType:Switch withLabel:LOC(@"HIDE_PEOPLE_TAB")];
    hidePeopleTabSwitchCell.prefKey = @"hidepeopletab";
    hidePeopleTabSwitchCell.defaultValue = @"false";
    hidePeopleTabSwitchCell.isRestartRequired = TRUE;
    MNACellModel *hideSuggestedContactInSearch = [[MNACellModel alloc] initWithType:Switch withLabel:LOC(@"HIDE_SUGGESTED_CONTACT_IN_SEARCH")];
    hideSuggestedContactInSearch.prefKey = @"hideSuggestedContactInSearch";
    hideSuggestedContactInSearch.defaultValue = @"false";
    hideSuggestedContactInSearch.isRestartRequired = TRUE;

    MNACellModel *extendStoryVideoUploadLengthSwitchCell = [[MNACellModel alloc] initWithType:Switch withLabel:LOC(@"EXTEND_STORY_VIDEO_UPLOAD_LENGTH")];
    extendStoryVideoUploadLengthSwitchCell.prefKey = @"extendStoryVideoUploadLength";
    extendStoryVideoUploadLengthSwitchCell.defaultValue = @"true";

    MNACellModel *otherPreferencesCell = [[MNACellModel alloc] initWithType:StaticText withLabel:@" " withSubtitle:[LOC(@"OTHER_PREFERENCES") uppercaseString]];
    MNACellModel *showTheEyeButtonSwitchCell = [[MNACellModel alloc] initWithType:Switch withLabel:LOC(@"SHOW_THE_EYE_BUTTON") withSubtitle:LOC(@"QUICK_ENABLE_DISABLE_READ_RECEIPT")];
    showTheEyeButtonSwitchCell.prefKey = @"showTheEyeButton";
    showTheEyeButtonSwitchCell.defaultValue = @"true";
    showTheEyeButtonSwitchCell.isRestartRequired = TRUE;
    MNACellModel *resetSettingsButtonCell = [[MNACellModel alloc] initWithType:Button withLabel:LOC(@"RESET_SETTINGS")];
    resetSettingsButtonCell.buttonAction = @selector(resetSettings);

    MNACellModel *supportMeCell = [[MNACellModel alloc] initWithType:StaticText withLabel:@" " withSubtitle:[LOC(@"SUPPORT_ME") uppercaseString]];
    MNACellModel *haoNguyenCell = [[MNACellModel alloc] initWithType:Link withLabel:@"Hao Nguyen 👨🏻‍💻" withSubtitle:@"@haoict"];
    haoNguyenCell.url = @"https://twitter.com/haoict";
    MNACellModel *donationCell = [[MNACellModel alloc] initWithType:Link withLabel:LOC(@"DONATION") withSubtitle:LOC(@"BUY_ME_A_COFFEE")];
    donationCell.url = @"https://paypal.me/haoict";
    MNACellModel *featureRequestCell = [[MNACellModel alloc] initWithType:Link withLabel:LOC(@"FEATURE_REQUEST") withSubtitle:LOC(@"SEND_ME_AN_EMAIL_WITH_YOUR_REQUEST")];
    featureRequestCell.url = @"mailto:hao.ict56@gmail.com?subject=Messenger%20No%20Ads%20Feature%20Request";
    MNACellModel *sourceCodeCell = [[MNACellModel alloc] initWithType:Link withLabel:LOC(@"SOURCE_CODE") withSubtitle:@"Github"];
    sourceCodeCell.url = @"https://github.com/haoict/messenger-no-ads";
    MNACellModel *foundABugCell = [[MNACellModel alloc] initWithType:Link withLabel:LOC(@"FOUND_A_BUG") withSubtitle:LOC(@"LEAVE_A_BUG_REPORT_ON_GITHUB")];
    foundABugCell.url = @"https://github.com/haoict/messenger-no-ads/issues/new";

    MNACellModel *emptyCell = [[MNACellModel alloc] initWithType:StaticText withLabel:@" "];
    MNACellModel *footerCell = [[MNACellModel alloc] initWithType:StaticText withLabel:@"Messenger No Ads, made with 💖"];

    [tableData addObject:mainPreferencesCell];
    [tableData addObject:noAdsSwitchCell];
    [tableData addObject:disableReadReceiptSwitchCell];
    [tableData addObject:disableTypingIndicatorSwitchCell];
    [tableData addObject:disableStorySeenReceiptSwitchCell];
    [tableData addObject:canSaveFriendsStorySwitchCell];
    [tableData addObject:hideSearchBarSwitchCell];
    [tableData addObject:hideStoriesRowSwitchCell];
    [tableData addObject:hidePeopleTabSwitchCell];
    [tableData addObject:hideSuggestedContactInSearch];
    [tableData addObject:extendStoryVideoUploadLengthSwitchCell];

    [tableData addObject:otherPreferencesCell];
    [tableData addObject:showTheEyeButtonSwitchCell];
    [tableData addObject:resetSettingsButtonCell];

    [tableData addObject:supportMeCell];
    [tableData addObject:haoNguyenCell];
    [tableData addObject:donationCell];
    [tableData addObject:featureRequestCell];
    [tableData addObject:sourceCodeCell];
    [tableData addObject:foundABugCell];

    [tableData addObject:emptyCell];
    [tableData addObject:footerCell];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    // [_tableView reloadData];
    headerImageView.contentMode = (IS_iPAD || self.view.bounds.size.width > self.view.bounds.size.height) ? UIViewContentModeScaleAspectFit : UIViewContentModeScaleAspectFill;
}

- (void)close {
    BOOL isRestartRequired = FALSE;
    NSMutableDictionary *newSettings = [MNAUtil getCurrentSettingsFromPlist];

    // get diff from original settings with new settings
    NSDictionary *diff = [MNAUtil compareNSDictionary:originalSettings withNSDictionary:newSettings];
    // get all keys array from diff
    NSArray *diffAllKeys = [diff allKeys];

    if ([diffAllKeys count] > 0) {
        // check if changed keys has isRestartRequired
        for (NSString *key in diffAllKeys) {
            for (MNACellModel *cellModel in tableData) {
                if ([key isEqualToString:cellModel.prefKey] && cellModel.isRestartRequired) {
                    isRestartRequired = TRUE;
                }
            }
        }
    }

    if (isRestartRequired) {
        // show restart required alert
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:LOC(@"APP_RESTART_REQUIRED") message:LOC(@"DO_YOU_REALLY_WANT_TO_KILL_MESSENGER") preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:LOC(@"CONFIRM") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            exit(0);
        }]];

        [alert addAction:[UIAlertAction actionWithTitle:LOC(@"CANCEL") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    tableView.tableHeaderView = headerView;
    MNACellModel *cellData = [tableData objectAtIndex:indexPath.row];

    NSString *cellIdentifier = [NSString stringWithFormat:@"MNATableViewCell-type%lu-title%@-subtitle%@", cellData.type, cellData.label, cellData.subtitle];
    MNATableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[MNATableViewCell alloc] initWithData:cellData reuseIdentifier:cellIdentifier isDarkMode:self.isDarkMode];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MNACellModel *cellData = [tableData objectAtIndex:indexPath.row];
    if (cellData.type == Link) {
        UIApplication *app = [UIApplication sharedApplication];
        [app openURL:[NSURL URLWithString:cellData.url] options:@{} completionHandler:nil];
    }

    if (cellData.type == Button) {
        SEL selector = cellData.buttonAction;
        IMP imp = [self methodForSelector:selector];
        void (*func)(id, SEL) = (void *)imp;
        func(self, selector);
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    });
}

- (void)resetSettings {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Are you sure?" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
        NSString *plistPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@PLIST_FILENAME];
        [@{} writeToFile:plistPath atomically:YES];
        //[tableView reloadData];
        notify_post(PREF_CHANGED_NOTIF);
        exit(0);
    }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:confirmAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
