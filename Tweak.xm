#import "Tweak.h"
#import "UtilityFunctions.h"

#pragma mark - Global variables

static BOOL hasCompletedIntroduction;
static BOOL noads;
static BOOL disablereadreceipt;
static BOOL disabletypingindicator;
static BOOL disablestoryseenreceipt;
static BOOL cansavefriendsstory;
static BOOL hidesearchbar;
static BOOL hidestoriesrow;
static BOOL hidepeopletab;
static BOOL hideSuggestedContactInSearch;
static BOOL showTheEyeButton;
static BOOL extendStoryVideoUploadLength;
static NSString *plistPath;
static NSMutableDictionary *settings;

#pragma mark - Settings page

%hook MDSNavigationController

- (void)viewDidLoad {
    if ([self.navigationBar.topItem.customTitleView.accessibilityLabel isEqual:@"Settings"]) {
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:IMAGE(@"gear-icon@3x") style:UIBarButtonItemStyleDone target:self action:@selector(openSettings:)];
        self.navigationBar.topItem.customLeftItem = item;
    }
    %orig;
}

%new(v@:@)
- (void)openSettings:(id)arg1 {
    MNASettingsViewController *settings = [[MNASettingsViewController alloc] initWithFrame:[UIScreen.mainScreen bounds] isDarkMode:YES];
    [self pushViewController:settings animated:YES];
}

%end

#pragma mark - Button to quickly disable/enable read receipt

%hook MDSSplitViewController
%property (nonatomic, retain) UIView *sideSwitch;
%property (nonatomic, retain) UIImageView *imageView;

- (void)viewDidLoad {
    %orig;
    if (showTheEyeButton) {
        [self initEyeButton];
    }
}

%new
- (void)initEyeButton {
    self.sideSwitch = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 50, self.view.frame.size.height / 2 - 60, 50, 50)];
    self.sideSwitch.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.3];
    self.sideSwitch.layer.cornerRadius = 10;
    [self.sideSwitch addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSideSwitchTap:)]];
    [self.sideSwitch addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)]];

    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 30, 30)];
    self.imageView.image = disablereadreceipt ? IMAGE(@"no-see") : IMAGE(@"see");
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.alpha = 0.8;

    [self.sideSwitch addSubview:self.imageView];
    [self.view addSubview:self.sideSwitch];
}

%new
- (void)handleSideSwitchTap:(UITapGestureRecognizer *)recognizer {
    [settings setObject:[NSNumber numberWithBool:!disablereadreceipt] forKey:@"disablereadreceipt"];
    BOOL success = [settings writeToFile:plistPath atomically:YES];
    if (!success) {
        //[HCommon showAlertMessage:@"Can't write file" withTitle:@"Error" viewController:nil];
    } else {
        self.imageView.image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", @PREF_BUNDLE_PATH, !disablereadreceipt ? @"no-see" : @"see"]];
        notify_post(PREF_CHANGED_NOTIF);
    }
}

%new
- (void)move:(UIPanGestureRecognizer *)sender {
    // Thanks for this post: https://stackoverflow.com/questions/6672677/how-to-use-uipangesturerecognizer-to-move-object-iphone-ipad
    [self.view bringSubviewToFront:sender.view];
    CGPoint translatedPoint = [sender translationInView:sender.view.superview];
    translatedPoint = CGPointMake(sender.view.center.x + translatedPoint.x, sender.view.center.y + translatedPoint.y);
    [sender.view setCenter:translatedPoint];
    [sender setTranslation:CGPointZero inView:sender.view];
    if (sender.state == UIGestureRecognizerStateEnded) {
        CGFloat velocityX = (0.2 * [sender velocityInView:self.view].x);
        CGFloat velocityY = (0.2 * [sender velocityInView:self.view].y);
        CGFloat finalX = translatedPoint.x + velocityX;
        CGFloat finalY = translatedPoint.y + velocityY;
        if (finalX < self.view.frame.size.width / 2) {
            finalX = 0 + sender.view.frame.size.width / 2;
        } else {
            finalX = self.view.frame.size.width - sender.view.frame.size.width / 2;
        }
        if (finalY < 50) { // to avoid status bar
            finalY = 50;
        } else if (finalY > self.view.frame.size.height - 75) { // avoid bottom tab
            finalY = self.view.frame.size.height - 75;
        }
        CGFloat animationDuration = (ABS(velocityX) * 0.0002) + 0.2;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:animationDuration];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationDidFinish)];
        [[sender view] setCenter:CGPointMake(finalX, finalY)];
        [UIView commitAnimations];
    }
}

%end

#pragma mark - Hide suggested contacts in search

%hook LSContactListViewController

- (void)didLoadContactList:(NSArray *)list contactExtrasById:(NSDictionary *)extras {
    if (hideSuggestedContactInSearch) {
        RLog(@"class = %@", NSStringFromClass([extras class]));
        NSString *featureIdentifier = MSHookIvar<NSString *>(self, "_featureIdentifier");
        if ([featureIdentifier isEqualToString:@"universal_search_null_state"]) {
            return %orig(nil, nil);
        }
    }
    %orig;
}

%end

#pragma mark - Remove ads, stories row

%hook MSGThreadListDataSource

- (NSArray *)inboxRows {
    NSArray *rows = %orig;
    if ((!noads && !hidestoriesrow) || ![rows count]) return rows;

    NSMutableArray *resultRows = [@[] mutableCopy];
    for (NSArray *row in rows) {
        if ((noads && [row[2] isKindOfClass:%c(MSGInboxUnit)] && [[row[2] key] isEqualToString:@"ads_renderer"]) ||
            (hidestoriesrow && [row[2] isKindOfClass:%c(MSGInboxUnit)] && [[row[2] key] isEqualToString:@"montage_renderer"])) {
            continue;
        }
        [resultRows addObject:row];
    }
    return resultRows;
}

%end

#pragma mark - Disable read receipt

%hook MSGMessageListViewController

- (void)viewDidLoad {
    %orig;
    [self setValue:@(disablereadreceipt) forKey:@"_disableReadReceipts"];
}

%end

#pragma mark - Disable typing indicator

%hook LSComposerViewController

- (void)_updateComposerEventWithTextViewChanged:(LSTextView *)arg1 {
    if (!disabletypingindicator) {
        %orig;
        return;
    }

    LSComposerView *_composerView = MSHookIvar<LSComposerView *>(self, "_composerView");
    LSComposerComponentStackView *_topStackView = MSHookIvar<LSComposerComponentStackView *>(_composerView, "_topStackView");
    if (_topStackView.frame.size.height > 0.0 || [arg1.text containsString:@"@"]) {
        %orig;
    }
}

%end

#pragma mark - Disable story seen receipt

%hook LSStoryBucketViewController

- (void)startTimer {
    if (!disablestoryseenreceipt) {
        %orig;
    }
}

%end

#pragma mark - Save friends' stories

%hook LSStoryOverlayProfileView

- (void)_handleOverflowMenuButton:(UIButton *)arg1 {
    if (!cansavefriendsstory) {
        return %orig;
    }

    // check if this story is mine
    if ([self.storyAuthorId isEqualToString:[[%c(LSAppDelegate) sharedInstance] getCurrentLoggedInUserId]]) {
        return %orig;
    }

    // otherwise show alert with save and original actions
    LSStoryOverlayViewController *overlayVC = (LSStoryOverlayViewController *)[[[self nextResponder] nextResponder] nextResponder];
    LSStoryBucketViewController *bucketVC = overlayVC.parentViewController;
    [bucketVC _pauseProgressIndicatorWithReset:FALSE];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *saveStoryAction = [UIAlertAction actionWithTitle:@"Save Story" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        LSMediaViewController *mediaVC = bucketVC.currentThreadVC;
        [mediaVC saveMedia];
        [bucketVC startTimer];
    }];
    UIAlertAction *otherOptionsAction = [UIAlertAction actionWithTitle:@"Options" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        %orig;
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        [bucketVC startTimer];
    }];
    [alert addAction:saveStoryAction];
    [alert addAction:otherOptionsAction];
    [alert addAction:cancelAction];

    if (IS_iPAD) {
        [alert setModalPresentationStyle:UIModalPresentationPopover];
        UIPopoverPresentationController *popPresenter = [alert popoverPresentationController];
        popPresenter.sourceView = arg1;
        popPresenter.sourceRect = arg1.bounds;
    }
    [overlayVC presentViewController:alert animated:YES completion:nil];
}

%end

#pragma mark - Hide people tab

%hook UITabBarController

- (UITabBar *)tabBar {
    UITabBar *orig = %orig;
    if (hidepeopletab) {
        orig.hidden = true;
    }
    return orig;
}

%end

#pragma mark - Hide search bar

%hook UINavigationController

- (void)_createAndAttachSearchPaletteForTransitionToTopViewControllerIfNecesssary:(id)arg1 {
    if (!hidesearchbar) {
        %orig;
    }
}

%end

#pragma mark - Extend story video upload duration

%hook MSGVideoTrimmerPresenter

- (id)presentIfPossibleWithNSURL:(id)arg1 videoMaximumDuration:(double)arg2 completion:(id)arg3 {
    double length = arg2;
    if (extendStoryVideoUploadLength) {
        length = 600.0; // 10 mins
    }
    return %orig(arg1, length, arg3);
}

%end

static void reloadPrefs() {
    plistPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@PLIST_FILENAME];
    settings = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath] ?: [@{} mutableCopy];

    hasCompletedIntroduction = [[settings objectForKey:@"hasCompletedIntroduction"] ?: @(NO) boolValue];
    noads = [[settings objectForKey:@"noads"] ?: @(YES) boolValue];
    disablereadreceipt = [[settings objectForKey:@"disablereadreceipt"] ?: @(YES) boolValue];
    disabletypingindicator = [[settings objectForKey:@"disabletypingindicator"] ?: @(YES) boolValue];
    disablestoryseenreceipt = [[settings objectForKey:@"disablestoryseenreceipt"] ?: @(YES) boolValue];
    cansavefriendsstory = [[settings objectForKey:@"cansavefriendsstory"] ?: @(YES) boolValue];
    hidesearchbar = [[settings objectForKey:@"hidesearchbar"] ?: @(NO) boolValue];
    hidestoriesrow = [[settings objectForKey:@"hidestoriesrow"] ?: @(NO) boolValue];
    hidepeopletab = [[settings objectForKey:@"hidepeopletab"] ?: @(NO) boolValue];
    hideSuggestedContactInSearch = [[settings objectForKey:@"hideSuggestedContactInSearch"] ?: @(NO) boolValue];
    showTheEyeButton = [[settings objectForKey:@"showTheEyeButton"] ?: @(YES) boolValue];
    extendStoryVideoUploadLength = [[settings objectForKey:@"extendStoryVideoUploadLength"] ?: @(YES) boolValue];
}

%ctor {
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback) reloadPrefs, CFSTR(PREF_CHANGED_NOTIF), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    reloadPrefs();

    dlopen([[[NSBundle mainBundle].bundlePath stringByAppendingPathComponent:@"Frameworks/NotInCore.framework/NotInCore"] UTF8String], RTLD_NOW);
    %init;
}
