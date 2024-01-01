#import <libhdev/HUtilities/HCommon.h>
#import <notify.h>
#import "MNACellModel.h"
#import "MNAUtil.h"

@interface MNATableViewCell : UITableViewCell {
    MNACellModel *_cellData;
    NSString *_plistPath;
}
@property (nonatomic, assign) BOOL isDarkMode;
- (id)initWithData:(MNACellModel *)cellData reuseIdentifier:(NSString *)reuseIdentifier isDarkMode:(BOOL)isDarkMode;
@end
