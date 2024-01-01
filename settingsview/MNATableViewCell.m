#import "MNATableViewCell.h"
#import "UtilityFunctions.h"

@implementation MNATableViewCell

- (id)initWithData:(MNACellModel *)cellData reuseIdentifier:(NSString *)reuseIdentifier isDarkMode:(BOOL)isDarkMode {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    _cellData = cellData;
    _plistPath = [MNAUtil getPlistPath];
    if (self) {
        self.isDarkMode = isDarkMode;

        self.textLabel.text = cellData.label;
        self.textLabel.textColor = self.isDarkMode ? colorWithHexString(@"#F2F2F2") : colorWithHexString(@"#333333");
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.detailTextLabel.text = cellData.subtitle;
        self.detailTextLabel.textColor = self.isDarkMode ? colorWithHexString(@"#888888") : colorWithHexString(@"#828282");
        if (cellData.disabled) {
            self.userInteractionEnabled = NO;
            self.textLabel.enabled = NO;
        }

        switch (cellData.type) {
            case Switch: {
                [self loadSwitcher];
                break;
            }

            case Button:
            case Link: {
                self.selectionStyle = UITableViewCellSelectionStyleDefault;
                self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
            }

            case StaticText: {
                self.textLabel.font=[UIFont systemFontOfSize:13];
                self.contentView.backgroundColor = self.isDarkMode ? colorWithHexString(@"#000000") : colorWithHexString(@"#EFEFF4");
                break;
            }

            case Default:
            default:
                break;
        }
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    switch (_cellData.type) {
        case Switch: {
            [self loadSwitcher];
            break;
        }
        default:
            break;
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    if (highlighted) {
        if (self.selectionStyle != UITableViewCellSelectionStyleNone) {
            self.contentView.superview.backgroundColor = [colorWithHexString(@"#B787FF") colorWithAlphaComponent:0.3];
        }
    } else {
        self.contentView.superview.backgroundColor = self.isDarkMode ? colorWithHexString(@"#1C1C1C") : colorWithHexString(@"#FFFFFF");
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (selected) {
        if (self.selectionStyle != UITableViewCellSelectionStyleNone) {
            self.contentView.superview.backgroundColor = [colorWithHexString(@"#B787FF") colorWithAlphaComponent:0.3];
        }
    } else {
        self.contentView.superview.backgroundColor = self.isDarkMode ? colorWithHexString(@"#1C1C1C") : colorWithHexString(@"#FFFFFF");
    }
}

- (void)setPreferenceValue:(id)value {
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:_plistPath] ?: [@{} mutableCopy];
    [settings setObject:value forKey:_cellData.prefKey];
    BOOL success = [settings writeToFile:_plistPath atomically:YES];

    if (!success) {
        //[HCommon showAlertMessage:@"Can't write file" withTitle:@"Error" viewController:nil];
    } else {
        notify_post(PREF_CHANGED_NOTIF);
    }
}

- (id)readPreferenceValueForKey:(NSString *)prefKey {
    NSDictionary *settings = [[NSDictionary alloc] initWithContentsOfFile:_plistPath] ?: [@{} mutableCopy];
    return settings[prefKey];
}

- (void)switchChanged:(id)sender {
    UISwitch *switchControl = sender;
    [self setPreferenceValue:[NSNumber numberWithBool:switchControl.on]];
}

- (void)loadSwitcher {
    UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
    self.accessoryView = switchView;
    id savedValue = [self readPreferenceValueForKey:_cellData.prefKey];
    BOOL value;
    if (savedValue == nil) {
        value = [[_cellData.defaultValue uppercaseString] isEqual:@"TRUE"];
    } else {
        value = [savedValue boolValue];
    }
    [switchView setOn:value animated:NO];
    [switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];

    if (_cellData.disabled) {
        switchView.enabled = NO;
    }
}

@end
