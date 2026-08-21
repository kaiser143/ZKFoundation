//
//  ZKPopupDemoViewController.m
//  ZKFoundation_Example
//
//  Created by zhangkai on 2026/8/21.
//  Copyright © 2026 zhangkai. All rights reserved.
//

#import "ZKPopupDemoViewController.h"
#import <ZKCategories/ZKCategories.h>
#import <ZKFoundation/ZKFoundation.h>

typedef NS_ENUM(NSInteger, ZKPopupDemoSection) {
    ZKPopupDemoSectionStyle = 0,
    ZKPopupDemoSectionPresentation,
    ZKPopupDemoSectionMask,
    ZKPopupDemoSectionFeature,
};

@interface ZKPopupDemoViewController () <ZKPopupControllerDelegate>

@property (nonatomic, strong) ZKPopupController *popup;
@property (nonatomic, strong) NSArray<NSArray<NSDictionary *> *> *sections;

@end

@implementation ZKPopupDemoViewController

- (instancetype)init {
    return [self initWithStyle:UITableViewStyleGrouped];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Popup";
    self.tableView.tableFooterView = UIView.new;
    [self buildSections];
}

- (void)buildSections {
    self.sections = @[
        @[
            @{@"title": @"底部 ActionSheet", @"detail": @"ZKPopupStyleActionSheet"},
            @{@"title": @"居中弹窗", @"detail": @"ZKPopupStyleCentered"},
            @{@"title": @"全屏弹窗", @"detail": @"ZKPopupStyleFullscreen"},
        ],
        @[
            @{@"title": @"淡入", @"detail": @"FadeIn"},
            @{@"title": @"从上滑入", @"detail": @"SlideInFromTop"},
            @{@"title": @"从下滑入", @"detail": @"SlideInFromBottom"},
            @{@"title": @"从左滑入", @"detail": @"SlideInFromLeft"},
            @{@"title": @"从右滑入", @"detail": @"SlideInFromRight"},
            @{@"title": @"反向消失", @"detail": @"dismissesOppositeDirection"},
        ],
        @[
            @{@"title": @"透明遮罩", @"detail": @"MaskTypeClear"},
            @{@"title": @"半透明遮罩", @"detail": @"MaskTypeDimmed"},
            @{@"title": @"自定义遮罩色", @"detail": @"MaskTypeCustom"},
            @{@"title": @"背景模糊", @"detail": @"blurEffectAlpha"},
        ],
        @[
            @{@"title": @"点击背景不关闭", @"detail": @"shouldDismissOnBackgroundTouch = NO"},
            @{@"title": @"键盘避让", @"detail": @"movesAboveKeyboard"},
            @{@"title": @"动态更新布局", @"detail": @"updateLayoutWithChanges"},
            @{@"title": @"综合示例", @"detail": @"富文本 + 图片 + 自定义视图"},
        ],
    ];
}

#pragma mark - Table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sections[section].count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case ZKPopupDemoSectionStyle: return @"展示样式 popupStyle";
        case ZKPopupDemoSectionPresentation: return @"出场动画 presentationStyle";
        case ZKPopupDemoSectionMask: return @"遮罩 maskType";
        case ZKPopupDemoSectionFeature: return @"其他能力";
        default: return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *const kCellId = @"ZKPopupDemoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellId];
    }
    NSDictionary *item = self.sections[indexPath.section][indexPath.row];
    cell.textLabel.text = item[@"title"];
    cell.detailTextLabel.text = item[@"detail"];
    cell.detailTextLabel.textColor = [UIColor colorWithWhite:0.45 alpha:1];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
        case ZKPopupDemoSectionStyle:
            [self showStyleDemoAtRow:indexPath.row];
            break;
        case ZKPopupDemoSectionPresentation:
            [self showPresentationDemoAtRow:indexPath.row];
            break;
        case ZKPopupDemoSectionMask:
            [self showMaskDemoAtRow:indexPath.row];
            break;
        case ZKPopupDemoSectionFeature:
            [self showFeatureDemoAtRow:indexPath.row];
            break;
        default:
            break;
    }
}

#pragma mark - Demos

- (void)showStyleDemoAtRow:(NSInteger)row {
    ZKPopupStyle style = ZKPopupStyleActionSheet;
    if (row == 1) style = ZKPopupStyleCentered;
    if (row == 2) style = ZKPopupStyleFullscreen;
    
    ZKPopupTheme *theme = [ZKPopupTheme defaultTheme];
    theme.popupStyle = style;
    if (style == ZKPopupStyleActionSheet) {
        theme.maxPopupWidth = ZKScreenSize().width;
        theme.presentationStyle = ZKPopupPresentationStyleSlideInFromBottom;
    } else if (style == ZKPopupStyleCentered) {
        theme.presentationStyle = ZKPopupPresentationStyleFadeIn;
        theme.maxPopupWidth = 300;
    } else {
        theme.maxPopupWidth = ZKScreenSize().width;
        theme.presentationStyle = ZKPopupPresentationStyleFadeIn;
    }
    [self presentPopupWithTheme:theme contents:[self basicContentsWithTitle:@"Popup Style" message:self.sections[ZKPopupDemoSectionStyle][row][@"title"]]];
}

- (void)showPresentationDemoAtRow:(NSInteger)row {
    ZKPopupTheme *theme = [ZKPopupTheme defaultTheme];
    theme.popupStyle = ZKPopupStyleCentered;
    theme.maxPopupWidth = 300;
    
    switch (row) {
        case 0: theme.presentationStyle = ZKPopupPresentationStyleFadeIn; break;
        case 1: theme.presentationStyle = ZKPopupPresentationStyleSlideInFromTop; break;
        case 2: theme.presentationStyle = ZKPopupPresentationStyleSlideInFromBottom; break;
        case 3: theme.presentationStyle = ZKPopupPresentationStyleSlideInFromLeft; break;
        case 4: theme.presentationStyle = ZKPopupPresentationStyleSlideInFromRight; break;
        case 5:
            theme.presentationStyle = ZKPopupPresentationStyleSlideInFromLeft;
            theme.dismissesOppositeDirection = YES;
            break;
        default: break;
    }
    
    NSString *title = self.sections[ZKPopupDemoSectionPresentation][row][@"title"];
    [self presentPopupWithTheme:theme contents:[self basicContentsWithTitle:title message:@"仅对居中样式生效"]];
}

- (void)showMaskDemoAtRow:(NSInteger)row {
    ZKPopupTheme *theme = [ZKPopupTheme defaultTheme];
    theme.popupStyle = ZKPopupStyleCentered;
    theme.presentationStyle = ZKPopupPresentationStyleFadeIn;
    theme.maxPopupWidth = 300;
    
    switch (row) {
        case 0:
            theme.maskType = ZKPopupMaskTypeClear;
            break;
        case 1:
            theme.maskType = ZKPopupMaskTypeDimmed;
            break;
        case 2:
            theme.maskType = ZKPopupMaskTypeCustom;
            theme.customMaskColor = [[UIColor systemPurpleColor] colorWithAlphaComponent:0.45];
            break;
        case 3:
            theme.maskType = ZKPopupMaskTypeDimmed;
            theme.blurEffectAlpha = 0.85;
            break;
        default:
            break;
    }
    
    NSString *title = self.sections[ZKPopupDemoSectionMask][row][@"title"];
    [self presentPopupWithTheme:theme contents:[self basicContentsWithTitle:title message:@"观察背景遮罩变化"]];
}

- (void)showFeatureDemoAtRow:(NSInteger)row {
    switch (row) {
        case 0: {
            ZKPopupTheme *theme = [ZKPopupTheme defaultTheme];
            theme.popupStyle = ZKPopupStyleCentered;
            theme.presentationStyle = ZKPopupPresentationStyleFadeIn;
            theme.shouldDismissOnBackgroundTouch = NO;
            theme.maxPopupWidth = 300;
            [self presentPopupWithTheme:theme contents:[self basicContentsWithTitle:@"点击背景不关闭" message:@"只能点关闭按钮退出"]];
            break;
        }
        case 1:
            [self showKeyboardDemo];
            break;
        case 2:
            [self showUpdateLayoutDemo];
            break;
        case 3:
            [self showRichContentsDemo];
            break;
        default:
            break;
    }
}

#pragma mark - Content builders

- (NSArray<UIView *> *)basicContentsWithTitle:(NSString *)title message:(NSString *)message {
    UILabel *titleLabel = [self labelWithText:title font:[UIFont boldSystemFontOfSize:20] color:UIColor.blackColor];
    UILabel *messageLabel = [self labelWithText:message font:[UIFont systemFontOfSize:15] color:[UIColor colorWithWhite:0.35 alpha:1]];
    UIButton *closeButton = [self closeButton];
    return @[titleLabel, messageLabel, closeButton];
}

- (void)showKeyboardDemo {
    UILabel *titleLabel = [self labelWithText:@"键盘避让" font:[UIFont boldSystemFontOfSize:20] color:UIColor.blackColor];
    UILabel *messageLabel = [self labelWithText:@"点击输入框，弹窗会随键盘上移" font:[UIFont systemFontOfSize:15] color:[UIColor colorWithWhite:0.35 alpha:1]];
    
    UIView *fieldContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 260, 44)];
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 260, 44)];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.placeholder = @"输入内容…";
    textField.returnKeyType = UIReturnKeyDone;
    [textField addBlockForControlEvents:UIControlEventEditingDidEndOnExit block:^(__kindof UITextField *sender) {
        [sender resignFirstResponder];
    }];
    [fieldContainer addSubview:textField];
    
    UIButton *closeButton = [self closeButton];
    
    ZKPopupTheme *theme = [ZKPopupTheme defaultTheme];
    theme.popupStyle = ZKPopupStyleCentered;
    theme.presentationStyle = ZKPopupPresentationStyleSlideInFromBottom;
    theme.movesAboveKeyboard = YES;
    theme.maxPopupWidth = 300;
    [self presentPopupWithTheme:theme contents:@[titleLabel, messageLabel, fieldContainer, closeButton]];
}

- (void)showUpdateLayoutDemo {
    @weakify(self);
    UILabel *titleLabel = [self labelWithText:@"动态布局" font:[UIFont boldSystemFontOfSize:20] color:UIColor.blackColor];
    UILabel *messageLabel = [self labelWithText:@"点击图片可增高；点按钮可还原" font:[UIFont systemFontOfSize:15] color:[UIColor colorWithWhite:0.35 alpha:1]];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithColor:[UIColor colorWithRed:0.35 green:0.72 blue:0.95 alpha:1]]];
    imageView.size = CGSizeMake(200, 120);
    imageView.layer.cornerRadius = 8;
    imageView.clipsToBounds = YES;
    imageView.userInteractionEnabled = YES;
    __block CGFloat baseHeight = 120;
    __weak UIImageView *weakImageView = imageView;
    [imageView setTapActionWithBlock:^{
        @strongify(self);
        UIImageView *strongImageView = weakImageView;
        if (!strongImageView) return;
        [self.popup updateLayoutWithChanges:^{
            strongImageView.height = MIN(strongImageView.height + 40, 280);
        }];
    }];
    
    UIButton *resetButton = [UIButton buttonWithType:UIButtonTypeSystem];
    resetButton.frame = CGRectMake(0, 0, 200, 44);
    [resetButton setTitle:@"还原高度" forState:UIControlStateNormal];
    resetButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    [resetButton addBlockForControlEvents:UIControlEventTouchUpInside block:^(__kindof UIControl *sender) {
        @strongify(self);
        UIImageView *strongImageView = weakImageView;
        if (!strongImageView) return;
        [self.popup updateLayoutWithChanges:^{
            strongImageView.height = baseHeight;
        }];
    }];
    
    UIButton *closeButton = [self closeButton];
    
    ZKPopupTheme *theme = [ZKPopupTheme defaultTheme];
    theme.popupStyle = ZKPopupStyleActionSheet;
    theme.presentationStyle = ZKPopupPresentationStyleSlideInFromBottom;
    theme.maxPopupWidth = ZKScreenSize().width;
    theme.cornerRadius = 16;
    [self presentPopupWithTheme:theme contents:@[titleLabel, messageLabel, imageView, resetButton, closeButton]];
}

- (void)showRichContentsDemo {
    @weakify(self);
    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSAttributedString *title = [[NSAttributedString alloc] initWithString:@"It's A Popup!"
                                                               attributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:24],
                                                                            NSParagraphStyleAttributeName: paragraphStyle}];
    NSAttributedString *lineOne = [[NSAttributedString alloc] initWithString:@"You can add text and images"
                                                                 attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:18],
                                                                              NSParagraphStyleAttributeName: paragraphStyle}];
    NSAttributedString *lineTwo = [[NSAttributedString alloc] initWithString:@"With style, using NSAttributedString"
                                                                 attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:18],
                                                                              NSForegroundColorAttributeName: [UIColor colorWithRed:0.46 green:0.8 blue:1.0 alpha:1.0],
                                                                              NSParagraphStyleAttributeName: paragraphStyle}];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.numberOfLines = 0;
    titleLabel.attributedText = title;
    
    UILabel *lineOneLabel = [[UILabel alloc] init];
    lineOneLabel.numberOfLines = 0;
    lineOneLabel.attributedText = lineOne;
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithColor:[UIColor randomColor]]];
    imageView.size = CGSizeMake(150, 160);
    imageView.layer.cornerRadius = 8;
    imageView.clipsToBounds = YES;
    imageView.userInteractionEnabled = YES;
    __weak UIImageView *weakImageView = imageView;
    [imageView setTapActionWithBlock:^{
        @strongify(self);
        UIImageView *strongImageView = weakImageView;
        if (!strongImageView) return;
        [self.popup updateLayoutWithChanges:^{
            strongImageView.height += 40;
        }];
    }];
    
    UILabel *lineTwoLabel = [[UILabel alloc] init];
    lineTwoLabel.numberOfLines = 0;
    lineTwoLabel.attributedText = lineTwo;
    
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 55)];
    customView.backgroundColor = [UIColor colorWithWhite:0.94 alpha:1];
    customView.layer.cornerRadius = 8;
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, 230, 35)];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.placeholder = @"Custom view!";
    [customView addSubview:textField];
    
    UIButton *closeButton = [self closeButton];
    
    ZKPopupTheme *theme = [ZKPopupTheme defaultTheme];
    theme.popupStyle = ZKPopupStyleActionSheet;
    theme.maxPopupWidth = ZKScreenSize().width;
    theme.cornerRadius = 16;
    [self presentPopupWithTheme:theme contents:@[titleLabel, lineOneLabel, imageView, lineTwoLabel, customView, closeButton]];
}

#pragma mark - Helpers

- (void)presentPopupWithTheme:(ZKPopupTheme *)theme contents:(NSArray<UIView *> *)contents {
    self.popup = [[ZKPopupController alloc] initWithContents:contents];
    self.popup.theme = theme;
    self.popup.delegate = self;
    [self.popup presentPopupControllerAnimated:YES];
}

- (UILabel *)labelWithText:(NSString *)text font:(UIFont *)font color:(UIColor *)color {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = font;
    label.textColor = color;
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    label.preferredMaxLayoutWidth = 260;
    return label;
}

- (UIButton *)closeButton {
    @weakify(self);
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 200, 48)];
    [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    [button setTitle:@"关闭" forState:UIControlStateNormal];
    button.backgroundColor = [UIColor colorWithRed:0.46 green:0.8 blue:1.0 alpha:1.0];
    button.layer.cornerRadius = 8;
    [button addBlockForControlEvents:UIControlEventTouchUpInside block:^(__kindof UIControl *sender) {
        @strongify(self);
        [self.popup dismissPopupControllerAnimated:YES];
    }];
    return button;
}

#pragma mark - ZKPopupControllerDelegate

- (void)popupControllerWillPresent:(ZKPopupController *)controller {
    ZKLog(@"popup will present");
}

- (void)popupControllerDidPresent:(ZKPopupController *)controller {
    ZKLog(@"popup did present");
}

- (void)popupControllerWillDismiss:(ZKPopupController *)controller {
    ZKLog(@"popup will dismiss");
}

- (void)popupControllerDidDismiss:(ZKPopupController *)controller {
    ZKLog(@"popup did dismiss");
    self.popup = nil;
}

@end
