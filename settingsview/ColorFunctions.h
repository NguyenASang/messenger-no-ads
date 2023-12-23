#import <UIKit/UIKit.h>

static CGFloat colorComponentFrom(NSString *string, NSUInteger start, NSUInteger length) {
    NSString *substring = [string substringWithRange: NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat: @"%@%@", substring, substring];
    unsigned hexComponent;
    [[NSScanner scannerWithString: fullHex] scanHexInt: &hexComponent];
    return hexComponent / 255.0;
}

static UIColor *colorWithHexString(NSString *hexString) {
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString: @"#" withString: @""] uppercaseString];

    CGFloat alpha, red, blue, green;

    // #RGB
    alpha = 1.0f;
    red   = colorComponentFrom(colorString,0,2);
    green = colorComponentFrom(colorString,2,2);
    blue  = colorComponentFrom(colorString,4,2);

    return [UIColor colorWithRed: red green: green blue: blue alpha: alpha];
}