//
//  ZKButton.h
//  ZKFoundation
//
//  Created by Kaiser on 2019/3/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ZKButtonImagePosition) {
    ZKButtonImagePositionTop,
    ZKButtonImagePositionLeft,
    ZKButtonImagePositionRight,
    ZKButtonImagePositionBottom
};

/**
 *  用于 `ZKButton.cornerRadius` 属性，当 `cornerRadius` 为 `ZKButtonCornerRadiusAdjustsBounds` 时，`ZKButton` 会在高度变化时自动调整 `cornerRadius`，使其始终保持为高度的 1/2。
 */
extern const CGFloat ZKButtonCornerRadiusAdjustsBounds;

/**
 *  提供以下功能：
 *  1. 支持让文字和图片自动跟随 tintColor 变化（系统的 UIButton 默认是不响应 tintColor 的）。
 *  2. 支持自动将圆角值保持为按钮高度的一半。
 *  3. highlighted、disabled 状态均通过改变整个按钮的 alpha 来表现，无需分别设置不同 state 下的 titleColor、image。alpha 的值可通过 ZKButton.highlightedAlpha、ZKButton.disabledAlpha 在 App 启动时统一设置。
 *  4. 支持点击时改变背景色颜色（highlightedBackgroundColor）或边框颜色（highlightedBorderColor）。
 *  5. 支持设置图片相对于 titleLabel 的位置（imagePosition）。
 *  6. 支持设置图片和 titleLabel 之间的间距，无需自行调整 titleEdgeInests、imageEdgeInsets（spacingBetweenImageAndTitle）。
 *  @warning ZKButton 重新定义了 UIButton.titleEdgeInests、imageEdgeInsets、contentEdgeInsets 这三者的布局逻辑，sizeThatFits: 里会把 titleEdgeInests 和 imageEdgeInsets 也考虑在内（UIButton 不会），以使这三个接口的使用更符合直觉。
 */
@interface ZKButton : UIButton

/**
 * ZKButton 在 highlighted 时的全局 alpha，默认 0.5。
 * 可在 App 启动时通过 setter 设置一次，之后所有 ZKButton 实例都会使用该值。
 */
@property (class, nonatomic, assign) CGFloat highlightedAlpha;

/**
 * ZKButton 在 disabled 时的全局 alpha，默认 0.5。
 * 可在 App 启动时通过 setter 设置一次，之后所有 ZKButton 实例都会使用该值。
 */
@property (class, nonatomic, assign) CGFloat disabledAlpha;

/**
 * 让按钮的文字颜色自动跟随 tintColor 调整（系统默认 titleColor 是不跟随的）<br/>
 * 默认为 NO
 */
@property (nonatomic, assign) IBInspectable BOOL adjustsTitleTintColorAutomatically;

/**
 * 让按钮的图片颜色自动跟随 tintColor 调整（系统默认 image 是需要更改 renderingMode 才可以达到这种效果）<br/>
 * 默认为 NO
 */
@property (nonatomic, assign) IBInspectable BOOL adjustsImageTintColorAutomatically;

/**
 *  等价于 adjustsTitleTintColorAutomatically = YES & adjustsImageTintColorAutomatically = YES & tintColor = xxx
 *  @warning 不支持传 nil
 */
@property (nonatomic, strong) IBInspectable UIColor *tintColorAdjustsTitleAndImage;

/**
 * 是否自动调整 highlighted 时的按钮样式，默认为 YES。<br/>
 * 当值为 YES 时，按钮 highlighted 时会改变自身的 alpha 属性为 ZKButton.highlightedAlpha
 */
@property (nonatomic, assign) IBInspectable BOOL adjustsButtonWhenHighlighted;

/**
 * 是否自动调整 disabled 时的按钮样式，默认为 YES。<br/>
 * 当值为 YES 时，按钮 disabled 时会改变自身的 alpha 属性为 ZKButton.disabledAlpha
 */
@property (nonatomic, assign) IBInspectable BOOL adjustsButtonWhenDisabled;

/**
 * 设置按钮点击时的背景色，默认为 nil。
 * @warning 不支持带透明度的背景颜色。当设置 highlightedBackgroundColor 时，会强制把 adjustsButtonWhenHighlighted 设为 NO，避免两者效果冲突。
 * @see adjustsButtonWhenHighlighted
 */
@property (nonatomic, strong, nullable) IBInspectable UIColor *highlightedBackgroundColor;

/**
 * 设置按钮点击时的边框颜色，默认为 nil。
 * @warning 当设置 highlightedBorderColor 时，会强制把 adjustsButtonWhenHighlighted 设为 NO，避免两者效果冲突。
 * @see adjustsButtonWhenHighlighted
 */
@property (nonatomic, strong, nullable) IBInspectable UIColor *highlightedBorderColor;

@property (nonatomic, assign) ZKButtonImagePosition imagePosition;

/**
 * 设置按钮里图标和文字之间的间隔，会自动响应 imagePosition 的变化而变化，默认为0。<br/>
 * 系统默认实现需要同时设置 titleEdgeInsets 和 imageEdgeInsets，同时还需考虑 contentEdgeInsets 的增加（否则不会影响布局，可能会让图标或文字溢出或挤压），使用该属性可以避免以上情况。<br/>
 * @warning 会与 imageEdgeInsets、 titleEdgeInsets、 contentEdgeInsets 共同作用。
 */
@property (nonatomic, assign) IBInspectable CGFloat spacingBetweenImageAndTitle;

@property (nonatomic, assign) IBInspectable CGFloat cornerRadius UI_APPEARANCE_SELECTOR; // 默认为 0。将其设置为 ZKButtonCornerRadiusAdjustsBounds 可自动保持圆角为按钮高度的一半。

@end

NS_ASSUME_NONNULL_END
