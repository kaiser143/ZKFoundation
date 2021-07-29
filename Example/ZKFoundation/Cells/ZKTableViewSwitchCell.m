//
//  ZKTableViewSwitchCell.m
//  ZKFoundation
//
//  Created by zhangkai on 2021/7/28.
//  Copyright © 2021 zhangkai. All rights reserved.
//

#import "ZKTableViewSwitchCell.h"

#if __has_include(<ZKCategories/ZKCategories.h>)
#import <ZKCategories/ZKCategories.h>
#else
#import "ZKCategories.h"
#endif

#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif

//#if __has_include(<UITableView_FDTemplateLayoutCell/UITableView+FDTemplateLayoutCell.h>)
//#import <UITableView_FDTemplateLayoutCell/UITableView+FDTemplateLayoutCell.h>
//#else
//#import "UITableView+FDTemplateLayoutCell.h"
//#endif

#import "ZKSwitchItemViewModel.h"

@interface ZKTableViewSwitchCell ()

// 解决cell默认高度跟AutoLayout的冲突
@property (nonatomic, strong) UIView *edgeView;
@property (nonatomic, strong) UISwitch *switcher;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, assign) BOOL hasInstalledConstraints;
@property (nonatomic, assign, readonly) UIEdgeInsets safeArea;

@end

@implementation ZKTableViewSwitchCell

@dynamic safeArea;

#pragma mark - Initializer

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self == nil) return nil;
    
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
    
    return self;
}

#pragma mark - :. ZKTableViewAdapterInjectionDelegate

- (void)bindViewModel:(ZKSwitchItemViewModel *)viewModel forIndexPath:(NSIndexPath *)indexPath {
    // 禁用 sizeThatFits 来计算高度
//    self.fd_enforceFrameLayout = NO;
    
    self.textLabel.text = viewModel.title;
    self.switcher.on = viewModel.on;
    self.indexPath = indexPath;
}

#pragma mark - Private Methods

- (void)updateConstraints {
    if (!self.hasInstalledConstraints) {
        self.hasInstalledConstraints = YES;
        
        [self.edgeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView).insets(self.safeArea).priorityHigh();
        }];
    }
    
    [super updateConstraints];
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat height = [self.edgeView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height + self.safeArea.top + self.safeArea.bottom;
    return CGSizeMake(size.width, height);
}

//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    [self.edgeView performSelector:@selector(setBackgroundColor:) withObject:<#color#> afterDelay:0.15];
//    self.edgeView.backgroundColor = <#color#>;
//    [super touchesBegan:touches withEvent:event];
//}
//
//- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    [self touchesRestoreBackgroundColor];
//    [super touchesEnded:touches withEvent:event];
//}
//
//- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    [self touchesRestoreBackgroundColor];
//    [super touchesCancelled:touches withEvent:event];
//}
//
//- (void)touchesRestoreBackgroundColor {
//    [NSObject cancelPreviousPerformRequestsWithTarget:self.edgeView selector:@selector(setBackgroundColor:) object:<#color#>];
//    self.edgeView.backgroundColor = UIColor.whiteColor;
//}

#pragma mark - :. getters and setters

- (UIView *)edgeView {
    if (!_edgeView) {
        _edgeView = [[UIView alloc] init];
        
        [self.contentView addSubview:_edgeView];
    }
    
    return _edgeView;
}

- (UIEdgeInsets)safeArea {
    return UIEdgeInsetsZero;
}

- (UISwitch *)switcher {
    if (!_switcher) {
        @weakify(self);
        _switcher = UISwitch.new;
        _switcher.on = NO;
        [_switcher addBlockForControlEvents:UIControlEventValueChanged block:^(__kindof UISwitch * _Nonnull sender) {
            @strongify(self);
            [self sendEventWithName:@"valueChanged" userInfo:@{@"index": self.indexPath, @"value": @(sender.on)}];
        }];
        self.accessoryView = _switcher;
    }
    return _switcher;
}

@end
