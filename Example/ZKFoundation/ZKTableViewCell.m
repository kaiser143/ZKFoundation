//
//  ZKTableViewCell.m
//  ZKFoundation
//
//  Created by zhangkai on 2020/2/19.
//  Copyright © 2020 zhangkai. All rights reserved.
//

#import "ZKTableViewCell.h"

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

@interface ZKTableViewCell ()

// 解决cell默认高度跟AutoLayout的冲突
@property (nonatomic, strong) UIView *edgeView;
@property (nonatomic, assign) BOOL hasInstalledConstraints;
@property (nonatomic, assign, readonly) UIEdgeInsets safeArea;

@end

@implementation ZKTableViewCell

@dynamic safeArea;

#pragma mark - Initializer

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self == nil) return nil;
    
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
    
    return self;
}

#pragma mark - :. ZKTableViewHelperInjectionDelegate

- (void)bindViewModel:(id)viewModel forIndexPath:(NSIndexPath *)indexPath {
    // 禁用 sizeThatFits 来计算高度
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


@end
