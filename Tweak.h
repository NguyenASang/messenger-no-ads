#import <dlfcn.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "settingsview/MNASettingsViewController.h"
#import "settingsview/MNAUtil.h"

@interface LSAppDelegate : NSObject
+ (id)sharedInstance; // new methods
- (id)getCurrentLoggedInUserId;
- (void)presentViewController:(id)arg1 animated:(BOOL)arg2 completion:(id)arg3;
@end

@interface MSGSplitViewController : UIViewController
@property (nonatomic, retain) UIView *sideSwitch; // new property
@property (nonatomic, retain) UIImageView *imageView; // new property
- (void)initEyeButton; // new method
@end

@interface MDSThemedNavigationBar : UINavigationBar
@end

@interface MDSNavigationBar : MDSThemedNavigationBar
@end

@interface UINavigationBar ()
@property _UINavigationBarItemStack *_stack;
@end

@interface MDSNavigationController : UINavigationController
- (void)pushViewController:(id)arg1 animated:(BOOL)arg2;
- (UIView *)view;
@end

@interface MSGContentSizeIgnoringTableView : UITableView
@end

@interface MDSSplitViewController : UIViewController
@property (nonatomic, retain) UIView *sideSwitch; // new property
@property (nonatomic, retain) UIImageView *imageView; // new property
- (void)initEyeButton; // new method
@end

@interface MBUIStoryViewerAuthorOverlayModel : UIView
@property(readonly, copy, nonatomic) NSString *authorId;
@end

@interface LSMediaViewController : UIViewController
- (void)saveMedia;
@end

@interface LSStoryBucketViewControllerBase : UIViewController
@property(readonly, nonatomic) LSMediaViewController *currentThreadVC;
- (void)_pauseProgressIndicatorWithReset:(BOOL)arg1;
- (void)startTimer;
@end

@interface LSStoryBucketViewController : LSStoryBucketViewControllerBase
@end

@interface LSStoryOverlayViewController : UIViewController
@property(nonatomic, weak, readwrite) LSStoryBucketViewController * parentViewController;
@end

@interface LSStoryOverlayProfileView : UIView
@property(readonly, copy, nonatomic) NSString *storyAuthorId;
@end

@interface LSTextView : UITextView
@end

@interface LSComposerView : NSObject
@end

@interface LSComposerComponentStackView : UIView
@end

@protocol MDSGeneratedImageSpecProtocol
@end

@interface MDSGeneratedImageView : UIImageView
@property (nonatomic, strong, readwrite) NSObject <MDSGeneratedImageSpecProtocol> *spec;
@end

@interface MDSLabel : UILabel
@end

@interface LSMountableTableViewCell : UITableViewCell
@property (retain, nonatomic) MDSGeneratedImageView *arrowImage;
@property (retain, nonatomic) UIButton *touchCapture;
@end

@interface MSGListBinder : NSObject <UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>
@end

@interface LSContactListViewController : UIViewController {
    NSString *_featureIdentifier;
}
@end

typedef struct {
    SEL loadView;
    SEL viewDidLoad;
    SEL viewWillAppear;
    SEL viewDidAppear;
    SEL viewWillDisappear;
    SEL viewDidDisappear;
    SEL viewWillLayoutSubviews;
    SEL viewDidLayoutSubviews;
    SEL preferredContentSize;
    SEL shouldAutoRotate;
    SEL supportedInterfaceOrientations;
    SEL viewWillTransitionToSizeWithTransitionCoordinator;
    SEL willTransitionToTraitCollectionWithTransitionCoordinator;
    SEL shouldAutomaticallyForwardAppearanceMethods;
    SEL willMoveToParentViewController;
    SEL didMoveToParentViewController;
    SEL updateViewConstraints;
    SEL viewLayoutMarginsDidChange;
    SEL viewSafeAreaInsetsDidChange;
    SEL preferredContentSizeDidChangeForChildContentContainer;
    SEL preferredStatusBarStyle;
    SEL childViewControllerForStatusBarStyle;
    SEL preferredStatusBarUpdateAnimation;
    SEL prefersStatusBarHidden;
    SEL modalPresentationCapturesStatusBarAppearance;
    SEL accessibilityActivate;
    SEL accessibilityIncrement;
    SEL accessibilityScroll;
    SEL accessibilityPerformEscape;
    SEL dealloc;
    SEL accessibilityValue;
    SEL accessibilityLabel;
    SEL accessibilityHint;
    SEL debugDescription;
    SEL preferredScreenEdgesDeferringSystemGestures;
    SEL childViewControllerForScreenEdgesDeferringSystemGestures;
    SEL traitCollectionDidChange;
    SEL surfaceTags;
} LSViewControllerFuncTable;

//? Maybe this will be neccessary later
/*
LSViewControllerFuncTable MakeInitialFuncTable() {
    LSViewControllerFuncTable funcTable;
    funcTable.loadView = @selector(loadView);
    funcTable.viewDidLoad = @selector(viewDidLoad);
    funcTable.viewWillAppear = @selector(viewWillAppear:);
    funcTable.viewDidAppear = @selector(viewDidAppear:);
    funcTable.viewWillDisappear = @selector(viewWillDisappear:);
    funcTable.viewDidDisappear = @selector(viewDidDisappear:);
    funcTable.viewWillLayoutSubviews = @selector(viewWillLayoutSubviews);
    funcTable.viewDidLayoutSubviews = @selector(viewDidLayoutSubviews);
    funcTable.preferredContentSize = @selector(preferredContentSize);
    funcTable.shouldAutoRotate = @selector(shouldAutoRotate);
    funcTable.supportedInterfaceOrientations = @selector(supportedInterfaceOrientations);
    funcTable.viewWillTransitionToSizeWithTransitionCoordinator = @selector(viewWillTransitionToSize:withTransitionCoordinator:);
    funcTable.willTransitionToTraitCollectionWithTransitionCoordinator = @selector(willTransitionToTraitCollection:withTransitionCoordinator:);
    funcTable.shouldAutomaticallyForwardAppearanceMethods = @selector(shouldAutomaticallyForwardAppearanceMethods);
    funcTable.willMoveToParentViewController = @selector(willMoveToParentViewController:);
    funcTable.didMoveToParentViewController = @selector(didMoveToParentViewController:);
    funcTable.updateViewConstraints = @selector(updateViewConstraints);
    funcTable.viewLayoutMarginsDidChange = @selector(viewLayoutMarginsDidChange);
    funcTable.viewSafeAreaInsetsDidChange = @selector(viewSafeAreaInsetsDidChange);
    funcTable.preferredContentSizeDidChangeForChildContentContainer = @selector(preferredContentSizeDidChangeForChildContentContainer:);
    funcTable.preferredStatusBarStyle = @selector(preferredStatusBarStyle);
    funcTable.childViewControllerForStatusBarStyle = @selector(childViewControllerForStatusBarStyle);
    funcTable.preferredStatusBarUpdateAnimation = @selector(preferredStatusBarUpdateAnimation);
    funcTable.prefersStatusBarHidden = @selector(prefersStatusBarHidden);
    funcTable.modalPresentationCapturesStatusBarAppearance = @selector(modalPresentationCapturesStatusBarAppearance);
    funcTable.accessibilityActivate = @selector(accessibilityActivate);
    funcTable.accessibilityIncrement = @selector(accessibilityIncrement);
    funcTable.accessibilityScroll = @selector(accessibilityScroll:);
    funcTable.accessibilityPerformEscape = @selector(accessibilityPerformEscape);
    //funcTable.dealloc = @selector(dealloc);
    funcTable.accessibilityValue = @selector(accessibilityValue);
    funcTable.accessibilityLabel = @selector(accessibilityLabel);
    funcTable.accessibilityHint = @selector(accessibilityHint);
    funcTable.debugDescription = @selector(debugDescription);
    funcTable.preferredScreenEdgesDeferringSystemGestures = @selector(preferredScreenEdgesDeferringSystemGestures);
    funcTable.childViewControllerForScreenEdgesDeferringSystemGestures = @selector(childViewControllerForScreenEdgesDeferringSystemGestures);
    funcTable.traitCollectionDidChange = @selector(traitCollectionDidChange:);
    funcTable.surfaceTags = @selector(surfaceTags);

    return funcTable;
}
*/

@interface LSViewController : UIViewController
- (instancetype)initWithFuncTable:(LSViewControllerFuncTable)funcTable className:(const char *)name;
@end

@interface MSGMessageListViewController : UIViewController
@end
