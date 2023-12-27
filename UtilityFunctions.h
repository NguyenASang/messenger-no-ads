#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/* COLOR STUFFS */

// Source: https://stackoverflow.com/a/26341062
static inline NSString *hexFromUIColor(UIColor *color) {
    const CGFloat *components = CGColorGetComponents(color.CGColor);

    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];

    return [NSString stringWithFormat:@"#%02lX%02lX%02lX",
            lroundf(r * 255),
            lroundf(g * 255),
            lroundf(b * 255)];
}

static inline CGFloat colorComponentFrom(NSString *string, NSUInteger start, NSUInteger length) {
    NSString *substring = [string substringWithRange: NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat: @"%@%@", substring, substring];
    unsigned hexComponent;
    [[NSScanner scannerWithString: fullHex] scanHexInt: &hexComponent];
    return hexComponent / 255.0;
}

static inline UIColor *colorWithHexString(NSString *hexString) {
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString: @"#" withString: @""] uppercaseString];

    CGFloat alpha, red, blue, green;

    // #RGB
    alpha = 1.0f;
    red   = colorComponentFrom(colorString, 0, 2);
    green = colorComponentFrom(colorString, 2, 2);
    blue  = colorComponentFrom(colorString, 4, 2);

    return [UIColor colorWithRed: red green: green blue: blue alpha: alpha];
}

/* FILE STUFFS */

static inline NSBundle *MessengerNoAdsBundle() {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
        NSString *tweakBundlePath = [[NSBundle mainBundle] pathForResource:@"MessengerNoAds" ofType:@"bundle"];
        if (tweakBundlePath)
            bundle = [NSBundle bundleWithPath:tweakBundlePath];
        else
            bundle = [NSBundle bundleWithPath:@"/Library/Application Support/MessengerNoAds.bundle"];
    });
    return bundle;
}

static inline NSString *LOC(NSString *key) {
    return [MessengerNoAdsBundle() localizedStringForKey:key value:nil table:nil];
}

static inline NSString *FILEPATH(NSString *name, NSString *type) {
    return [MessengerNoAdsBundle() pathForResource:name ofType:type];
}

static inline UIImage *IMAGE(NSString *name) {
    return [UIImage imageWithContentsOfFile:FILEPATH(name, @"png")];
}

/* HELPER FUNCTIONS */
/*
static inline NSMutableDictionary *settingsPlist() {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *settingsPath = [documentsDirectory stringByAppendingPathComponent:@"iSponsorBlock.plist"];
    NSMutableDictionary *settings = [NSMutableDictionary dictionary];
    [settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:settingsPath]];

    return settings;
}
*/
