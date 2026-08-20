//
//  ZKBackBarButtonViewController.m
//  ZKFoundation
//
//  Created by Kaiser on 2026/8/20.
//  Copyright © 2026 zhangkai. All rights reserved.
//

#import "ZKBackBarButtonViewController.h"
#import <ZKFoundation/ZKFoundation.h>
#import <ZKCategories/ZKCategories.h>

/// 消息列表子界面的返回按钮用圆形未读数来显示。
@interface ZKDemoBackBarButton : ZKButton

@property (nonatomic, copy) NSString *countString;

@end

@interface ZKBackBarButtonViewController ()

@property (nonatomic, assign) NSInteger badgeOfPreviousViewController;

@end

@implementation ZKBackBarButtonViewController

- (instancetype)init {
    return [self initWithStyle:UITableViewStyleGrouped];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"ZKBackBarButton";
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 64;
}

- (UIViewController *)kai_previousViewController {
    NSArray<UIViewController *> *viewControllers = self.navigationController.viewControllers;
    NSInteger index = [viewControllers indexOfObject:self];
    if (index != NSNotFound && index > 0) {
        return viewControllers[index - 1];
    }
    return nil;
}

- (ZKDemoBackBarButton *)makeBackBarButtonWithBadge:(NSInteger)badge {
    ZKDemoBackBarButton *backBarButton = [ZKDemoBackBarButton buttonWithType:UIButtonTypeCustom];
    backBarButton.countString = badge > 99 ? @"99+" : [NSString stringWithFormat:@"%ld", (long)badge];
    [backBarButton sizeToFit];
    return backBarButton;
}

- (void)setBadgeOfPreviousViewController:(NSInteger)badgeOfPreviousViewController {
    _badgeOfPreviousViewController = badgeOfPreviousViewController;
    self.kai_previousViewController.navigationItem.kai_backBarButton = badgeOfPreviousViewController > 0 ? [self makeBackBarButtonWithBadge:badgeOfPreviousViewController] : nil;
}

/// 设置在当前页，push 后在转场过程中就会显示自定义返回
- (void)pushNextPageWithCustomBackBadge:(NSInteger)badge {
    self.navigationItem.kai_backBarButton = [self makeBackBarButtonWithBadge:badge];
    ZKBackBarButtonViewController *next = [[ZKBackBarButtonViewController alloc] init];
    next.title = [NSString stringWithFormat:@"Badge %ld", (long)badge];
    [self kai_pushViewController:next];
}

- (void)clearState {
    self.navigationItem.leftBarButtonItems = nil;
    self.navigationItem.leftItemsSupplementBackButton = NO;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.detailTextLabel.numberOfLines = 0;
        cell.detailTextLabel.textColor = [UIColor grayColor];
        cell.textLabel.numberOfLines = 0;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Push 并显示自定义返回";
            cell.detailTextLabel.text = @"设置在当前页，转场过程中就会显示自定义返回，并支持手势返回";
            break;
        case 1:
            cell.textLabel.text = @"动态更新当前页的自定义返回";
            cell.detailTextLabel.text = @"改前一个界面的 kai_backBarButton，当前页返回按钮实时刷新";
            break;
        case 2:
            cell.textLabel.text = @"恢复为系统 backBarButtonItem";
            cell.detailTextLabel.text = @"将前一个界面的 kai_backBarButton 置为 nil";
            break;
        case 3:
            cell.textLabel.text = @"同时显示 leftBarButtonItems 和返回按钮";
            cell.detailTextLabel.text = @"leftItemsSupplementBackButton = YES";
            break;
        case 4:
            cell.textLabel.text = @"只显示 leftBarButtonItems";
            cell.detailTextLabel.text = @"leftItemsSupplementBackButton = NO";
            break;
        case 5:
            cell.textLabel.text = @"切换导航栏的显隐";
            cell.detailTextLabel.text = @"导航栏不可见时也应能刷新 backBarButtonItem";
            break;
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:
            [self clearState];
            [self pushNextPageWithCustomBackBadge:8];
            break;
        case 1:
            [self clearState];
            self.badgeOfPreviousViewController = self.badgeOfPreviousViewController > 0 ? self.badgeOfPreviousViewController + 1 : 100;
            break;
        case 2:
            [self clearState];
            self.kai_previousViewController.navigationItem.kai_backBarButton = nil;
            self.badgeOfPreviousViewController = 0;
            break;
        case 3:
            [self clearState];
            self.navigationItem.leftItemsSupplementBackButton = YES;
            self.navigationItem.leftBarButtonItems = @[
                [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:nil action:nil]
            ];
            break;
        case 4:
            [self clearState];
            self.navigationItem.leftItemsSupplementBackButton = NO;
            self.navigationItem.leftBarButtonItems = @[
                [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:nil action:nil]
            ];
            break;
        case 5:
            [self clearState];
            [self.navigationController setNavigationBarHidden:!self.navigationController.navigationBarHidden animated:YES];
            break;
        default:
            break;
    }
}

@end

@interface ZKDemoBackBarButton ()

@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, assign) UIEdgeInsets countLabelPadding;
@property (nonatomic, strong) UIImageView *chevronView;

@end

@implementation ZKDemoBackBarButton

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.adjustsTitleTintColorAutomatically = YES;
        self.adjustsImageTintColorAutomatically = YES;
        self.adjustsButtonWhenHighlighted = YES;

        self.chevronView = [[UIImageView alloc] initWithImage:[[self class] backChevronImage]];
        self.chevronView.contentMode = UIViewContentModeCenter;
        [self addSubview:self.chevronView];

        self.countLabel = [[UILabel alloc] init];
        self.countLabel.font = [UIFont boldSystemFontOfSize:14];
        self.countLabel.textAlignment = NSTextAlignmentCenter;
        self.countLabel.clipsToBounds = YES;
        [self addSubview:self.countLabel];

        self.countLabelPadding = UIEdgeInsetsMake(4, 6, 4, 6);
        self.spacingBetweenImageAndTitle = 5;

        [self addTarget:self action:@selector(handlePopEvent) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

+ (UIImage *)backChevronImage {
    if (@available(iOS 13.0, *)) {
        UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:18 weight:UIImageSymbolWeightSemibold];
        return [[UIImage systemImageNamed:@"chevron.left" withConfiguration:config] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    UIImage *image = [UIImage imageNamed:@"barbuttonicon_back"];
    if (image) {
        return [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    return nil;
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    UIColor *tintColor = self.tintColor;
    if (!tintColor) {
        tintColor = self.superview.tintColor;
    }
    if (!tintColor) {
        tintColor = [UIColor colorWithRed:0 green:0.478 blue:1 alpha:1];
    }
    self.chevronView.tintColor = tintColor;
    self.countLabel.textColor = tintColor;
    self.countLabel.backgroundColor = [tintColor colorWithAlphaComponent:0.25];
}

- (void)setCountString:(NSString *)countString {
    _countString = [countString copy];
    self.countLabel.text = countString;
    [self setNeedsLayout];
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize chevronSize = self.chevronView.image ? self.chevronView.image.size : CGSizeMake(12, 20);
    CGSize countLabelSize = [self.countLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
    countLabelSize.width = countLabelSize.width + self.countLabelPadding.left + self.countLabelPadding.right;
    countLabelSize.height = countLabelSize.height + self.countLabelPadding.top + self.countLabelPadding.bottom;
    countLabelSize.width = MAX(countLabelSize.width, countLabelSize.height);
    CGFloat resultWidth = chevronSize.width + self.spacingBetweenImageAndTitle + countLabelSize.width;
    CGFloat resultHeight = MAX(chevronSize.height, countLabelSize.height);
    return CGSizeMake(resultWidth, resultHeight);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize chevronSize = self.chevronView.image ? self.chevronView.image.size : CGSizeMake(12, 20);
    self.chevronView.frame = CGRectMake(0, (CGRectGetHeight(self.bounds) - chevronSize.height) / 2.0, chevronSize.width, chevronSize.height);

    CGSize countFit = [self.countLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
    CGFloat countHeight = countFit.height + self.countLabelPadding.top + self.countLabelPadding.bottom;
    CGFloat countWidth = CGRectGetWidth(self.bounds) - CGRectGetMaxX(self.chevronView.frame) - self.spacingBetweenImageAndTitle;
    self.countLabel.frame = CGRectMake(CGRectGetMaxX(self.chevronView.frame) + self.spacingBetweenImageAndTitle,
                                       (CGRectGetHeight(self.bounds) - countHeight) / 2.0,
                                       countWidth,
                                       countHeight);
    self.countLabel.layer.cornerRadius = countHeight / 2.0;
}

- (void)handlePopEvent {
    UIViewController *host = self.viewController;
    UINavigationController *nav = nil;
    if ([host isKindOfClass:UINavigationController.class]) {
        nav = (UINavigationController *)host;
    } else {
        nav = host.navigationController;
    }
    if (!nav) {
        return;
    }

    UIViewController *top = nav.topViewController;
    void (^callback)(UIViewController *) = top.kai_prefersPopViewControllerInjectBlock;
    if (callback) {
        callback(top);
    } else {
        [nav popViewControllerAnimated:YES];
    }
}

@end
