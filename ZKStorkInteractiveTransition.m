//
//  ZKStorkInteractiveTransition.m
//  ZKFoundation
//
//  Created by zhangkai on 2019/11/14.
//

#import "ZKStorkInteractiveTransition.h"
#import <ZKCategories.h>

@interface ZKStorkInteractiveTransition ()
@property (nonatomic, weak) UIViewController *modalController;
@property (nonatomic, strong) ZFDetectScrollViewEndGestureRecognizer *gesture;
@property (nonatomic, strong) id<UIViewControllerContextTransitioning> transitionContext;
@property CGFloat panLocationStart;
@property BOOL isDismiss;
@property BOOL isInteractive;
@property CATransform3D tempTransform;
@property (nonatomic, readonly) CGFloat topSpace;
@end

@implementation ZKStorkInteractiveTransition

- (instancetype)initWithModalViewController:(UIViewController *)modalViewController {
    self = [super init];
    if (self) {
        _modalController     = modalViewController;
        _dragable            = NO;
        _bounces             = NO;
        _behindViewScale     = 0.9f;
        _behindViewAlpha     = 1.0f;
        _transitionDuration  = 0.8f;
        _cornerRadius        = 10;
        _translateForDismiss = 200;

        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(orientationChanged:)
                                                     name:UIApplicationDidChangeStatusBarFrameNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

- (void)setDragable:(BOOL)dragable {
    _dragable = dragable;
    if (_dragable) {
        [self removeGestureRecognizerFromModalController];
        self.gesture          = [[ZFDetectScrollViewEndGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        self.gesture.delegate = self;
        [self.modalController.view addGestureRecognizer:self.gesture];
    } else {
        [self removeGestureRecognizerFromModalController];
    }
}

- (void)setContentScrollView:(UIScrollView *)scrollView {
    // always enable drag if scrollview is set
    if (!self.dragable) {
        self.dragable = YES;
    }

    self.gesture.scrollview = scrollView;
}

- (void)animationEnded:(BOOL)transitionCompleted {
    // Reset to our default state
    self.isInteractive     = NO;
    self.transitionContext = nil;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return self.transitionDuration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    if (self.isInteractive) {
        return;
    }
    // Grab the from and to view controllers from the context
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController   = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    UIView *containerView = [transitionContext containerView];
    kai_view_singleFillet(fromViewController.view, UIRectCornerTopLeft | UIRectCornerTopRight, self.cornerRadius);
    kai_view_singleFillet(toViewController.view, UIRectCornerTopLeft | UIRectCornerTopRight, self.cornerRadius);

    if (!self.isDismiss) {
        [containerView addSubview:toViewController.view];

        toViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

        CGRect startRect = CGRectMake(0,
                                      CGRectGetHeight(containerView.frame),
                                      CGRectGetWidth(containerView.bounds),
                                      CGRectGetHeight(containerView.bounds) - self.topSpace);

        CGPoint transformedPoint    = CGPointApplyAffineTransform(startRect.origin, toViewController.view.transform);
        toViewController.view.frame = CGRectMake(transformedPoint.x, transformedPoint.y, startRect.size.width, startRect.size.height);

        if (toViewController.modalPresentationStyle == UIModalPresentationCustom) {
            [fromViewController beginAppearanceTransition:NO animated:YES];
        }

        [UIView animateWithDuration:[self transitionDuration:transitionContext]
            delay:0
            usingSpringWithDamping:0.8
            initialSpringVelocity:0.1
            options:UIViewAnimationOptionCurveEaseOut
            animations:^{
                fromViewController.view.transform = CGAffineTransformScale(fromViewController.view.transform, self.behindViewScale, self.behindViewScale);
                fromViewController.view.alpha     = self.behindViewAlpha;

                toViewController.view.frame = CGRectMake(0, self.topSpace,
                                                         CGRectGetWidth(toViewController.view.frame),
                                                         CGRectGetHeight(toViewController.view.frame));
            }
            completion:^(BOOL finished) {
                if (toViewController.modalPresentationStyle == UIModalPresentationCustom) {
                    [fromViewController endAppearanceTransition];
                }
                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            }];
    } else {
        if (fromViewController.modalPresentationStyle == UIModalPresentationFullScreen) {
            [containerView addSubview:toViewController.view];
        }

        [containerView bringSubviewToFront:fromViewController.view];

        if (![self isPriorToIOS8]) {
            toViewController.view.layer.transform = CATransform3DScale(toViewController.view.layer.transform, self.behindViewScale, self.behindViewScale, 1);
        }

        toViewController.view.alpha = self.behindViewAlpha;

        UIView *containerView = [transitionContext containerView];
        CGRect endRect        = CGRectMake(0,
                                    CGRectGetHeight(containerView.bounds),
                                    CGRectGetWidth(fromViewController.view.frame),
                                    CGRectGetHeight(fromViewController.view.frame));

        CGPoint transformedPoint = CGPointApplyAffineTransform(endRect.origin, fromViewController.view.transform);
        endRect                  = CGRectMake(transformedPoint.x, transformedPoint.y, endRect.size.width, endRect.size.height);

        if (fromViewController.modalPresentationStyle == UIModalPresentationCustom) {
            [toViewController beginAppearanceTransition:YES animated:YES];
        }

        [UIView animateWithDuration:[self transitionDuration:transitionContext]
            delay:0
            usingSpringWithDamping:0.8
            initialSpringVelocity:0.1
            options:UIViewAnimationOptionCurveEaseOut
            animations:^{
                CGFloat scaleBack                     = (1 / self.behindViewScale);
                toViewController.view.layer.transform = CATransform3DScale(toViewController.view.layer.transform, scaleBack, scaleBack, 1);
                toViewController.view.alpha           = 1.0f;
                fromViewController.view.frame         = endRect;
            }
            completion:^(BOOL finished) {
                toViewController.view.layer.transform = CATransform3DIdentity;
                if (fromViewController.modalPresentationStyle == UIModalPresentationCustom) {
                    [toViewController endAppearanceTransition];
                }
                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            }];
    }
}

- (void)removeGestureRecognizerFromModalController {
    if (self.gesture && [self.modalController.view.gestureRecognizers containsObject:self.gesture]) {
        [self.modalController.view removeGestureRecognizer:self.gesture];
        self.gesture = nil;
    }
}

#pragma mark - Gesture

- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
    // Location reference
    CGPoint location = [recognizer locationInView:self.modalController.view.window];
    location         = CGPointApplyAffineTransform(location, CGAffineTransformInvert(recognizer.view.transform));
    // Velocity reference
    CGPoint velocity = [recognizer velocityInView:[self.modalController.view window]];
    velocity         = CGPointApplyAffineTransform(velocity, CGAffineTransformInvert(recognizer.view.transform));

    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.isInteractive    = YES;
        self.panLocationStart = location.y;
        [self.modalController dismissViewControllerAnimated:YES completion:nil];

    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat animationRatio = (location.y - self.panLocationStart) / (CGRectGetHeight([self.modalController view].bounds));
        [self updateInteractiveTransition:animationRatio];

    } else if (recognizer.state == UIGestureRecognizerStateEnded) {

        CGFloat velocityForSelectedDirection = velocity.y;

        if (velocityForSelectedDirection > self.translateForDismiss) {
            [self finishInteractiveTransition];
        } else {
            [self cancelInteractiveTransition];
        }
        self.isInteractive = NO;
    }
}

#pragma mark -

- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    self.transitionContext = transitionContext;

    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController   = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    if (![self isPriorToIOS8]) {
        toViewController.view.layer.transform = CATransform3DScale(toViewController.view.layer.transform, self.behindViewScale, self.behindViewScale, 1);
    }

    self.tempTransform = toViewController.view.layer.transform;

    toViewController.view.alpha = self.behindViewAlpha;

    if (fromViewController.modalPresentationStyle == UIModalPresentationFullScreen) {
        [[transitionContext containerView] addSubview:toViewController.view];
    }
    [[transitionContext containerView] bringSubviewToFront:fromViewController.view];
}

- (void)updateInteractiveTransition:(CGFloat)percentComplete {
    if (!self.bounces && percentComplete < 0) {
        percentComplete = 0;
    }

    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;

    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController   = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    CATransform3D transform              = CATransform3DMakeScale(
        1 + (((1 / self.behindViewScale) - 1) * percentComplete),
        1 + (((1 / self.behindViewScale) - 1) * percentComplete), 1);
    toViewController.view.layer.transform = CATransform3DConcat(self.tempTransform, transform);

    toViewController.view.alpha = self.behindViewAlpha + ((1 - self.behindViewAlpha) * percentComplete);

    CGRect updateRect = CGRectMake(0,
                                   (CGRectGetHeight(fromViewController.view.bounds) * percentComplete) + self.topSpace,
                                   CGRectGetWidth(fromViewController.view.frame),
                                   CGRectGetHeight(fromViewController.view.frame));

    // reset to zero if x and y has unexpected value to prevent crash
    if (isnan(updateRect.origin.x) || isinf(updateRect.origin.x)) {
        updateRect.origin.x = 0;
    }
    if (isnan(updateRect.origin.y) || isinf(updateRect.origin.y)) {
        updateRect.origin.y = 0;
    }

    CGPoint transformedPoint = CGPointApplyAffineTransform(updateRect.origin, fromViewController.view.transform);
    updateRect               = CGRectMake(transformedPoint.x, transformedPoint.y, updateRect.size.width, updateRect.size.height);

    fromViewController.view.frame = updateRect;
}

- (void)finishInteractiveTransition {
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;

    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController   = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    kai_view_singleFillet(toViewController.view, UIRectCornerTopLeft | UIRectCornerTopRight, 0);
    UIView *containerView = [transitionContext containerView];
    CGRect endRect        = CGRectMake(0,
                                CGRectGetHeight(containerView.bounds),
                                CGRectGetWidth(fromViewController.view.frame),
                                CGRectGetHeight(fromViewController.view.frame));

    CGPoint transformedPoint = CGPointApplyAffineTransform(endRect.origin, fromViewController.view.transform);
    endRect                  = CGRectMake(transformedPoint.x, transformedPoint.y, endRect.size.width, endRect.size.height);

    if (fromViewController.modalPresentationStyle == UIModalPresentationCustom) {
        [toViewController beginAppearanceTransition:YES animated:YES];
    }

    [UIView animateWithDuration:[self transitionDuration:transitionContext]
        delay:0
        usingSpringWithDamping:0.8
        initialSpringVelocity:0.1
        options:UIViewAnimationOptionCurveEaseOut
        animations:^{
            CGFloat scaleBack                     = (1 / self.behindViewScale);
            toViewController.view.layer.transform = CATransform3DScale(self.tempTransform, scaleBack, scaleBack, 1);
            toViewController.view.alpha           = 1.0f;
            fromViewController.view.frame         = endRect;
        }
        completion:^(BOOL finished) {
            if (fromViewController.modalPresentationStyle == UIModalPresentationCustom) {
                [toViewController endAppearanceTransition];
            }
            [transitionContext completeTransition:YES];
        }];
}

- (void)cancelInteractiveTransition {
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
    [transitionContext cancelInteractiveTransition];

    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController   = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    [UIView animateWithDuration:0.4
        delay:0
        usingSpringWithDamping:0.8
        initialSpringVelocity:0.1
        options:UIViewAnimationOptionCurveEaseOut
        animations:^{
            toViewController.view.layer.transform = self.tempTransform;
            toViewController.view.alpha           = self.behindViewAlpha;

            fromViewController.view.frame = CGRectMake(0, self.topSpace,
                                                       CGRectGetWidth(fromViewController.view.frame),
                                                       CGRectGetHeight(fromViewController.view.frame));
        }
        completion:^(BOOL finished) {
            [transitionContext completeTransition:NO];
            if (fromViewController.modalPresentationStyle == UIModalPresentationFullScreen) {
                [toViewController.view removeFromSuperview];
            }
        }];
}

#pragma mark - UIViewControllerTransitioningDelegate Methods

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    self.isDismiss = NO;
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    self.isDismiss = YES;
    return self;
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id<UIViewControllerAnimatedTransitioning>)animator {
    return nil;
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator {
    // Return nil if we are not interactive
    if (self.isInteractive && self.dragable) {
        self.isDismiss = YES;
        return self;
    }

    return nil;
}

#pragma mark - Gesture Delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (self.gestureRecognizerToFailPan && otherGestureRecognizer && self.gestureRecognizerToFailPan == otherGestureRecognizer) {
        return YES;
    }

    return NO;
}

#pragma mark - Utils

- (BOOL)isPriorToIOS8 {
    NSComparisonResult order = [[UIDevice currentDevice].systemVersion compare:@"8.0" options:NSNumericSearch];
    if (order == NSOrderedSame || order == NSOrderedDescending) {
        // OS version >= 8.0
        return YES;
    }
    return NO;
}

#pragma mark - Orientation

- (void)orientationChanged:(NSNotification *)notification {
    UIViewController *backViewController = self.modalController.presentingViewController;
    backViewController.view.transform    = CGAffineTransformIdentity;
    backViewController.view.frame        = self.modalController.view.bounds;
    backViewController.view.transform    = CGAffineTransformScale(backViewController.view.transform, self.behindViewScale, self.behindViewScale);
}

#pragma mark - :. getters and setters

- (CGFloat)topSpace {
    CGFloat statusBarHeight = UIApplication.sharedApplication.statusBarFrame.size.height;
    return (statusBarHeight < 25) ? 30 : statusBarHeight + 13;
}

@end

// Gesture Class Implement
@interface ZFDetectScrollViewEndGestureRecognizer ()
@property (nonatomic, strong) NSNumber *isFail;
@end

@implementation ZFDetectScrollViewEndGestureRecognizer

- (void)reset {
    [super reset];
    self.isFail = nil;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];

    if (!self.scrollview) {
        return;
    }

    if (self.state == UIGestureRecognizerStateFailed) return;
    CGPoint velocity  = [self velocityInView:self.view];
    CGPoint nowPoint  = [touches.anyObject locationInView:self.view];
    CGPoint prevPoint = [touches.anyObject previousLocationInView:self.view];

    if (self.isFail) {
        if (self.isFail.boolValue) {
            self.state = UIGestureRecognizerStateFailed;
        }
        return;
    }

    CGFloat topVerticalOffset = -self.scrollview.contentInset.top;

    if ((fabs(velocity.x) < fabs(velocity.y)) && (nowPoint.y > prevPoint.y) && (self.scrollview.contentOffset.y <= topVerticalOffset)) {
        self.isFail = @NO;
    } else if (self.scrollview.contentOffset.y >= topVerticalOffset) {
        self.state  = UIGestureRecognizerStateFailed;
        self.isFail = @YES;
    } else {
        self.isFail = @NO;
    }
}

@end
