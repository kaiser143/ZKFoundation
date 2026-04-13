//
//  ZKMarqueeLabel.h
//  ZKFoundation
//
//  跑马灯 UILabel：文本超出可视区域时横向循环滚动，支持速度与边缘停顿等参数。
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 简易跑马灯标签：文字超过可视宽度时自动滚动，首尾衔接（类似锁屏音乐标题）。
 *
 * @warning `lineBreakMode` 默认为 `NSLineBreakByClipping`（系统 UILabel 默认为 `NSLineBreakByTruncatingTail`）。
 * @warning `textAlignment` 不支持 `NSTextAlignmentJustified` 与 `NSTextAlignmentNatural`。
 * @warning 会忽略 `numberOfLines`，始终单行显示。
 */
@interface ZKMarqueeLabel : UILabel

/// 滚动速度：每帧移动的 pt 数，默认 0.5（与系统锁屏标题接近）。
@property (nonatomic, assign) IBInspectable CGFloat speed;

/// 首次显示及每次滚回起点时的停顿时长（秒），默认 2.5。
@property (nonatomic, assign) IBInspectable NSTimeInterval pauseDurationWhenMoveToEdge;

/// 首尾衔接两段文字之间的间距（pt），默认 40。
@property (nonatomic, assign) IBInspectable CGFloat spacingBetweenHeadToTail;

/// 左右渐变区域占宽度比例，默认 0.2（20%）。
@property (nonatomic, assign) IBInspectable CGFloat fadeWidthPercent;

/**
 * 是否在 `frame` 超出当前 `UIWindow` 可视范围时自动停止动画，默认 YES。
 * @warning 若仅调整 `superview` 的 frame 而不改 label 自身 frame，可能无法触发检测。
 */
@property (nonatomic, assign) IBInspectable BOOL automaticallyValidateVisibleFrame;

/// 是否在左右边缘显示渐变遮罩，默认 YES。
@property (nonatomic, assign) IBInspectable BOOL shouldFadeAtEdge;

/**
 * YES：在开启 `shouldFadeAtEdge` 时，文字从左侧渐变区域之后开始绘制；NO：始终从 label 左边缘开始。默认 NO。
 * @note 若文字宽度未超出（无需滚动），不会出现渐变，该属性不影响布局。
 */
@property (nonatomic, assign) IBInspectable BOOL textStartAfterFade;

@end


/**
 * 在可复用容器（如 UITableViewCell、UICollectionViewCell）中使用时，需在合适的显示/隐藏时机手动启停动画；普通 UIView 中一般无需处理。
 */
@interface ZKMarqueeLabel (ReusableView)

/// 尝试开始滚动动画，返回是否实际开启。
- (BOOL)requestToStartAnimation;

/// 尝试停止滚动动画，返回是否已处理停止。
- (BOOL)requestToStopAnimation;

@end


@interface UILabel (ZKMarquee)

/**
 * 使用系统私有跑马灯 API（仅开/关，无法控制速度与停顿；性能通常优于 `ZKMarqueeLabel`）。
 *
 * @code
 * [label kai_startNativeMarquee];
 * [label kai_stopNativeMarquee];
 * @endcode
 *
 * @note 会强制 `numberOfLines = 1`、`clipsToBounds = YES`。在 cell 中请在 will display 时 start、did end display 时 stop。
 */
- (void)kai_startNativeMarquee;

/// 停止系统跑马灯；可与 `kai_startNativeMarquee` 不成对调用。
- (void)kai_stopNativeMarquee;

/// 系统跑马灯是否正在运行。
@property (nonatomic, assign, readonly) BOOL kai_nativeMarqueeRunning;

@end

NS_ASSUME_NONNULL_END
