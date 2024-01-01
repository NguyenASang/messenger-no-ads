#import <RemoteLog.h>
#include "Tweak.h"
#include "UtilityFunctions.h"

/**
* Load Preferences
*/
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

static BOOL didHaveAccessory = NO;
static LSMountableTableViewCell *mnaCell = nil;
static MDSNavigationController *controller = nil;

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

%group Settings
%hook MDSNavigationController

- (void)viewDidLoad {
    %orig;
    controller = self;
}

%end

%hook LSMountableTableViewCell
%property (retain, nonatomic) MDSGeneratedImageView *arrowImage;
%property (retain, nonatomic) UIButton *touchCapture;

- (void)setBackgroundColor:(UIColor *)color {
    %orig;
    if (mnaCell.backgroundColor != color) mnaCell.backgroundColor = color;
}

- (void)setSelected:(BOOL)selected {
    if (mnaCell) {
        mnaCell.selectedBackgroundView.layer.cornerRadius = 10;
        if (selected) {
            [mnaCell addSubview:mnaCell.selectedBackgroundView];
        } else {
            [mnaCell.selectedBackgroundView removeFromSuperview];
        }
        return;
    }
    %orig;
}

%end

%hook MDSGeneratedImageView

- (void)setSpec:(NSObject <MDSGeneratedImageSpecProtocol> *)spec {
    if (mnaCell && [spec isKindOfClass:%c(MDSGeneratedImageSpecIcon)] && !didHaveAccessory) {
        didHaveAccessory = YES;
        mnaCell.arrowImage.spec = spec;
    }
    %orig(spec);
}

%end

%hook MSGContentSizeIgnoringTableView

- (BOOL)touchesShouldCancelInContentView:(id)arg1 {
    return YES;
}

%end

%hook MSGListBinder

- (LSMountableTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LSMountableTableViewCell *cell = %orig;
    NSMutableSet *_registeredReuseIdentifiers = MSHookIvar<NSMutableSet *>(self, "_registeredReuseIdentifiers");
    if ([_registeredReuseIdentifiers containsObject:@"me_setting_avatar_header"] && indexPath.row == 1) {
        if (!mnaCell) {
            mnaCell = [[%c(LSMountableTableViewCell) alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MNASettings"];
            mnaCell.layoutMargins = UIEdgeInsetsMake(0, 18, 0, 16);
            mnaCell.frame = CGRectMake(20, 28, 374, 52);
            mnaCell.layer.cornerRadius = 10;
            mnaCell.accessibilityLabel = @"Advanced options";
            mnaCell.imageView.image = IMAGE(@"icon@3x");

            MDSLabel *label = [[%c(MDSLabel) alloc] initWithFrame:CGRectMake(62, 16, 409.0f / 3.0f, 58.0f / 3.0f)];
            label.font = [UIFont systemFontOfSize:16];
            label.text = @"Advanced options";

            MDSGeneratedImageView *accessoryImage = [[%c(MDSGeneratedImageView) alloc] initWithFrame:CGRectMake(334, 13.5, 24, 25)];
            mnaCell.arrowImage = accessoryImage;

            UIButton *touchCapture = [[UIButton alloc] initWithFrame:[mnaCell bounds]];
            mnaCell.touchCapture = touchCapture;

            [mnaCell addSubview:label];
            [mnaCell addSubview:accessoryImage];
            [mnaCell addSubview:touchCapture];

            mnaCell.selectedBackgroundView.layer.cornerRadius = 10;
        }
        tableView.delaysContentTouches = NO;
        [mnaCell.touchCapture addTarget:self action:@selector(didPressMNACell:) forControlEvents:UIControlEventTouchDown];
        [mnaCell.touchCapture addTarget:self action:@selector(cancelPressMNACell:) forControlEvents:UIControlEventTouchCancel];
        [mnaCell.touchCapture addTarget:self action:@selector(didEndPressMNACell:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:mnaCell];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableSet *_registeredReuseIdentifiers = MSHookIvar<NSMutableSet *>(self, "_registeredReuseIdentifiers");
    if ([_registeredReuseIdentifiers containsObject:@"me_setting_avatar_header"] && indexPath.row == 1) {
        return 108;
    }
    return %orig;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(LSMountableTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableSet *_registeredReuseIdentifiers = MSHookIvar<NSMutableSet *>(self, "_registeredReuseIdentifiers");
    if ([_registeredReuseIdentifiers containsObject:@"me_setting_avatar_header"] && indexPath.row == 1) {
        mnaCell.hidden = YES;
    }
    %orig;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(LSMountableTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableSet *_registeredReuseIdentifiers = MSHookIvar<NSMutableSet *>(self, "_registeredReuseIdentifiers");
    if ([_registeredReuseIdentifiers containsObject:@"me_setting_avatar_header"] && indexPath.row == 1) {
        mnaCell.hidden = NO;
    }
    %orig;
}

%new(v@:@@)
- (void)didPressMNACell:(id)arg1 {
    mnaCell.selected = YES;
}

%new(v@:@@)
- (void)cancelPressMNACell:(id)arg1 {
    mnaCell.selected = NO;
}

%new(v@:@@)
- (void)didEndPressMNACell:(id)arg1 {
    MNASettingsViewController *settingsVC = [[MNASettingsViewController alloc] initWithFrame:[UIScreen.mainScreen bounds] isDarkMode:YES];
    [controller pushViewController:settingsVC animated:YES];
    mnaCell.selected = NO;
}

%end
%end

/**
* Tweak's hooking code
*/
%group CommonGroup

%hook MDSSplitViewController
%property (nonatomic, retain) UIView *sideSwitch;
%property (nonatomic, retain) UIImageView *imageView;

- (void)viewDidAppear:(BOOL)arg1 {
    %orig;
    if (!hasCompletedIntroduction) {
        [self presentViewController:[MNAIntroViewController new] animated:YES completion:nil];
    }
}

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

%hook LSContactListViewController

- (void)_updateContactList {
    if (hideSuggestedContactInSearch) {
        NSString *_featureIdentifier = MSHookIvar<NSString *>(self, "_featureIdentifier");
        if ([_featureIdentifier isEqualToString:@"universal_search_null_state"]) {
            return;
        }
    }
    %orig;
}

%end
%end

%group NoAdsNoStoriesRow
%hook MSGThreadListDataSource

- (NSArray *)inboxRows {
    NSArray *orig = %orig;
    if (![orig count]) {
        return orig;
    }
    NSMutableArray *resultRows = [@[] mutableCopy];
    if (!(hidestoriesrow && [orig[0][2] isKindOfClass:[NSArray class]] && [orig[0][2][1] isEqual:@"montage_renderer"])) {
        [resultRows addObject:orig[0]];
    }
    for (int i = 1; i < [orig count]; i++) {
        NSArray *row = orig[i];
        if (!noads || (noads && [row[1] intValue] != 2) || ([row[2] isKindOfClass:[NSArray class]] && [row[2][1] isEqual:@"message_requests_spam_unit"])) {
        [resultRows addObject:row];
        }
    }
    return resultRows;
}

%end

%hook LSStoryViewerContentController

- (void)_issueAdsFetchWithCurrentSync:(id)arg1 startIndex:(int)arg2 bucketStoryModels:(id)arg3 {}

%end
%end

%group DisableReadReceipt
%hook MSGMessageListViewController

- (void)viewDidLoad {
    %orig;
    [self setValue:@(disablereadreceipt) forKey:@"_disableReadReceipts"];
}

%end
%end

%group DisableTypingIndicator
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
%end

%group DisableStorySeenReceipt
%hook LSStoryBucketViewController

- (void)startTimer {
    if (!disablestoryseenreceipt) {
        %orig;
    }
}

%end
%end

%group CanSaveFriendsStory
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
%end

%group HidePeopleTab
%hook UITabBarController

- (UITabBar *)tabBar {
    UITabBar *orig = %orig;
    if (hidepeopletab) {
        orig.hidden = true;
    }
    return orig;
}

%end
%end

%group HideSearchBar
%hook UINavigationController

- (void)_createAndAttachSearchPaletteForTransitionToTopViewControllerIfNecesssary:(id)arg1 {
    if (!hidesearchbar) {
        %orig;
    }
}

%end
%end

%group ExtendStoryVideoUploadLength
%hook MSGVideoTrimmerPresenter

- (id)presentIfPossibleWithNSURL:(id)arg1 videoMaximumDuration:(double)arg2 completion:(id)arg3 {
    double length = arg2;
    if (extendStoryVideoUploadLength) {
        length = 600.0; // 10 mins
    }
    return %orig(arg1, length, arg3);
}

%end
%end

/**
* Constructor
*/
%ctor {
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback) reloadPrefs, CFSTR(PREF_CHANGED_NOTIF), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    reloadPrefs();

    dlopen([[[NSBundle mainBundle].bundlePath stringByAppendingPathComponent:@"Frameworks/NotInCore.framework/NotInCore"] UTF8String], RTLD_NOW);

    %init(Settings);
    %init(CommonGroup);
    %init(NoAdsNoStoriesRow);
    %init(DisableReadReceipt);
    %init(DisableTypingIndicator);
    %init(DisableStorySeenReceipt);
    %init(CanSaveFriendsStory);
    %init(HideSearchBar);
    %init(HidePeopleTab);
    %init(ExtendStoryVideoUploadLength);
}
