//
//  ZKUIImagePreviewViewTransitionAnimator.h
//  ZKFoundation
//
//  Created by zhangkai on 2026/3/19.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ZKUIImagePreviewViewController.h"

NS_ASSUME_NONNULL_BEGIN

/**
 负责处理 ZKUIImagePreviewViewController 被 present/dismiss 时的动画，如果需要自定义动画效果，可按需修改 animationEnteringBlock、animationBlock、animationCompletionBlock。
 @see ZKUIImagePreviewViewController.transitioningAnimator
 */
@interface ZKUIImagePreviewViewTransitionAnimator : NSObject <UIViewControllerAnimatedTransitioning>

/// 当前图片预览控件的引用，在为 ZKUIImagePreviewViewController.transitioningAnimator 赋值时会自动建立这个引用关系
@property (nonatomic, weak, nullable) ZKUIImagePreviewViewController *imagePreviewViewController;

/// 转场动画的持续时长，默认为 0.25
@property (nonatomic, assign) NSTimeInterval duration;

/// 当 sourceImageView 本身带圆角时，动画过程中会通过这个 layer 来处理圆角的动画
@property (nonatomic, strong, readonly) CALayer *cornerRadiusMaskLayer;

/**
 动画开始前的准备工作可以在这里做

 @param animator 当前的动画器 animator
 @param isPresenting YES 表示当前正在 present，NO 表示正在 dismiss
 @param style 当前动画的样式
 @param sourceImageRect 原界面上显示图片的 view 在 imagePreviewViewController.view 坐标系里的 rect，仅在 style 为 zoom 时有值，style 为 fade 时为 CGRectZero
 @param zoomImageView 当前图片
 @param transitionContext 转场动画的上下文，可通过它获取前后界面、动画容器等信息
 */
@property (nonatomic, copy, nullable) void (^animationEnteringBlock)(__kindof ZKUIImagePreviewViewTransitionAnimator *animator, BOOL isPresenting, ZKUIImagePreviewViewControllerTransitioningStyle style, CGRect sourceImageRect, ZKZoomImageView * _Nullable zoomImageView, id<UIViewControllerContextTransitioning> _Nullable transitionContext);

/**
 转场时的实际动画内容，整个 block 会在一个 UIView animation block 里被调用，因此直接写动画内容即可，无需包裹一个 animation block

 @param animator 当前的动画器 animator
 @param isPresenting YES 表示当前正在 present，NO 表示正在 dismiss
 @param style 当前动画的样式
 @param sourceImageRect 原界面上显示图片的 view 在 imagePreviewViewController.view 坐标系里的 rect，仅在 style 为 zoom 时有值，style 为 fade 时为 CGRectZero
 @param zoomImageView 当前图片
 @param transitionContext 转场动画的上下文，可通过它获取前后界面、动画容器等信息
 */
@property (nonatomic, copy, nullable) void (^animationBlock)(__kindof ZKUIImagePreviewViewTransitionAnimator *animator, BOOL isPresenting, ZKUIImagePreviewViewControllerTransitioningStyle style, CGRect sourceImageRect, ZKZoomImageView * _Nullable zoomImageView, id<UIViewControllerContextTransitioning> _Nullable transitionContext);

/**
 动画结束后的事情，在执行完这个 block 后才会调用 [transitionContext completeTransition:]

 @param animator 当前的动画器 animator
 @param isPresenting YES 表示当前正在 present，NO 表示正在 dismiss
 @param style 当前动画的样式
 @param sourceImageRect 原界面上显示图片的 view 在 imagePreviewViewController.view 坐标系里的 rect，仅在 style 为 zoom 时有值，style 为 fade 时为 CGRectZero
 @param zoomImageView 当前图片
 @param transitionContext 转场动画的上下文，可通过它获取前后界面、动画容器等信息
 */
@property (nonatomic, copy, nullable) void (^animationCompletionBlock)(__kindof ZKUIImagePreviewViewTransitionAnimator *animator, BOOL isPresenting, ZKUIImagePreviewViewControllerTransitioningStyle style, CGRect sourceImageRect, ZKZoomImageView * _Nullable zoomImageView, id<UIViewControllerContextTransitioning> _Nullable transitionContext);

@end

NS_ASSUME_NONNULL_END
