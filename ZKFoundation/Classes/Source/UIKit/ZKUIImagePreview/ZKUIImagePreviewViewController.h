//
//  ZKUIImagePreviewViewController.h
//  ZKFoundation
//
//  Created by zhangkai on 2026/3/19.
//

#import <UIKit/UIKit.h>
#import "ZKUIImagePreviewView.h"

NS_ASSUME_NONNULL_BEGIN

@class ZKUIImagePreviewViewTransitionAnimator;

typedef NS_ENUM(NSUInteger, ZKUIImagePreviewViewControllerTransitioningStyle) {
    /// present 整页淡入，dismiss 整页淡出（默认）
    ZKUIImagePreviewViewControllerTransitioningStyleFade,
    /// 从 sourceImageView / sourceImageRect 缩放进入/退出
    ZKUIImagePreviewViewControllerTransitioningStyleZoom
};

extern const CGFloat ZKUIImagePreviewViewControllerCornerRadiusAutomaticDimension;

/**
 * 图片预览控制器。核心浏览能力由 imagePreviewView 提供。
 *
 * 使用方式：
 * 1. init
 * 2. 设置 imagePreviewView.delegate
 * 3. push 或 present。present 时支持 Fade / Zoom；Zoom 需提供 sourceImageView 或 sourceImageRect
 */
@interface ZKUIImagePreviewViewController : UIViewController <UIViewControllerTransitioningDelegate>

@property (nonatomic, strong, nullable) UIColor *backgroundColor;
@property (nonatomic, strong, readonly) ZKUIImagePreviewView *imagePreviewView;

@property (nonatomic, strong, nullable) __kindof ZKUIImagePreviewViewTransitionAnimator *transitioningAnimator;
@property (nonatomic, assign) ZKUIImagePreviewViewControllerTransitioningStyle presentingStyle;
@property (nonatomic, assign) ZKUIImagePreviewViewControllerTransitioningStyle dismissingStyle;

/// Zoom 动画起点/终点 view；与 sourceImageRect 同时存在时优先用 rect
@property (nonatomic, copy, nullable) UIView * _Nullable (^sourceImageView)(void);
/// Zoom 动画起点/终点 rect（需已转到合适坐标系）
@property (nonatomic, copy, nullable) CGRect (^sourceImageRect)(void);
/// Zoom 圆角，默认 AutomaticDimension（从 sourceImageView.layer.cornerRadius 读取）
@property (nonatomic, assign) CGFloat sourceImageCornerRadius;

/// 是否支持下拉退出，默认 YES（仅 present）
@property (nonatomic, assign) BOOL dismissingGestureEnabled;

@end

NS_ASSUME_NONNULL_END
