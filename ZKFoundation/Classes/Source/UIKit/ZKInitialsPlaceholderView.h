//
//  ZKInitialsPlaceholderView.h
//  ZKFoundation
//
//  Created by Kaiser on 2019/4/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 用于绘制占位图的视图：在圆形背景上显示指定首字母（如群聊头像）。
 * 效果类似 iMessage 群聊中的联系人占位头像（iOS 7.0+）。
 */
@interface ZKInitialsPlaceholderView : UIView

/**
 * 绘制首字母时使用的字体。
 * @note 字号会根据视图的 frame 自动计算，此处设置的 size 不生效。默认为 [UIFont boldSystemFontOfSize:16]。
 */
@property (strong) UIFont *font;

/**
 * 首字母文字颜色。
 * @note 默认为 [UIColor whiteColor]。
 */
@property (strong) UIColor *textColor;

/**
 * 背景圆的填充颜色。
 * @note 默认为 [UIColor lightGrayColor]。
 */
@property (strong) UIColor *circleColor;

/**
 * 要显示的首字母字符串。
 * @note 若超过 2 个字符会被截断为 2 个字符。
 */
@property (strong) NSString *initials;

/**
 * 指定初始化方法，用直径创建视图（使用其他初始化方法会产生未定义行为）。
 */
- (instancetype)initWithDiameter:(CGFloat)diameter NS_DESIGNATED_INITIALIZER;

/**
 * 一次性设置首字母、圆色、文字色、字体，只触发一次重绘（避免多次单独设置属性导致多次绘制）。
 * circleColor、textColor、font 可传 nil。
 */
- (void)batchUpdateViewWithInitials:(NSString *)initials circleColor:(UIColor *)circleColor textColor:(UIColor *)textColor font:(UIFont *)font;

@end

NS_ASSUME_NONNULL_END
