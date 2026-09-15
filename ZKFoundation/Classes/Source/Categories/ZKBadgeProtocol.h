//
//  ZKBadgeProtocol.h
//  ZKFoundation
//
//  Created by Kaiser on 2026/6/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Badge 能力协议，与具体载体（UIView / UIBarItem 等）解耦。
 
 业务层面向协议编程：- (void)showDotOn:(id<ZKBadgeProtocol>)badgeable;
 后续新增载体只需为其新建 Category 并遵从该协议，无需改动调用方。
 
 @note 未主动设置样式时，会在首次展示时应用一组合理默认值（红底白字、bold 11、红点 7pt 等）。
 */
@protocol ZKBadgeProtocol <NSObject>

#pragma mark - Badge

/// 用数字设置未读数，0 表示不显示未读数
@property (nonatomic, assign) NSUInteger kai_badgeInteger;

/// 用字符串设置未读数，nil 表示不显示未读数
@property (nonatomic, copy, nullable) NSString *kai_badgeString;

@property (nonatomic, strong, nullable) UIColor *kai_badgeBackgroundColor; ///< 未读数背景色，默认 [UIColor redColor]。
@property (nonatomic, strong, nullable) UIColor *kai_badgeTextColor; ///< 未读数文字颜色，默认 [UIColor whiteColor]。
@property (nonatomic, strong, nullable) UIFont *kai_badgeFont; ///< 未读数字体，默认 [UIFont boldSystemFontOfSize:11]。

/// 未读数字与圆圈之间的 padding，会影响最终 badge 大小。一位数字时取宽/高较大值，保证正圆。默认 UIEdgeInsetsMake(2, 4, 2, 4)。
@property (nonatomic, assign) UIEdgeInsets kai_badgeContentEdgeInsets;

/// 自定义圆角半径。默认值为 -1，表示未设置，此时沿用现有自适应方案（MIN(width / 2, height / 2)，一位数字正圆、多位胶囊）；
/// 设为 >= 0 则固定使用该值（0 为直角），不再随 size 自适应；设为负值则恢复自适应。
@property (nonatomic, assign) CGFloat kai_badgeCornerRadius;

/// 默认布局在 view 右上角（x = view.width, y = -badge height），通过该属性相对默认原点偏移；x 正值向右，y 正值向下。默认 CGPointMake(-9, 11)。
@property (nonatomic, assign) CGPoint kai_badgeOffset;

/// 横屏下使用，含义同 kai_badgeOffset。默认 CGPointMake(-9, 6)。
@property (nonatomic, assign) CGPoint kai_badgeOffsetLandscape;

@property (nonatomic, strong, readonly, nullable) UILabel *kai_badgeLabel; ///< 当前展示的未读数 label，由 kai_badgeString 生成，仅读取。

#pragma mark - UpdatesIndicator

/// 控制红点显隐
@property (nonatomic, assign) BOOL kai_shouldShowUpdatesIndicator;
@property (nonatomic, strong, nullable) UIColor *kai_updatesIndicatorColor; ///< 红点颜色，默认 [UIColor redColor]。
@property (nonatomic, assign) CGSize kai_updatesIndicatorSize; ///< 红点尺寸，默认 CGSizeMake(7, 7)。

/// 默认布局在 view 右上角（x = view.width, y = -indicator height），通过该属性相对默认原点偏移。默认 CGPointMake(4, 7)。
@property (nonatomic, assign) CGPoint kai_updatesIndicatorOffset;

/// 横屏下使用，含义同 kai_updatesIndicatorOffset。默认同 kai_updatesIndicatorOffset。
@property (nonatomic, assign) CGPoint kai_updatesIndicatorOffsetLandscape;

@property (nonatomic, strong, readonly, nullable) UIView *kai_updatesIndicatorView; ///< 当前展示的红点视图，由 kai_shouldShowUpdatesIndicator 生成，仅读取。

@end

NS_ASSUME_NONNULL_END
