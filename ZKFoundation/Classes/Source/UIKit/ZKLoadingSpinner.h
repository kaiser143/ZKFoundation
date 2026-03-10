//
//  ZKLoadingSpinner.h
//  ZKFoundation
//
//  Created by Kaiser on 2019/4/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ZKRotationDirection) {
    ZKRotationDirectionClockwise,
    ZKRotationDirectionCounterClockwise,
};

@interface ZKLoadingSpinner : UIView

/**
 *  @brief 加载器旋转的方向。默认为顺时针。
 */
@property (nonatomic, assign) ZKRotationDirection rotationDirection;

/**
 *  @brief 当加载器未处于动画状态时，要绘制的弧的长度。这可以
 *         用于实现类似 DRPRefreshControl 中的下拉刷新功能。
 */
@property (nonatomic, assign) CGFloat staticArcLength;

/**
 @brief 当弧线缩小时，它最小应达到的弧度值。
 */
@property (assign) CGFloat minimumArcLength;

/**
 *  @brief 当弧线增长时，它最大应达到的弧度值。
 */
@property (assign) CGFloat maximumArcLength;

/**
 *  @brief 弧线的线宽。
 */
@property (nonatomic) CGFloat lineWidth;

/**
 @brief 绘图旋转 360 度所需的时间（秒）。
 此持续时间不应用缓动函数，即为线性变化。
 */
@property (assign) CFTimeInterval rotationCycleDuration;

/**
 @brief 绘制或擦除一个完整圆所需的时间（秒）。
 此持续时间应用了缓入缓出函数。
 */
@property (assign) CFTimeInterval drawCycleDuration;

/**
 @brief 用于绘制轨道的计时函数。
 */
@property (strong) CAMediaTimingFunction *drawTimingFunction;

/**
 @brief 一个 UIColor 数组，定义了加载器将绘制的颜色
 及其顺序。当最后一个颜色的循环完成后，颜色将循环回到开头。
 */
@property (strong) NSArray<UIColor *> *colorSequence UI_APPEARANCE_SELECTOR;

/**
 @brief 加载器后面轨道的颜色。默认为透明色。
 */
@property (nonatomic) UIColor *backgroundRailColor;

/**
 @return 如果加载器正在动画，则为 YES，否则为 NO
 */
@property (readonly) BOOL isAnimating;

/**
 @brief 开始动画。
 */
- (void)startAnimating;

/**
 @brief 停止动画并清除绘图上下文。
 */
- (void)stopAnimating;

@end

NS_ASSUME_NONNULL_END
