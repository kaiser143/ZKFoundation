//
//  ZKUIImagePreviewViewTransitionAnimator.m
//  ZKFoundation
//
//  Created by zhangkai on 2026/3/19.
//

#import "ZKUIImagePreviewViewTransitionAnimator.h"

static inline CGPoint ZKCenterOfRect(CGRect rect) {
    return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}

/// 根据图片尺寸与 contentMode 计算在 containerBounds 内的实际显示区域（bounds 坐标系）
static CGRect ZKUIImagePreviewRectForImage(UIImage *image, CGRect containerBounds, UIViewContentMode contentMode) {
    if (CGRectIsEmpty(containerBounds)) {
        return CGRectZero;
    }
    if (!image || image.size.width <= 0 || image.size.height <= 0) {
        return containerBounds;
    }
    
    if (contentMode == UIViewContentModeScaleToFill || contentMode == UIViewContentModeScaleAspectFill) {
        return containerBounds;
    }
    
    CGSize imageSize = image.size;
    CGSize displaySize = imageSize;
    
    if (contentMode == UIViewContentModeScaleAspectFit) {
        CGFloat scale = MIN(containerBounds.size.width / imageSize.width, containerBounds.size.height / imageSize.height);
        displaySize = CGSizeMake(imageSize.width * scale, imageSize.height * scale);
    } else if (contentMode == UIViewContentModeCenter ||
               contentMode == UIViewContentModeRedraw) {
        if (displaySize.width > containerBounds.size.width || displaySize.height > containerBounds.size.height) {
            CGFloat scale = MIN(containerBounds.size.width / displaySize.width, containerBounds.size.height / displaySize.height);
            displaySize = CGSizeMake(displaySize.width * scale, displaySize.height * scale);
        }
    } else {
        CGFloat scale = MIN(containerBounds.size.width / imageSize.width, containerBounds.size.height / imageSize.height);
        displaySize = CGSizeMake(imageSize.width * scale, imageSize.height * scale);
    }
    
    return CGRectMake(CGRectGetMinX(containerBounds) + (containerBounds.size.width - displaySize.width) / 2.0,
                      CGRectGetMinY(containerBounds) + (containerBounds.size.height - displaySize.height) / 2.0,
                      displaySize.width,
                      displaySize.height);
}

static CGRect ZKUIImagePreviewSourceRectForView(UIView *sourceView, UIView *targetView) {
    if (!sourceView || !targetView) {
        return CGRectZero;
    }
    
    [sourceView layoutIfNeeded];
    
    UIImage *image = nil;
    UIViewContentMode contentMode = UIViewContentModeScaleAspectFill;
    
    if ([sourceView isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)sourceView;
        image = [button imageForState:UIControlStateNormal];
        contentMode = button.imageView.contentMode;
        [button.imageView layoutIfNeeded];
        
        if (button.imageView.image && !CGRectIsEmpty(button.imageView.frame)) {
            CGRect imageRectInButton = button.imageView.frame;
            if (CGRectContainsRect(button.bounds, imageRectInButton) ||
                CGRectIntersectsRect(button.bounds, imageRectInButton)) {
                return [targetView convertRect:imageRectInButton fromView:button];
            }
        }
        
        CGRect displayRect = ZKUIImagePreviewRectForImage(image, button.bounds, contentMode);
        return [targetView convertRect:displayRect fromView:button];
    }
    
    if ([sourceView isKindOfClass:[UIImageView class]]) {
        UIImageView *imageView = (UIImageView *)sourceView;
        image = imageView.image;
        contentMode = imageView.contentMode;
        CGRect displayRect = ZKUIImagePreviewRectForImage(image, imageView.bounds, contentMode);
        return [targetView convertRect:displayRect fromView:imageView];
    }
    
    return [targetView convertRect:sourceView.bounds fromView:sourceView];
}

@implementation ZKUIImagePreviewViewTransitionAnimator

- (instancetype)init {
    self = [super init];
    if (self) {
        _duration = 0.25;
        _cornerRadiusMaskLayer = [CALayer layer];
        _cornerRadiusMaskLayer.actions = @{
            @"bounds": [NSNull null],
            @"position": [NSNull null],
            @"cornerRadius": [NSNull null],
            @"contents": [NSNull null]
        };
        _cornerRadiusMaskLayer.backgroundColor = [UIColor whiteColor].CGColor;
        
        self.animationEnteringBlock = ^(__kindof ZKUIImagePreviewViewTransitionAnimator *animator, BOOL isPresenting, ZKUIImagePreviewViewControllerTransitioningStyle style, CGRect sourceImageRect, ZKZoomImageView *zoomImageView, id<UIViewControllerContextTransitioning> transitionContext) {
            UIView *previewView = animator.imagePreviewViewController.view;
            
            if (style == ZKUIImagePreviewViewControllerTransitioningStyleFade) {
                previewView.alpha = isPresenting ? 0 : 1;
                return;
            }
            
            if (!zoomImageView || !zoomImageView.contentView) {
                previewView.alpha = isPresenting ? 0 : 1;
                return;
            }
            
            [zoomImageView prepareForTransition];
            
            CGRect contentViewFrame = [previewView convertRect:[zoomImageView contentViewRectInZoomImageView] fromView:zoomImageView];
            CGPoint contentViewCenterInZoomImageView = ZKCenterOfRect([zoomImageView contentViewRectInZoomImageView]);
            if (CGRectIsEmpty(contentViewFrame)) {
                contentViewFrame = [previewView convertRect:zoomImageView.bounds fromView:zoomImageView];
                contentViewCenterInZoomImageView = ZKCenterOfRect(zoomImageView.bounds);
            }
            
            CGPoint centerInZoomImageView = ZKCenterOfRect(zoomImageView.bounds);
            CGFloat horizontalRatio = CGRectGetWidth(sourceImageRect) / MAX(CGRectGetWidth(contentViewFrame), CGFLOAT_MIN);
            CGFloat verticalRatio = CGRectGetHeight(sourceImageRect) / MAX(CGRectGetHeight(contentViewFrame), CGFLOAT_MIN);
            CGFloat finalRatio = MAX(horizontalRatio, verticalRatio);
            
            CGAffineTransform transform = CGAffineTransformIdentity;
            transform = CGAffineTransformScale(transform, finalRatio, finalRatio);
            CGPoint contentViewCenterAfterScale = CGPointMake(centerInZoomImageView.x + (contentViewCenterInZoomImageView.x - centerInZoomImageView.x) * finalRatio,
                                                             centerInZoomImageView.y + (contentViewCenterInZoomImageView.y - centerInZoomImageView.y) * finalRatio);
            CGRect sourceImageRectInZoomImageView = [zoomImageView convertRect:sourceImageRect fromView:previewView];
            transform = CGAffineTransformConcat(transform, CGAffineTransformMakeTranslation(CGRectGetMidX(sourceImageRectInZoomImageView) - contentViewCenterAfterScale.x,
                                                                                              CGRectGetMidY(sourceImageRectInZoomImageView) - contentViewCenterAfterScale.y));
            
            CGAffineTransform fromTransform = isPresenting ? transform : CGAffineTransformIdentity;
            CGAffineTransform toTransform = isPresenting ? CGAffineTransformIdentity : transform;
            
            UIView *contentView = zoomImageView.contentView;
            CGRect maskFromBounds = contentView.bounds;
            CGRect maskToBounds = contentView.bounds;
            CGRect maskBounds = maskFromBounds;
            CGFloat maskHorizontalRatio = CGRectGetWidth(sourceImageRect) / MAX(CGRectGetWidth(maskBounds), CGFLOAT_MIN);
            CGFloat maskVerticalRatio = CGRectGetHeight(sourceImageRect) / MAX(CGRectGetHeight(maskBounds), CGFLOAT_MIN);
            CGFloat maskFinalRatio = MAX(maskHorizontalRatio, maskVerticalRatio);
            maskBounds = CGRectMake(0, 0, CGRectGetWidth(sourceImageRect) / maskFinalRatio, CGRectGetHeight(sourceImageRect) / maskFinalRatio);
            if (isPresenting) {
                maskFromBounds = maskBounds;
            } else {
                maskToBounds = maskBounds;
            }
            
            CGFloat cornerRadius = 0;
            if (animator.imagePreviewViewController.sourceImageCornerRadius == ZKUIImagePreviewViewControllerCornerRadiusAutomaticDimension &&
                animator.imagePreviewViewController.sourceImageView) {
                UIView *sourceView = animator.imagePreviewViewController.sourceImageView();
                cornerRadius = sourceView.layer.cornerRadius;
            } else {
                cornerRadius = MAX(animator.imagePreviewViewController.sourceImageCornerRadius, 0);
            }
            cornerRadius = cornerRadius / MAX(maskFinalRatio, CGFLOAT_MIN);
            
            CABasicAnimation *cornerRadiusAnimation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
            cornerRadiusAnimation.fromValue = @(isPresenting ? cornerRadius : 0);
            cornerRadiusAnimation.toValue = @(isPresenting ? 0 : cornerRadius);
            
            CABasicAnimation *boundsAnimation = [CABasicAnimation animationWithKeyPath:@"bounds"];
            boundsAnimation.fromValue = [NSValue valueWithCGRect:CGRectMake(0, 0, maskFromBounds.size.width, maskFromBounds.size.height)];
            boundsAnimation.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, maskToBounds.size.width, maskToBounds.size.height)];
            
            CAAnimationGroup *maskAnimation = [[CAAnimationGroup alloc] init];
            maskAnimation.duration = animator.duration;
            maskAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            maskAnimation.fillMode = kCAFillModeForwards;
            maskAnimation.removedOnCompletion = NO;
            maskAnimation.animations = @[cornerRadiusAnimation, boundsAnimation];
            
            animator.cornerRadiusMaskLayer.position = ZKCenterOfRect(contentView.bounds);
            contentView.layer.mask = animator.cornerRadiusMaskLayer;
            [animator.cornerRadiusMaskLayer addAnimation:maskAnimation forKey:@"maskAnimation"];
            
            zoomImageView.scrollView.clipsToBounds = NO;
            zoomImageView.transform = CGAffineTransformIdentity;
            if (zoomImageView.contentView) {
                zoomImageView.contentView.transform = CGAffineTransformIdentity;
            }
            if (isPresenting) {
                previewView.backgroundColor = [UIColor clearColor];
            }
            
            CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
            transformAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeAffineTransform(fromTransform)];
            transformAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeAffineTransform(toTransform)];
            transformAnimation.duration = animator.duration;
            transformAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            transformAnimation.fillMode = kCAFillModeForwards;
            transformAnimation.removedOnCompletion = NO;
            [zoomImageView.layer addAnimation:transformAnimation forKey:@"transformAnimation"];
        };
        
        self.animationBlock = ^(__kindof ZKUIImagePreviewViewTransitionAnimator *animator, BOOL isPresenting, ZKUIImagePreviewViewControllerTransitioningStyle style, CGRect sourceImageRect, ZKZoomImageView *zoomImageView, id<UIViewControllerContextTransitioning> transitionContext) {
            if (style == ZKUIImagePreviewViewControllerTransitioningStyleFade) {
                animator.imagePreviewViewController.view.alpha = isPresenting ? 1 : 0;
            } else {
                animator.imagePreviewViewController.view.backgroundColor = isPresenting ? animator.imagePreviewViewController.backgroundColor : [UIColor clearColor];
            }
        };
        
        self.animationCompletionBlock = ^(__kindof ZKUIImagePreviewViewTransitionAnimator *animator, BOOL isPresenting, ZKUIImagePreviewViewControllerTransitioningStyle style, CGRect sourceImageRect, ZKZoomImageView *zoomImageView, id<UIViewControllerContextTransitioning> transitionContext) {
            animator.imagePreviewViewController.view.alpha = 1;
            [animator.cornerRadiusMaskLayer removeAnimationForKey:@"maskAnimation"];
            if (zoomImageView) {
                zoomImageView.scrollView.clipsToBounds = YES;
                if (zoomImageView.contentView) {
                    zoomImageView.contentView.layer.mask = nil;
                    zoomImageView.contentView.transform = CGAffineTransformIdentity;
                    [zoomImageView.contentView.layer removeAnimationForKey:@"transformAnimation"];
                }
                [zoomImageView.layer removeAnimationForKey:@"transformAnimation"];
                zoomImageView.transform = CGAffineTransformIdentity;
                [zoomImageView prepareForTransition];
            }
        };
    }
    return self;
}

- (void)setImagePreviewViewController:(ZKUIImagePreviewViewController *)imagePreviewViewController {
    _imagePreviewViewController = imagePreviewViewController;
}

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return self.duration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    if (!self.imagePreviewViewController) {
        [transitionContext completeTransition:NO];
        return;
    }
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    BOOL isPresenting = fromViewController.presentedViewController == toViewController;
    UIViewController *presentingViewController = isPresenting ? fromViewController : toViewController;
    BOOL shouldAppearanceTransitionManually = self.imagePreviewViewController.modalPresentationStyle != UIModalPresentationFullScreen;
    
    ZKUIImagePreviewViewControllerTransitioningStyle style = isPresenting ? self.imagePreviewViewController.presentingStyle : self.imagePreviewViewController.dismissingStyle;
    CGRect sourceImageRect = CGRectZero;
    if (style == ZKUIImagePreviewViewControllerTransitioningStyleZoom) {
        if (self.imagePreviewViewController.sourceImageRect) {
            sourceImageRect = [self.imagePreviewViewController.view convertRect:self.imagePreviewViewController.sourceImageRect() fromView:nil];
        } else if (self.imagePreviewViewController.sourceImageView) {
            UIView *sourceImageView = self.imagePreviewViewController.sourceImageView();
            if (sourceImageView) {
                sourceImageRect = ZKUIImagePreviewSourceRectForView(sourceImageView, self.imagePreviewViewController.view);
            }
        }
        if (!CGRectEqualToRect(sourceImageRect, CGRectZero) && !CGRectIntersectsRect(sourceImageRect, self.imagePreviewViewController.view.bounds)) {
            sourceImageRect = CGRectZero;
        }
    }
    if (style == ZKUIImagePreviewViewControllerTransitioningStyleZoom && CGRectEqualToRect(sourceImageRect, CGRectZero)) {
        style = ZKUIImagePreviewViewControllerTransitioningStyleFade;
    }
    
    UIView *containerView = transitionContext.containerView;
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    [fromView setNeedsLayout];
    [fromView layoutIfNeeded];
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    [toView setNeedsLayout];
    [toView layoutIfNeeded];
    
    ZKZoomImageView *zoomImageView = [self.imagePreviewViewController.imagePreviewView zoomImageViewAtIndex:self.imagePreviewViewController.imagePreviewView.currentImageIndex];
    if (zoomImageView && style == ZKUIImagePreviewViewControllerTransitioningStyleZoom) {
        [zoomImageView prepareForTransition];
    }
    
    toView.frame = containerView.bounds;
    if (isPresenting) {
        [containerView addSubview:toView];
        if (shouldAppearanceTransitionManually) {
            [presentingViewController beginAppearanceTransition:NO animated:YES];
        }
    } else {
        [containerView insertSubview:toView belowSubview:fromView];
        [presentingViewController beginAppearanceTransition:YES animated:YES];
    }
    
    if (self.animationEnteringBlock) {
        self.animationEnteringBlock(self, isPresenting, style, sourceImageRect, zoomImageView, transitionContext);
    }
    
    [UIView animateWithDuration:self.duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        if (self.animationBlock) {
            self.animationBlock(self, isPresenting, style, sourceImageRect, zoomImageView, transitionContext);
        }
    } completion:^(BOOL finished) {
        [presentingViewController endAppearanceTransition];
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        if (self.animationCompletionBlock) {
            self.animationCompletionBlock(self, isPresenting, style, sourceImageRect, zoomImageView, transitionContext);
        }
    }];
}

@end
