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
 *  1. 支持自动将圆角值保持为按钮高度的一半。
 *  2. 支持设置图片相对于 titleLabel 的位置（imagePosition）。
 *  3. 支持设置图片和 titleLabel 之间的间距，无需自行调整 titleEdgeInests、imageEdgeInsets（spacingBetweenImageAndTitle）。
 *  @warning ZKButton 重新定义了 UIButton.titleEdgeInests、imageEdgeInsets、contentEdgeInsets 这三者的布局逻辑，sizeThatFits: 里会把 titleEdgeInests 和 imageEdgeInsets 也考虑在内（UIButton 不会），以使这三个接口的使用更符合直觉。
 */
@interface ZKButton : UIButton

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
