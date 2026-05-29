//
//  ZKFloatLayoutView.h
//  ZKFoundation
//
//  Created by zhangkai on 2025/7/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 用于属性 maximumItemSize，是它的默认值。表示 item 的最大宽高会自动根据当前 floatLayoutView 的内容大小来调整，从而避免 item 内容过多时可能溢出 floatLayoutView。
extern const CGSize ZKUIFloatLayoutViewAutomaticalMaximumItemSize;

/**
 *  做类似 CSS 里的 float:left 的布局，自行使用 addSubview: 将子 View 添加进来即可。
 *  支持通过 `contentMode` 属性修改子 View 的对齐方式，目前仅支持 `UIViewContentModeLeft` 和 `UIViewContentModeRight`，默认为 `UIViewContentModeLeft`。
 *  支持 Auto Layout：可直接用约束固定宽度，高度会根据内容自适应；子 View 若使用 Auto Layout 构建，会通过 `systemLayoutSizeFittingSize:` 计算尺寸。
 *
 *  @code
     // Frame 布局
     - (void)viewDidLayoutSubviews {
         [super viewDidLayoutSubviews];

         UIEdgeInsets margins = UIEdgeInsetsMake(24, 24 + self.view.safeAreaInsets.left, 24, 24 + self.view.safeAreaInsets.right);
         CGFloat contentWidth = self.view.width - UIEdgeInsetsGetHorizontalValue(margins);
         NSInteger column = IS_IPAD || IS_LANDSCAPE ? self.images.count : 3;
         CGFloat imageWidth = contentWidth / column - (column - 1) * UIEdgeInsetsGetHorizontalValue(self.floatLayoutView.itemMargins);
         self.floatLayoutView.minimumItemSize = CGSizeMake(imageWidth, imageWidth);
         self.floatLayoutView.maximumItemSize = self.floatLayoutView.minimumItemSize;
         self.floatLayoutView.frame = CGRectMake(margins.left, margins.top, contentWidth, INFINITY);
     }
 *
 *  @code
     // Auto Layout 布局
     self.floatLayoutView.translatesAutoresizingMaskIntoConstraints = NO;
     [NSLayoutConstraint activateConstraints:@[
         [self.floatLayoutView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:24],
         [self.floatLayoutView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-24],
         [self.floatLayoutView.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:16],
     ]];
 *  @endcode
 */
@interface ZKFloatLayoutView : UIView

/**
 *  ZKFloatLayoutView 内部的间距，默认为 UIEdgeInsetsZero
 */
@property (nonatomic, assign) UIEdgeInsets padding;

/**
 *  item 的最小宽高，默认为 CGSizeZero，也即不限制。
 */
@property (nonatomic, assign) IBInspectable CGSize minimumItemSize;

/**
 *  item 的最大宽高，默认为 ZKUIFloatLayoutViewAutomaticalMaximumItemSize，也即不超过 floatLayoutView 自身最大内容宽高。
 */
@property (nonatomic, assign) IBInspectable CGSize maximumItemSize;

/**
 *  item 之间的间距，默认为 UIEdgeInsetsZero。
 *
 *  @warning 上、下、左、右四个边缘的 item 布局时不会考虑 itemMargins.top/bottom/left/right。
 */
@property (nonatomic, assign) UIEdgeInsets itemMargins;

@end

NS_ASSUME_NONNULL_END
