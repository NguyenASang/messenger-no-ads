#import <dlfcn.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include "settingsview/MNAIntroViewController.h"
#include "settingsview/MNASettingsViewController.h"
#include "settingsview/MNAUtil.h"

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

@interface MDSGeneratedImageSpec : NSArray
@end

@interface MDSGeneratedImageView : UIImageView
@property (nonatomic, strong, readwrite) MDSGeneratedImageSpec *spec;
@end

@interface MDSLabel : UILabel
@end

@interface LSMountableTableViewCell : UITableViewCell
- (void)setMeasureFunction:(id)arg1;
- (void)setLayoutSubviewsHook:(id)arg1;
- (id)layoutSubviewsHook;
- (id)measureFunction;
@end

@interface MSGListBinder : NSObject <UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>
@end

@interface LSContactListViewController : UIViewController {
    NSString *_featureIdentifier;
}
@end
