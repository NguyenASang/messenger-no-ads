#include "MNACellModel.h"
#include "MNATableViewCell.h"
#include "MNAUtil.h"

@interface MNASettingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    UITableView *_tableView;
    NSMutableArray *tableData;
    UIView *headerView;
    UIImageView *headerImageView;
    UILabel *titleLabel;
    UIImageView *iconView;
    NSMutableDictionary *originalSettings;
}
@property (nonatomic, assign) BOOL isDarkMode;
- (instancetype)initWithFrame:(CGRect)frame isDarkMode:(BOOL)isDarkMode;
@end
