#import <UIKit/UIKit.h>

#define TWEAK_TITLE "Messenger No Ads"
#define PREF_BUNDLE_PATH "/Library/Application Support/MessengerNoAds.bundle"
#define PLIST_FILENAME "com.haoict.MessengerNoAds.plist"
#define PREF_CHANGED_NOTIF "com.haoict.messengernoadspref/PrefChanged"

@interface MNAUtil : NSObject
+ (void)showRequireRestartAlert:(UIViewController *)vc;
+ (NSString *)getPlistPath;
+ (NSMutableDictionary *)getCurrentSettingsFromPlist;
+ (NSDictionary *)compareNSDictionary:(NSDictionary *)d1 withNSDictionary:(NSDictionary *)d2;
@end