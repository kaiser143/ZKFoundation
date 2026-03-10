//
//  ZKLoadingSpinner.h
//  ZKFoundation
//
//  Created by Kaiser on 2019/4/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/** 旋转方向 */
typedef NS_ENUM(NSUInteger, ZKRotationDirection) {
    ZKRotationDirectionClockwise,        ///< 顺时针
    ZKRotationDirectionCounterClockwise, ///< 逆时针
};

@interface ZKLoadingSpinner : UIView

/** 旋转方向，默认为顺时针 */
@property (nonatomic, assign) ZKRotationDirection rotationDirection;

/**
 * 未在动画时绘制的弧长（弧度）。
 * 可用于实现类似下拉刷新中静止时的弧线效果。
 */
@property (nonatomic, assign) CGFloat staticArcLength;

/** 弧线收缩时的最小弧长（弧度） */
@property (assign) CGFloat minimumArcLength;

/** 弧线展开时的最大弧长（弧度） */
@property (assign) CGFloat maximumArcLength;

/** 弧线线条宽度 */
@property (nonatomic) CGFloat lineWidth;

/**
 * 旋转一圈（360 度）所需时间（秒）。
 * 为匀速旋转，无缓动。
 */
@property (assign) CFTimeInterval rotationCycleDuration;

/**
 * 弧线画满一整圈或擦除一整圈所需时间（秒）。
 * 使用 in-out 缓动。
 */
@property (assign) CFTimeInterval drawCycleDuration;

/** 绘制弧线时使用的时间曲线（如加速/减速） */
@property (strong) CAMediaTimingFunction *drawTimingFunction;

/**
 * 弧线颜色序列（UIColor 数组），按顺序循环使用。
 * 最后一色播完后会回到第一种颜色。
 */
@property (strong) NSArray<UIColor *> *colorSequence UI_APPEARANCE_SELECTOR;

/** 弧线背后轨道（背景圆环）的颜色，默认为透明 */
@property (nonatomic) UIColor *backgroundRailColor;

/** 当前是否正在动画中 */
@property (readonly) BOOL isAnimating;

/** 开始旋转动画 */
- (void)startAnimating;

/** 停止动画并清空绘制 */
- (void)stopAnimating;

@end

NS_ASSUME_NONNULL_END
