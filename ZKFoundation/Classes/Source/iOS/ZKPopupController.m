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
@property (nonatomic, strong) UIVisualEffectView *blurEffectView;
@property (nonatomic, strong) UITapGestureRecognizer *backgroundTapRecognizer;
@property (nonatomic, strong) UIView *popupView;
@property (nonatomic, strong) NSArray<UIView *> *views;
@property (nonatomic) BOOL dismissAnimated;

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
        self.maskView.backgroundColor         = [UIColor colorWithWhite:0.0 alpha:0.7];
        self.backgroundTapRecognizer          = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleBackgroundTapGesture:)];
        self.backgroundTapRecognizer.delegate = self;
        [self.maskView addGestureRecognizer:self.backgroundTapRecognizer];

        // Add blur effect view to maskView
        if (!UIAccessibilityIsReduceTransparencyEnabled()) {
            UIBlurEffect *blurEffect             = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
            self.blurEffectView                  = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
            self.blurEffectView.frame            = self.maskView.bounds;
            self.blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

            [self.maskView addSubview:self.blurEffectView];
        }

        [self.maskView addSubview:self.popupView];

        self.theme = [ZKPopupTheme defaultTheme];

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
    self.blurEffectView.alpha         = self.theme.blurEffectAlpha;
    self.popupView.layer.cornerRadius = self.theme.popupStyle == ZKPopupStyleCentered ? self.theme.cornerRadius : 0;
    self.popupView.backgroundColor    = self.theme.backgroundColor;
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
                maskBackgroundColor = [UIColor colorWithWhite:0.0 alpha:0.7];
                break;
            default:
                maskBackgroundColor = self.theme.customMaskColor;
                break;
        }
    }
    self.maskView.backgroundColor = maskBackgroundColor;
}

#pragma mark - Popup Building

- (void)addPopupContents {
    for (UIView *view in self.views) {
        [self.popupView addSubview:view];
    }
}

- (CGSize)calculateContentSizeThatFits:(CGSize)size andUpdateLayout:(BOOL)update {
    UIEdgeInsets inset = self.theme.popupContentInsets;
    size.width -= (inset.left + inset.right);
    size.height -= (inset.top + inset.bottom);

    CGSize result = CGSizeMake(0, inset.top);
    for (UIView *view in self.popupView.subviews) {
        view.autoresizingMask = UIViewAutoresizingNone;
        if (!view.hidden) {
            CGSize _size = view.frame.size;
            if (CGSizeEqualToSize(_size, CGSizeZero)) {
                _size       = [view sizeThatFits:size];
                _size.width = size.width;
                if (update) view.frame = CGRectMake(inset.left, result.height, _size.width, _size.height);
            } else {
                if (update) {
                    view.frame = CGRectMake(0, result.height, _size.width, _size.height);
                }
            }
            result.height += _size.height + self.theme.contentVerticalPadding;
            result.width = MAX(result.width, _size.width);
        }
    }

    result.height -= self.theme.contentVerticalPadding;
    result.width += inset.left + inset.right;
    result.height = MIN(INFINITY, MAX(0.0f, result.height + inset.bottom));
    if (update) {
        for (UIView *view in self.popupView.subviews) {
            view.frame = CGRectMake((result.width - view.frame.size.width) * 0.5, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
        }
        self.popupView.frame = CGRectMake(0, 0, result.width, result.height);
    }
    return result;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return [self calculateContentSizeThatFits:size andUpdateLayout:NO];
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

    [self.applicationWindow addSubview:self.maskView];
    self.maskView.alpha = 0;
    [UIView animateWithDuration:flag ? self.theme.animationDuration : 0.0
        animations:^{
            self.maskView.alpha   = 1.0;
            self.popupView.center = [self endingPoint];
            ;
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
    [UIView animateWithDuration:flag ? self.theme.animationDuration : 0.0
        animations:^{
            self.maskView.alpha   = 0.0;
            self.popupView.center = [self dismissedPoint];
            ;
        }
        completion:^(BOOL finished) {
            [self.maskView removeFromSuperview];
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
    defaultTheme.cornerRadius                   = 4.0f;
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
