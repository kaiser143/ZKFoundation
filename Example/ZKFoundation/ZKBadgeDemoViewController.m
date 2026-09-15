//
//  ZKBadgeDemoViewController.m
//  ZKFoundation_Example
//
//  Created by Kaiser on 2026/6/16.
//

#import "ZKBadgeDemoViewController.h"
#import <ZKCategories/ZKCategories.h>
#import <ZKFoundation/ZKFoundation.h>

typedef NS_ENUM(NSInteger, ZKBadgeDemoRow) {
    ZKBadgeDemoRowInteger = 0,
    ZKBadgeDemoRow99Plus,
    ZKBadgeDemoRowString,
    ZKBadgeDemoRowCustomStyle,
    ZKBadgeDemoRowCustomCornerRadius,
    ZKBadgeDemoRowOffset,
    ZKBadgeDemoRowUpdatesIndicator,
    ZKBadgeDemoRowToggleBadge,
    ZKBadgeDemoRowToggleIndicator,
    ZKBadgeDemoRowClearAll,
};

@interface ZKBadgeDemoViewController ()

@property (nonatomic, strong) NSArray<NSDictionary *> *items;

@end

@implementation ZKBadgeDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"ZKBadge";
    self.view.backgroundColor = UIColor.whiteColor;
    self.tableView.tableFooterView = UIView.new;
    [self buildItems];
}

- (void)buildItems {
    self.items = @[
        @{@"title": @"数字未读数", @"detail": @"kai_badgeInteger = 5"},
        @{@"title": @"数字 99", @"detail": @"kai_badgeInteger = 99，观察正圆变胶囊"},
        @{@"title": @"字符串未读数", @"detail": @"kai_badgeString = @\"NEW\""},
        @{@"title": @"自定义样式", @"detail": @"背景/文字颜色 + 字体 + 内边距"},
        @{@"title": @"固定小圆角", @"detail": @"kai_badgeCornerRadius = 4，不随高度自适应"},
        @{@"title": @"自定义偏移", @"detail": @"kai_badgeOffset，观察位置变化"},
        @{@"title": @"红点 UpdatesIndicator", @"detail": @"kai_shouldShowUpdatesIndicator + 尺寸/颜色"},
        @{@"title": @"开关 Badge", @"detail": @"点击在 5 与隐藏之间切换"},
        @{@"title": @"开关红点", @"detail": @"点击切换红点显隐"},
        @{@"title": @"清除全部", @"detail": @"badgeString = nil / 红点隐藏"},
    ];
}

#pragma mark - Helpers

/// 每行右侧挂一个 28x28 的色块作为 badge 载体，直观对比不同形态
- (UIView *)demoIconForRow:(ZKBadgeDemoRow)row {
    UIView *icon = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
    icon.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1];
    icon.layer.cornerRadius = 6;
    switch (row) {
        case ZKBadgeDemoRowInteger: {
            icon.kai_badgeInteger = 5;
        }
            break;
        case ZKBadgeDemoRow99Plus: {
            icon.kai_badgeInteger = 99;
        }
            break;
        case ZKBadgeDemoRowString: {
            icon.kai_badgeString = @"NEW";
        }
            break;
        case ZKBadgeDemoRowCustomStyle: {
            icon.kai_badgeBackgroundColor = [UIColor systemBlueColor];
            icon.kai_badgeTextColor = UIColor.yellowColor;
            icon.kai_badgeFont = [UIFont systemFontOfSize:9 weight:UIFontWeightHeavy];
            icon.kai_badgeContentEdgeInsets = UIEdgeInsetsMake(3, 6, 3, 6);
            icon.kai_badgeString = @"HOT";
        }
            break;
        case ZKBadgeDemoRowCustomCornerRadius: {
            icon.kai_badgeCornerRadius = 4;
            icon.kai_badgeString = @"99";
        }
            break;
        case ZKBadgeDemoRowOffset: {
            icon.kai_badgeOffset = CGPointMake(6, 20);
            icon.kai_badgeString = @"1";
        }
            break;
        case ZKBadgeDemoRowUpdatesIndicator: {
            icon.kai_updatesIndicatorSize = CGSizeMake(9, 9);
            icon.kai_updatesIndicatorColor = [UIColor systemOrangeColor];
            icon.kai_shouldShowUpdatesIndicator = YES;
        }
            break;
        case ZKBadgeDemoRowToggleBadge: {
            icon.kai_badgeInteger = 5;
        }
            break;
        case ZKBadgeDemoRowToggleIndicator: {
            icon.kai_shouldShowUpdatesIndicator = YES;
        }
            break;
        default:
            break;
    }
    return icon;
}

/// 面向协议编程的示例：调用方只依赖 id<ZKBadgeProtocol>，不关心载体是 UIView 还是未来的 UIBarItem
- (void)showDotOn:(id<ZKBadgeProtocol>)badgeable {
    badgeable.kai_shouldShowUpdatesIndicator = YES;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *const kCellId = @"ZKBadgeDemoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellId];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSDictionary *item = self.items[indexPath.row];
    cell.textLabel.text = item[@"title"];
    cell.detailTextLabel.text = item[@"detail"];
    cell.detailTextLabel.textColor = [UIColor colorWithWhite:0.45 alpha:1];
    cell.accessoryView = [self demoIconForRow:indexPath.row];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    UIView *icon = [tableView cellForRowAtIndexPath:indexPath].accessoryView;
    if (![icon isKindOfClass:UIView.class]) return;

    switch (indexPath.row) {
        case ZKBadgeDemoRowInteger: {
            icon.kai_badgeInteger = 5;
        }
            break;
        case ZKBadgeDemoRow99Plus: {
            icon.kai_badgeInteger = 99;
        }
            break;
        case ZKBadgeDemoRowString: {
            icon.kai_badgeString = @"NEW";
        }
            break;
        case ZKBadgeDemoRowCustomStyle: {
            icon.kai_badgeBackgroundColor = [UIColor systemBlueColor];
            icon.kai_badgeTextColor = UIColor.yellowColor;
            icon.kai_badgeFont = [UIFont systemFontOfSize:9 weight:UIFontWeightHeavy];
            icon.kai_badgeContentEdgeInsets = UIEdgeInsetsMake(3, 6, 3, 6);
            icon.kai_badgeString = @"HOT";
        }
            break;
        case ZKBadgeDemoRowCustomCornerRadius: {
            icon.kai_badgeCornerRadius = 4;
            icon.kai_badgeString = @"99";
        }
            break;
        case ZKBadgeDemoRowOffset: {
            // 相对默认右上角原点偏移：x 正值向右，y 正值向下
            icon.kai_badgeOffset = CGPointMake(6, 20);
            icon.kai_badgeString = @"1";
        }
            break;
        case ZKBadgeDemoRowUpdatesIndicator: {
            icon.kai_updatesIndicatorSize = CGSizeMake(9, 9);
            icon.kai_updatesIndicatorColor = [UIColor systemOrangeColor];
            icon.kai_updatesIndicatorOffset = CGPointMake(4, 7);
            [self showDotOn:icon];
        }
            break;
        case ZKBadgeDemoRowToggleBadge: {
            icon.kai_badgeInteger = (icon.kai_badgeInteger > 0) ? 0 : 5;
        }
            break;
        case ZKBadgeDemoRowToggleIndicator: {
            icon.kai_shouldShowUpdatesIndicator = !icon.kai_shouldShowUpdatesIndicator;
        }
            break;
        case ZKBadgeDemoRowClearAll: {
            icon.kai_badgeString = nil;
            icon.kai_shouldShowUpdatesIndicator = NO;
        }
            break;
        default:
            break;
    }
}

@end
