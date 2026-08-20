//
//  ZKPopupController.m
//  ZKFoundation
//
//  Created by Kaiser on 2019/4/21.
//

#import "ZKPopupController.h"

#define KAI_SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define KAI_IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

static inline UIViewAnimationOptions UIViewAnimationCurveToAnimationOptions(UIViewAnimationCurve curve) {
    return curve << 16;
}

@interface ZKPopupController () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIWindow *applicationWindow;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIView *backdropView;
@property (nonatomic, strong) UIVisualEffectView *blurEffectView;
@property (nonatomic, strong) UITapGestureRecognizer *backgroundTapRecognizer;
@property (nonatomic, strong) UIView *popupView;
@property (nonatomic, strong) NSArray<UIView *> *views;
@property (nonatomic) BOOL dismissAnimated;
@property (nonatomic, strong) NSMutableArray<NSLayoutConstraint *> *contentLayoutConstraints;
@property (nonatomic, strong) NSMutableDictionary<NSValue *, NSLayoutConstraint *> *contentHeightConstraintsByView;
@property (nonatomic, strong) NSMutableDictionary<NSValue *, NSLayoutConstraint *> *contentTopConstraintsByView;
@property (nonatomic, strong) NSMutableDictionary<NSValue *, NSLayoutConstraint *> *contentBottomConstraintsByView;

@end

@implementation ZKPopupController

- (instancetype)initWithContents:(NSArray<UIView *> *)contents {
    self = [super init];
    if (self) {

        self.views = contents;

        self.popupView                 = [[UIView alloc] initWithFrame:CGRectZero];
        self.popupView.backgroundColor = [UIColor whiteColor];
        self.popupView.clipsToBounds   = YES;

        self.maskView                         = [[UIView alloc] initWithFrame:self.applicationWindow.bounds];
        self.maskView.backgroundColor         = [UIColor clearColor];
        self.backgroundTapRecognizer          = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleBackgroundTapGesture:)];
        self.backgroundTapRecognizer.delegate = self;
        [self.maskView addGestureRecognizer:self.backgroundTapRecognizer];

        self.backdropView                         = [[UIView alloc] initWithFrame:self.maskView.bounds];
        self.backdropView.backgroundColor         = [UIColor colorWithWhite:0.0 alpha:0.5];
        self.backdropView.autoresizingMask        = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backdropView.userInteractionEnabled  = NO;
        [self.maskView addSubview:self.backdropView];

        // Add blur effect view to backdrop (alpha animation applies to backdrop only, not popupView)
        if (!UIAccessibilityIsReduceTransparencyEnabled()) {
            UIBlurEffect *blurEffect             = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
            self.blurEffectView                  = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
            self.blurEffectView.frame            = self.backdropView.bounds;
            self.blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

            [self.backdropView addSubview:self.blurEffectView];
        }

        [self.maskView addSubview:self.popupView];

        self.theme = [ZKPopupTheme defaultTheme];
        self.contentLayoutConstraints = [NSMutableArray array];
        self.contentHeightConstraintsByView = [NSMutableDictionary dictionary];
        self.contentTopConstraintsByView = [NSMutableDictionary dictionary];
        self.contentBottomConstraintsByView = [NSMutableDictionary dictionary];

        [self addPopupContents];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(orientationWillChange)
                                                     name:UIApplicationWillChangeStatusBarOrientationNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(orientationChanged)
                                                     name:UIApplicationDidChangeStatusBarOrientationNotification
                                                   object:nil];
    }
    return self;
}

- (instancetype)init {
    self = [self initWithContents:@[]];
    return self;
}

- (void)dealloc {
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)orientationWillChange {

    [UIView animateWithDuration:self.theme.animationDuration
                     animations:^{
                         self.maskView.frame   = self.applicationWindow.bounds;
                         self.popupView.center = [self endingPoint];
                     }];
}

- (void)orientationChanged {

    UIInterfaceOrientation statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
    CGFloat angle                               = KAI_UIInterfaceOrientationAngleOfOrientation(statusBarOrientation);
    CGAffineTransform transform                 = CGAffineTransformMakeRotation(angle);

    [UIView animateWithDuration:self.theme.animationDuration
                     animations:^{
                         self.maskView.frame   = self.applicationWindow.bounds;
                         self.popupView.center = [self endingPoint];
                         if (KAI_SYSTEM_VERSION_LESS_THAN(@"8.0")) {
                             self.popupView.transform = transform;
                         }
                     }];
}

CGFloat KAI_UIInterfaceOrientationAngleOfOrientation(UIInterfaceOrientation orientation) {
    CGFloat angle;

    switch (orientation) {
        case UIInterfaceOrientationPortraitUpsideDown:
            angle = M_PI;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            angle = -M_PI_2;
            break;
        case UIInterfaceOrientationLandscapeRight:
            angle = M_PI_2;
            break;
        default:
            angle = 0.0;
            break;
    }

    return angle;
}

#pragma mark - Theming

- (void)applyTheme {
    if (self.theme.popupStyle == ZKPopupStyleFullscreen) {
        self.theme.presentationStyle = ZKPopupPresentationStyleFadeIn;
    }
    if (self.theme.popupStyle == ZKPopupStyleActionSheet) {
        self.theme.presentationStyle = ZKPopupPresentationStyleSlideInFromBottom;
    }
    self.blurEffectView.alpha      = self.theme.blurEffectAlpha;
    self.popupView.backgroundColor = self.theme.backgroundColor;

    CGFloat cornerRadius = self.theme.cornerRadius;
    if (self.theme.popupStyle == ZKPopupStyleFullscreen) {
        self.popupView.layer.cornerRadius = 0;
    } else if (self.theme.popupStyle == ZKPopupStyleActionSheet) {
        self.popupView.layer.cornerRadius = cornerRadius;
        self.popupView.layer.masksToBounds  = YES;
        self.popupView.layer.maskedCorners  = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    } else if (self.theme.popupStyle == ZKPopupStyleCentered) {
        self.popupView.layer.cornerRadius = cornerRadius;
        self.popupView.layer.masksToBounds  = YES;
        self.popupView.layer.maskedCorners  = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner;
    } else {
        self.popupView.layer.cornerRadius = 0;
    }
    UIColor *maskBackgroundColor;
    if (self.theme.popupStyle == ZKPopupStyleFullscreen) {
        maskBackgroundColor = self.popupView.backgroundColor;
    } else {
        // set maskBackgroundColor according to maskType
        switch (self.theme.maskType) {
            case ZKPopupMaskTypeClear:
                maskBackgroundColor = [UIColor clearColor];
                break;
            case ZKPopupMaskTypeDimmed:
                maskBackgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
                break;
            default:
                maskBackgroundColor = self.theme.customMaskColor;
                break;
        }
    }
    self.backdropView.backgroundColor = maskBackgroundColor;
}

#pragma mark - Popup Building

- (void)addPopupContents {
    for (UIView *view in self.views) {
        [self.popupView addSubview:view];
    }
}

- (CGFloat)bottomSafeAreaInsetIfNeed {
    if (self.theme.popupStyle != ZKPopupStyleActionSheet) {
        return 0;
    }
    UIWindow *window = self.maskView.window ?: self.applicationWindow;
    if (@available(iOS 11.0, *)) {
        return window.safeAreaInsets.bottom;
    }
    return 0;
}

- (BOOL)shouldLayoutViewUsingAutoLayout:(UIView *)view {
    return !view.translatesAutoresizingMaskIntoConstraints;
}

- (void)removeContentLayoutConstraints {
    if (self.contentLayoutConstraints.count > 0) {
        [NSLayoutConstraint deactivateConstraints:self.contentLayoutConstraints];
        [self.contentLayoutConstraints removeAllObjects];
    }
    [self.contentHeightConstraintsByView removeAllObjects];
    [self.contentTopConstraintsByView removeAllObjects];
    [self.contentBottomConstraintsByView removeAllObjects];
}

- (NSValue *)layoutKeyForView:(UIView *)view {
    return [NSValue valueWithNonretainedObject:view];
}

- (CGSize)sizeForManualLayoutView:(UIView *)view fittingWidth:(CGFloat)width {
    CGSize viewSize = view.frame.size;
    if (CGSizeEqualToSize(viewSize, CGSizeZero)) {
        viewSize = [view sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)];
        viewSize.width = width;
    }
    return viewSize;
}

- (CGSize)sizeForAutoLayoutView:(UIView *)view fittingWidth:(CGFloat)width {
    CGSize fittingSize = CGSizeMake(width, UILayoutFittingCompressedSize.height);
    return [view systemLayoutSizeFittingSize:fittingSize
               withHorizontalFittingPriority:UILayoutPriorityRequired
                     verticalFittingPriority:UILayoutPriorityFittingSizeLevel];
}

- (void)activateContentConstraints:(NSArray<NSLayoutConstraint *> *)constraints {
    [NSLayoutConstraint activateConstraints:constraints];
    [self.contentLayoutConstraints addObjectsFromArray:constraints];
}

- (void)applyPopupViewFrameWithSize:(CGSize)size preservePopupPosition:(BOOL)preserve {
    if (preserve && self.maskView.superview) {
        if (self.theme.popupStyle == ZKPopupStyleActionSheet) {
            CGFloat bottom = CGRectGetMaxY(self.popupView.frame);
            CGFloat x      = (CGRectGetWidth(self.maskView.bounds) - size.width) * 0.5;
            self.popupView.frame = CGRectMake(x, bottom - size.height, size.width, size.height);
            return;
        }
        if (self.theme.popupStyle == ZKPopupStyleCentered) {
            CGPoint center = self.popupView.center;
            self.popupView.bounds = CGRectMake(0, 0, size.width, size.height);
            self.popupView.center = center;
            return;
        }
        if (self.theme.popupStyle == ZKPopupStyleFullscreen) {
            self.popupView.frame = self.maskView.bounds;
            return;
        }
    }
    self.popupView.frame = CGRectMake(0, 0, size.width, size.height);
}

- (CGFloat)horizontalOriginForManualLayoutView:(UIView *)view viewSize:(CGSize)viewSize inset:(UIEdgeInsets)inset popupWidth:(CGFloat)popupWidth {
    if (CGSizeEqualToSize(view.frame.size, CGSizeZero)) {
        return inset.left;
    }
    return (popupWidth - viewSize.width) * 0.5;
}

- (void)applyLayoutForItems:(NSArray<NSDictionary *> *)layoutItems
            anchorFromBottom:(BOOL)anchorFromBottom
                   popupSize:(CGSize)popupSize
                       inset:(UIEdgeInsets)inset
    reuseExistingConstraints:(BOOL)reuseExistingConstraints {
    NSArray<NSDictionary *> *orderedItems = anchorFromBottom ? [[layoutItems reverseObjectEnumerator] allObjects] : layoutItems;
    CGFloat edge                          = anchorFromBottom ? (popupSize.height - inset.bottom) : inset.top;

    for (NSDictionary *item in orderedItems) {
        UIView *view        = item[@"view"];
        CGSize viewSize     = [item[@"size"] CGSizeValue];
        BOOL usesAutoLayout = [item[@"usesAutoLayout"] boolValue];

        if (usesAutoLayout) {
            view.translatesAutoresizingMaskIntoConstraints = NO;
            NSValue *viewKey = [self layoutKeyForView:view];

            if (reuseExistingConstraints) {
                NSLayoutConstraint *heightConstraint = self.contentHeightConstraintsByView[viewKey];
                if (anchorFromBottom) {
                    CGFloat bottomInset                  = popupSize.height - edge;
                    NSLayoutConstraint *bottomConstraint = self.contentBottomConstraintsByView[viewKey];
                    if (heightConstraint && bottomConstraint) {
                        heightConstraint.constant = viewSize.height;
                        bottomConstraint.constant = -bottomInset;
                        edge -= viewSize.height + self.theme.contentVerticalPadding;
                        continue;
                    }
                } else {
                    NSLayoutConstraint *topConstraint = self.contentTopConstraintsByView[viewKey];
                    if (heightConstraint && topConstraint) {
                        heightConstraint.constant = viewSize.height;
                        topConstraint.constant    = edge;
                        edge += viewSize.height + self.theme.contentVerticalPadding;
                        continue;
                    }
                }
            }

            NSLayoutConstraint *heightConstraint = [view.heightAnchor constraintEqualToConstant:viewSize.height];
            NSLayoutConstraint *centerXConstraint = [view.centerXAnchor constraintEqualToAnchor:self.popupView.centerXAnchor];
            NSLayoutConstraint *widthConstraint = [view.widthAnchor constraintEqualToConstant:viewSize.width];
            NSMutableArray<NSLayoutConstraint *> *constraints = [NSMutableArray arrayWithObjects:heightConstraint, centerXConstraint, widthConstraint, nil];

            if (anchorFromBottom) {
                CGFloat bottomInset = popupSize.height - edge;
                NSLayoutConstraint *bottomConstraint = [view.bottomAnchor constraintEqualToAnchor:self.popupView.bottomAnchor constant:-bottomInset];
                [constraints addObject:bottomConstraint];
                self.contentBottomConstraintsByView[viewKey] = bottomConstraint;
                edge -= viewSize.height + self.theme.contentVerticalPadding;
            } else {
                NSLayoutConstraint *topConstraint = [view.topAnchor constraintEqualToAnchor:self.popupView.topAnchor constant:edge];
                [constraints addObject:topConstraint];
                self.contentTopConstraintsByView[viewKey] = topConstraint;
                edge += viewSize.height + self.theme.contentVerticalPadding;
            }

            self.contentHeightConstraintsByView[viewKey] = heightConstraint;
            [self activateContentConstraints:constraints];
        } else {
            CGFloat originX = [self horizontalOriginForManualLayoutView:view viewSize:viewSize inset:inset popupWidth:popupSize.width];
            CGFloat originY = anchorFromBottom ? (edge - viewSize.height) : edge;
            view.translatesAutoresizingMaskIntoConstraints = YES;
            view.frame                                     = CGRectMake(originX, originY, viewSize.width, viewSize.height);
            edge = anchorFromBottom ? (originY - self.theme.contentVerticalPadding) : (edge + viewSize.height + self.theme.contentVerticalPadding);
        }
    }
}

- (NSDictionary *)prepareLayoutForFittingSize:(CGSize)size {
    UIEdgeInsets inset = self.theme.popupContentInsets;
    if (self.theme.popupStyle == ZKPopupStyleActionSheet) {
        inset.bottom += [self bottomSafeAreaInsetIfNeed];
    }
    CGFloat availableWidth = size.width - (inset.left + inset.right);

    NSMutableArray<NSDictionary *> *layoutItems = [NSMutableArray array];
    CGFloat layoutY                             = inset.top;
    BOOL laidOutAnySubview                      = NO;

    for (UIView *view in self.popupView.subviews) {
        view.autoresizingMask = UIViewAutoresizingNone;
        if (view.hidden) {
            continue;
        }

        CGSize viewSize = [self shouldLayoutViewUsingAutoLayout:view] ? [self sizeForAutoLayoutView:view fittingWidth:availableWidth]
                                                                  : [self sizeForManualLayoutView:view fittingWidth:availableWidth];
        BOOL usesAutoLayout = [self shouldLayoutViewUsingAutoLayout:view];

        [layoutItems addObject:@{
            @"view" : view,
            @"size" : [NSValue valueWithCGSize:viewSize],
            @"usesAutoLayout" : @(usesAutoLayout)
        }];

        layoutY += viewSize.height + self.theme.contentVerticalPadding;
        laidOutAnySubview = YES;
    }

    CGSize result = CGSizeZero;
    if (laidOutAnySubview) {
        result.height = layoutY - self.theme.contentVerticalPadding;
    }
    for (NSDictionary *item in layoutItems) {
        CGSize viewSize = [item[@"size"] CGSizeValue];
        result.width    = MAX(result.width, viewSize.width);
    }
    result.width += inset.left + inset.right;
    result.height = MIN(INFINITY, MAX(0.0f, result.height + inset.bottom));

    return @{
        @"items" : layoutItems,
        @"size" : [NSValue valueWithCGSize:result],
        @"inset" : [NSValue valueWithUIEdgeInsets:inset]
    };
}

- (CGSize)applyPreparedLayout:(NSDictionary *)prepared
         preservePopupPosition:(BOOL)preservePopupPosition
      reuseExistingConstraints:(BOOL)reuseExistingConstraints {
    NSArray<NSDictionary *> *layoutItems = prepared[@"items"];
    CGSize result                        = [prepared[@"size"] CGSizeValue];
    UIEdgeInsets inset                   = [prepared[@"inset"] UIEdgeInsetsValue];

    BOOL anchorFromBottom        = self.theme.popupStyle == ZKPopupStyleActionSheet;
    BOOL resizePopupBeforeLayout = preservePopupPosition && anchorFromBottom;

    if (!reuseExistingConstraints) {
        [self removeContentLayoutConstraints];
    }

    if (resizePopupBeforeLayout) {
        [self applyPopupViewFrameWithSize:result preservePopupPosition:YES];
    }

    [self applyLayoutForItems:layoutItems
             anchorFromBottom:anchorFromBottom
                    popupSize:result
                        inset:inset
     reuseExistingConstraints:reuseExistingConstraints];

    if (!resizePopupBeforeLayout) {
        [self applyPopupViewFrameWithSize:result preservePopupPosition:preservePopupPosition];
    }

    if (self.contentLayoutConstraints.count > 0) {
        [self.popupView layoutIfNeeded];
        CGFloat maxBottom = inset.top;
        for (UIView *view in self.popupView.subviews) {
            if (!view.hidden) {
                maxBottom = MAX(maxBottom, CGRectGetMaxY(view.frame));
            }
        }
        result.height = MIN(INFINITY, MAX(0.0f, maxBottom + inset.bottom));
    }

    if (!CGSizeEqualToSize(self.popupView.bounds.size, result)) {
        if (resizePopupBeforeLayout) {
            [self applyPopupViewFrameWithSize:result preservePopupPosition:YES];
        }
        if (self.contentLayoutConstraints.count > 0) {
            if (!reuseExistingConstraints) {
                [self removeContentLayoutConstraints];
            }
            [self applyLayoutForItems:layoutItems
                     anchorFromBottom:anchorFromBottom
                            popupSize:result
                                inset:inset
             reuseExistingConstraints:reuseExistingConstraints];
        }
        if (!resizePopupBeforeLayout) {
            [self applyPopupViewFrameWithSize:result preservePopupPosition:preservePopupPosition];
        }
        if (self.contentLayoutConstraints.count > 0) {
            [self.popupView layoutIfNeeded];
        }
    }

    return result;
}

- (CGSize)calculateContentSizeThatFits:(CGSize)size andUpdateLayout:(BOOL)update preservePopupPosition:(BOOL)preservePopupPosition {
    NSDictionary *prepared = [self prepareLayoutForFittingSize:size];
    if (!update) {
        return [prepared[@"size"] CGSizeValue];
    }
    return [self applyPreparedLayout:prepared preservePopupPosition:preservePopupPosition reuseExistingConstraints:NO];
}

- (CGSize)calculateContentSizeThatFits:(CGSize)size andUpdateLayout:(BOOL)update {
    return [self calculateContentSizeThatFits:size andUpdateLayout:update preservePopupPosition:NO];
}

- (CGSize)sizeThatFits:(CGSize)size {
    return [self calculateContentSizeThatFits:size andUpdateLayout:NO];
}

- (void)updateLayout {
    [self updateLayoutWithChanges:nil];
}

- (void)updateLayoutWithChanges:(void (^)(void))changes {
    BOOL isPresented   = self.maskView.superview != nil;
    CGSize fittingSize = CGSizeMake([self popupWidth], self.maskView.bounds.size.height);

    if (!isPresented) {
        if (changes) {
            changes();
        }
        [self applyPreparedLayout:[self prepareLayoutForFittingSize:fittingSize] preservePopupPosition:NO reuseExistingConstraints:NO];
        return;
    }

    [UIView animateWithDuration:self.theme.animationDuration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         if (changes) {
                             changes();
                         }
                         [self applyPreparedLayout:[self prepareLayoutForFittingSize:fittingSize]
                             preservePopupPosition:YES
                          reuseExistingConstraints:YES];
                     }
                     completion:nil];
}

#pragma mark - Keyboard

- (void)keyboardWillShow:(NSNotification *)notification {
    if (self.theme.movesAboveKeyboard) {
        CGRect frame               = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        frame                      = [self.popupView convertRect:frame fromView:nil];
        NSTimeInterval duration    = [(notification.userInfo)[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        UIViewAnimationCurve curve = [(notification.userInfo)[UIKeyboardAnimationCurveUserInfoKey] integerValue];

        [self keyboardWithEndFrame:frame willShowAfterDuration:duration withOptions:UIViewAnimationCurveToAnimationOptions(curve)];
    }
}

- (void)keyboardWithEndFrame:(CGRect)keyboardFrame willShowAfterDuration:(NSTimeInterval)duration withOptions:(UIViewAnimationOptions)options {
    CGRect popupViewIntersection = CGRectIntersection(self.popupView.frame, keyboardFrame);

    if (popupViewIntersection.size.height > 0 || self.theme.popupStyle == ZKPopupStyleActionSheet) {
        CGRect maskViewIntersection = CGRectIntersection(self.maskView.frame, keyboardFrame);

        [UIView animateWithDuration:duration
                              delay:0.0f
                            options:options
                         animations:^{
                             if (self.theme.popupStyle == ZKPopupStyleActionSheet) {
                                 CGFloat y            = CGRectGetHeight(self.maskView.frame) - CGRectGetHeight(keyboardFrame) - CGRectGetHeight(self.popupView.frame);
                                 self.popupView.frame = CGRectMake(self.popupView.frame.origin.x, y, self.popupView.frame.size.width, self.popupView.frame.size.height);
                             } else {
                                 self.popupView.center = CGPointMake(self.popupView.center.x, (CGRectGetHeight(self.maskView.frame) - maskViewIntersection.size.height) / 2);
                             }
                         }
                         completion:nil];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    if (self.theme.movesAboveKeyboard) {
        CGRect frame               = [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
        frame                      = [self.popupView convertRect:frame fromView:nil];
        NSTimeInterval duration    = [(notification.userInfo)[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        UIViewAnimationCurve curve = [(notification.userInfo)[UIKeyboardAnimationCurveUserInfoKey] integerValue];

        [self keyboardWithStartFrame:frame willHideAfterDuration:duration withOptions:UIViewAnimationCurveToAnimationOptions(curve)];
    }
}

- (void)keyboardWithStartFrame:(CGRect)keyboardFrame willHideAfterDuration:(NSTimeInterval)duration withOptions:(UIViewAnimationOptions)options {
    [UIView animateWithDuration:duration
                          delay:0.0f
                        options:options
                     animations:^{
                         self.popupView.center = [self endingPoint];
                     }
                     completion:nil];
}

#pragma mark - Presentation

- (void)presentPopupControllerAnimated:(BOOL)flag {

    if ([self.delegate respondsToSelector:@selector(popupControllerWillPresent:)]) {
        [self.delegate popupControllerWillPresent:self];
    }

    // Keep a record of if the popup was presented with animation
    self.dismissAnimated = flag;

    [self applyTheme];
    [self calculateContentSizeThatFits:CGSizeMake([self popupWidth], self.maskView.bounds.size.height) andUpdateLayout:YES];
    self.popupView.center = [self originPoint];

    BOOL fadeContent = (self.theme.presentationStyle == ZKPopupPresentationStyleFadeIn &&
                        self.theme.popupStyle == ZKPopupStyleCentered);

    [self.applicationWindow addSubview:self.maskView];
    self.backdropView.alpha = 0;
    if (fadeContent) {
        // 与系统 Alert 一致：蒙版与内容同步淡入
        self.popupView.alpha = 0;
    }
    [UIView animateWithDuration:flag ? self.theme.animationDuration : 0.0
        animations:^{
            self.backdropView.alpha = 1.0;
            self.popupView.center   = [self endingPoint];
            if (fadeContent) {
                self.popupView.alpha = 1.0;
            }
        }
        completion:^(BOOL finished) {
            self.popupView.userInteractionEnabled = YES;
            if ([self.delegate respondsToSelector:@selector(popupControllerDidPresent:)]) {
                [self.delegate popupControllerDidPresent:self];
            }
        }];
}

- (void)dismissPopupControllerAnimated:(BOOL)flag {
    if ([self.delegate respondsToSelector:@selector(popupControllerWillDismiss:)]) {
        [self.delegate popupControllerWillDismiss:self];
    }
    BOOL fadeContent = (self.theme.presentationStyle == ZKPopupPresentationStyleFadeIn &&
                        self.theme.popupStyle == ZKPopupStyleCentered);
    [UIView animateWithDuration:flag ? self.theme.animationDuration : 0.0
        animations:^{
            self.backdropView.alpha = 0.0;
            self.popupView.center   = [self dismissedPoint];
            if (fadeContent) {
                // 与系统 Alert 一致：蒙版与内容同步淡出，避免蒙版消失后内容忽然被移除
                self.popupView.alpha = 0.0;
            }
        }
        completion:^(BOOL finished) {
            [self.maskView removeFromSuperview];
            self.popupView.alpha = 1.0;
            if ([self.delegate respondsToSelector:@selector(popupControllerDidDismiss:)]) {
                [self.delegate popupControllerDidDismiss:self];
            }
        }];
}

- (CGPoint)originPoint {
    CGPoint origin;
    switch (self.theme.presentationStyle) {
        case ZKPopupPresentationStyleFadeIn:
            origin = self.maskView.center;
            break;
        case ZKPopupPresentationStyleSlideInFromBottom:
            origin = CGPointMake(self.maskView.center.x, self.maskView.bounds.size.height + self.popupView.bounds.size.height);
            break;
        case ZKPopupPresentationStyleSlideInFromLeft:
            origin = CGPointMake(-self.popupView.bounds.size.width, self.maskView.center.y);
            break;
        case ZKPopupPresentationStyleSlideInFromRight:
            origin = CGPointMake(self.maskView.bounds.size.width + self.popupView.bounds.size.width, self.maskView.center.y);
            break;
        case ZKPopupPresentationStyleSlideInFromTop:
            origin = CGPointMake(self.maskView.center.x, -self.popupView.bounds.size.height);
            break;
        default:
            origin = self.maskView.center;
            break;
    }
    return origin;
}

- (CGPoint)endingPoint {
    CGPoint center;
    if (self.theme.popupStyle == ZKPopupStyleActionSheet) {
        center = CGPointMake(self.maskView.center.x, self.maskView.bounds.size.height - (self.popupView.bounds.size.height * 0.5));
    } else {
        center = self.maskView.center;
    }
    return center;
}

- (CGPoint)dismissedPoint {
    CGPoint dismissed;
    switch (self.theme.presentationStyle) {
        case ZKPopupPresentationStyleFadeIn:
            dismissed = self.maskView.center;
            break;
        case ZKPopupPresentationStyleSlideInFromBottom:
            dismissed = self.theme.dismissesOppositeDirection ? CGPointMake(self.maskView.center.x, -self.popupView.bounds.size.height) : CGPointMake(self.maskView.center.x, self.maskView.bounds.size.height + self.popupView.bounds.size.height);
            if (self.theme.popupStyle == ZKPopupStyleActionSheet) {
                dismissed = CGPointMake(self.maskView.center.x, self.maskView.bounds.size.height + self.popupView.bounds.size.height);
            }
            break;
        case ZKPopupPresentationStyleSlideInFromLeft:
            dismissed = self.theme.dismissesOppositeDirection ? CGPointMake(self.maskView.bounds.size.width + self.popupView.bounds.size.width, self.maskView.center.y) : CGPointMake(-self.popupView.bounds.size.width, self.maskView.center.y);
            break;
        case ZKPopupPresentationStyleSlideInFromRight:
            dismissed = self.theme.dismissesOppositeDirection ? CGPointMake(-self.popupView.bounds.size.width, self.maskView.center.y) : CGPointMake(self.maskView.bounds.size.width + self.popupView.bounds.size.width, self.maskView.center.y);
            break;
        case ZKPopupPresentationStyleSlideInFromTop:
            dismissed = self.theme.dismissesOppositeDirection ? CGPointMake(self.maskView.center.x, self.maskView.bounds.size.height + self.popupView.bounds.size.height) : CGPointMake(self.maskView.center.x, -self.popupView.bounds.size.height);
            break;
        default:
            dismissed = self.maskView.center;
            break;
    }
    return dismissed;
}

- (CGFloat)popupWidth {
    CGFloat width         = self.theme.maxPopupWidth;
    CGFloat maskViewWidth = self.maskView.bounds.size.width;
    if (width > maskViewWidth || self.theme.popupStyle == ZKPopupStyleFullscreen) {
        width = maskViewWidth;
    }
    return width;
}

#pragma mark - UIGestureRecognizerDelegate

- (void)handleBackgroundTapGesture:(id)sender {
    if (self.theme.shouldDismissOnBackgroundTouch) {
        [self.popupView endEditing:YES];
        [self dismissPopupControllerAnimated:self.dismissAnimated];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isDescendantOfView:self.popupView])
        return NO;
    return YES;
}

- (UIWindow *)applicationWindow {
    return [UIApplication sharedApplication].keyWindow;
}

@end

#pragma mark - ZKPopupTheme Methods

@implementation ZKPopupTheme

+ (ZKPopupTheme *)defaultTheme {
    ZKPopupTheme *defaultTheme                  = [[ZKPopupTheme alloc] init];
    defaultTheme.backgroundColor                = [UIColor whiteColor];
    defaultTheme.cornerRadius                   = 15.0f;
    defaultTheme.popupContentInsets             = UIEdgeInsetsMake(16.0f, 16.0f, 16.0f, 16.0f);
    defaultTheme.popupStyle                     = ZKPopupStyleCentered;
    defaultTheme.presentationStyle              = ZKPopupPresentationStyleSlideInFromBottom;
    defaultTheme.dismissesOppositeDirection     = NO;
    defaultTheme.maskType                       = ZKPopupMaskTypeDimmed;
    defaultTheme.shouldDismissOnBackgroundTouch = YES;
    defaultTheme.movesAboveKeyboard             = YES;
    defaultTheme.contentVerticalPadding         = 16.0f;
    defaultTheme.maxPopupWidth                  = 300.0f;
    defaultTheme.animationDuration              = 0.3f;
    defaultTheme.blurEffectAlpha                = 0.0f;
    return defaultTheme;
}

@end
