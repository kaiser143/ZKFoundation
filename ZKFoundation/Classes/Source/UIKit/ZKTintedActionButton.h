//
//  ZKTintedActionButton.h
//  ZKFoundation
//
//  Created by Kaiser on 2019/4/3.
//

#import <UIKit/UIKit.h>

/*!
 * A generic button that uses the view's tint color for background and highlight colors.
 * @code
 ZKTintedActionButton *action = [[ZKTintedActionButton alloc] initWithText:@"Continue"];
 action.tintColor = [UIColor redColor];
 // 如果需要，可以设置一个亮度偏移量，该偏移量将用于从默认颜色动态计算“点击”颜色
 action.tappedTintColorBrightnessOffset = -0.15;
 [<#view#> addSubview:action];
 * @endcode
 */

NS_ASSUME_NONNULL_BEGIN

@class ZKTintedActionButton;

NS_SWIFT_NAME(TintedActionButtonDelegate)
@protocol ZKTintedActionButtonDelegate <NSObject>

/// 当用户点击相关按钮时调用。
/// - 参数 button: 被点击的按钮对象。
- (void)tintedActionButtonDidTap:(ZKTintedActionButton *)button;

@end

NS_SWIFT_NAME(TintedActionButton)
IB_DESIGNABLE @interface ZKTintedActionButton : UIControl

/// 可以接收此按钮点击事件的代理对象。
@property (nonatomic, weak) id<ZKTintedActionButtonDelegate> delegate;

/// 此按钮的角半径（默认值为12.0f）。
@property (nonatomic, assign) IBInspectable CGFloat cornerRadius;

/// 管理此按钮中所有前景视图的容器。
/// 您可以默认将自定义视图添加到此视图中，或者可以将此属性设置为您自己的自定义UIView子类，以便更有效地管理大小和布局。
@property (nonatomic, strong, null_resettable) UIView *contentView;

/// 内容视图与按钮边缘之间的内边距量。
/// （默认值是每边15点的内边距）。
@property (nonatomic, assign) UIEdgeInsets contentInset;

/// 用模糊视图替换实心颜色背景。（默认值为NO）
@property (nonatomic, assign) BOOL isTranslucent;

/// 当 `isTranslucent` 为 `YES` 时，背景视图的模糊效果。
@property (nonatomic, assign) UIBlurEffectStyle blurStyle;

/// 按钮中心显示的文本（默认值为nil）。
@property (nonatomic, copy, nullable) IBInspectable NSString *text;

/// 此按钮标签中使用的属性字符串。
/// 请参阅 `UILabel.attributedText` 文档以获取完整详细信息（默认值为nil）。
@property (nonatomic, copy, nullable) NSAttributedString *attributedText;

/// 按钮中文本的颜色（默认值为白色）。
@property (nonatomic, strong) IBInspectable UIColor *textColor;

/// 按钮中文字的字体
/// （默认值为UIFontTextStyleBody加粗）。
@property (nonatomic, strong) UIFont *textFont;

/// 由于IB无法处理字体，这可以用于设置字体大小。
/// （默认值为关闭，大小为0.0）。
@property (nonatomic, assign) IBInspectable CGFloat textPointSize;

/// 点击时，文本标签动画的透明度级别。
/// （默认值为关闭，大小为1.0f）。
@property (nonatomic, assign) IBInspectable CGFloat tappedTextAlpha;

/// 将默认按钮背景颜色应用亮度偏移以获得点击颜色
/// （默认值为-0.1f。设置为0.0关闭）。
@property (nonatomic, assign) IBInspectable CGFloat tappedTintColorBrightnessOffset;

/// 如果需要，明确设置按钮点击时的背景颜色（默认值为nil）。
@property (nonatomic, strong, nullable) IBInspectable UIColor *tappedTintColor;

/// 点击时按钮缩放动画的缩放比例（默认值为0.97f）。
@property (nonatomic, assign) IBInspectable CGFloat tappedButtonScale;

/// 点击时的淡入淡出动画持续时间（默认值为0.4f）。
@property (nonatomic, assign) CGFloat tapAnimationDuration;

/// 每次点击按钮时触发的回调处理程序。
@property (nonatomic, copy) void (^tappedHandler)(void);

/// 创建一个新实例的按钮，可以进一步配置文本或自定义子视图。
/// 默认大小为宽288点，高50点。
- (instancetype)init;

/// 创建一个新实例的按钮，可以进一步配置文本或自定义子视图。
- (instancetype)initWithFrame:(CGRect)frame;

/// 创建一个带有中心文本的新实例按钮。
/// 默认大小为宽288点，高50点。
- (instancetype)initWithText:(NSString *)text;

/// 创建一个将提供的视图设置为托管内容视图的新实例按钮。
- (instancetype)initWithContentView:(__kindof UIView *)contentView;

/// 调整按钮大小以适应 `contentView` 中所有子视图的边界大小，加上内容内边距。
/// 如果子类化此类，请重写此方法以进行自定义大小控制（不要忘记包含内容内边距）。
/// 如果内容视图只包含一个子视图（如标题标签），或提供了自定义内容视图，也会将其转发给该视图。
/// 如果内容视图包含多个子视图，则会计算其边界大小，然后应用于此按钮。
- (void)sizeToFit;

/// 计算并返回此按钮需要适应所提供大小的适当最小尺寸。
/// 如果子类化此类，请重写此方法以进行自定义大小控制（不要忘记包含内容内边距）。
/// 如果内容视图只包含一个子视图（如标题标签），或提供了自定义内容视图，也会将其转发给该视图。
/// 如果内容视图包含多个子视图，则会计算其边界大小，然后应用于此按钮。
- (CGSize)sizeThatFits:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
