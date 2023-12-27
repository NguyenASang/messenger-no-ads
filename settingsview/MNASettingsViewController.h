#import "MNACellModel.h"
#import "MNATableViewCell.h"
#import "MNAUtil.h"

@interface MNASettingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    UITableView *_tableView;
    NSMutableArray *_tableData;
    UIView *_headerView;
    UIImageView *_headerImageView;
    UILabel *titleLabel;
    UIImageView *_iconView;
    NSMutableDictionary *_originalSettings;
}
@end
