//
//  ZKZoomImageView.h
//  ZKFoundation
//
//  Created by zhangkai on 2026/3/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ZKZoomImageView;

@protocol ZKZoomImageViewDelegate <NSObject>
@optional
/// 单击图片时回调。location 为点击位置，坐标系为 zoomImageView。
- (void)singleTouchInZoomingImageView:(ZKZoomImageView *)zoomImageView location:(CGPoint)location;
/// 双击图片时回调，会在内置缩放动画之前触发。location 为点击位置，坐标系为 zoomImageView。
- (void)doubleTouchInZoomingImageView:(ZKZoomImageView *)zoomImageView location:(CGPoint)location;
/// 长按图片时回调，仅在 `-enabledZoomViewInZoomImageView:` 返回 YES 时触发。
- (void)longPressInZoomingImageView:(ZKZoomImageView *)zoomImageView;
/// 是否允许缩放、拖动及长按。未实现时默认在有图片（`image != nil`）时返回 YES。
- (BOOL)enabledZoomViewInZoomImageView:(ZKZoomImageView *)zoomImageView;
@end

/**
 * 支持双击缩放、单击/长按回调的图片预览控件。
 * 主要用于 ZKUIImagePreviewView 内部 cell。
 */
@interface ZKZoomImageView : UIView <UIScrollViewDelegate>

@property (nonatomic, weak, nullable) id<ZKZoomImageViewDelegate> delegate;
@property (nonatomic, strong, readonly) UIScrollView *scrollView;
@property (nonatomic, strong, readonly) UIImageView *imageView;
@property (nonatomic, strong, readonly, nullable) UIView *contentView;

/// 当前图片。设置后会清空 loading 状态并重置缩放。
@property (nonatomic, strong, nullable) UIImage *image;

/// 最大缩放倍数，默认 2.0
@property (nonatomic, assign) CGFloat maximumZoomScale;

/// cell 复用标识，异步加载时用于校验
@property (nonatomic, copy, nullable) id reusedIdentifier;

/// loading 指示器颜色，默认白色
@property (nonatomic, strong) UIColor *loadingColor;

- (CGRect)contentViewRectInZoomImageView;
- (void)revertZooming;
- (void)prepareForTransition;
- (void)showLoading;
- (void)hideEmptyView;

@end

NS_ASSUME_NONNULL_END
