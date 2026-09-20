//
//  ZKNavigationBarTransitionCenter.m
//  ZKFoundation
//
//  Created by zhangkai on 2019/11/14.
//

#import "ZKNavigationBarTransitionCenter.h"
#import "ZKBarConfiguration.h"
#import "ZKNavigationController.h"
#import "ZKNavigationBarTransitionCenterInternal.h"
#import "UIViewController+ZKNavigationBarTransition.h"
#import "ZKCategoriesImport.h"

BOOL KAITransitionNeedShowFakeBar(ZKBarConfiguration *from, ZKBarConfiguration *to) {
    BOOL showFakeBar = NO;
    do {
        if (from.navigationBarHidden || to.navigationBarHidden) break;

        if (from.transparent != to.transparent ||
            from.translucent != to.translucent) {
            showFakeBar = YES;
            break;
        }

        if (from.useSystemBarBackground && to.useSystemBarBackground) {
            showFakeBar = from.barStyle != to.barStyle;
        } else if (from.backgroundImage && to.backgroundImage) {
            NSString *const fromImageName = from.backgroundImageIdentifier;
            NSString *const toImageName   = to.backgroundImageIdentifier;
            if (fromImageName && toImageName) {
                showFakeBar = ![fromImageName isEqualToString:toImageName];
                break;
            }
            
            showFakeBar = ![from.backgroundImage isEqual:to.backgroundImage];
        } else if (![from.backgroundColor isEqual:to.backgroundColor]) {
            showFakeBar = YES;
        }
    } while (0);

    return showFakeBar;
}

static struct {
    __unsafe_unretained UIViewController *toVC;
} ctx;

/// 仅在转场期间使用的导航栏背景视图。
///
/// 直接按配置绘制背景，不依赖导航栏私有视图层级，
/// 在液态玻璃风格下也能保证全宽背景可见。
@interface ZKNavigationBarFakeView : UIView

@property (nonatomic, strong) UIVisualEffectView *effectView;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIView *backgroundColorView;
@property (nonatomic, strong) UIView *shadowView;

- (void)applyBarConfiguration:(ZKBarConfiguration *)configuration;

@end

@implementation ZKNavigationBarFakeView

- (instancetype)init {
    self = [super initWithFrame:CGRectZero];
    if (!self) return nil;

    self.userInteractionEnabled = NO;
    self.clipsToBounds = YES;

    _effectView = [[UIVisualEffectView alloc] initWithEffect:nil];
    _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _backgroundImageView.contentMode = UIViewContentModeScaleToFill;
    _backgroundColorView = [[UIView alloc] initWithFrame:CGRectZero];
    _shadowView = [[UIView alloc] initWithFrame:CGRectZero];

    [self addSubview:_effectView];
    [self addSubview:_backgroundImageView];
    [self addSubview:_backgroundColorView];
    [self addSubview:_shadowView];
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.effectView.frame = self.bounds;
    self.backgroundImageView.frame = self.bounds;
    self.backgroundColorView.frame = self.bounds;

    CGFloat screenScale = self.window.screen.scale;
    if (screenScale <= 0) screenScale = UIScreen.mainScreen.scale;
    CGFloat pixelHeight = 1.0 / MAX(screenScale, 1.0);
    self.shadowView.frame = CGRectMake(0,
                                       MAX(0, CGRectGetHeight(self.bounds) - pixelHeight),
                                       CGRectGetWidth(self.bounds),
                                       pixelHeight);
}

- (void)applyBarConfiguration:(ZKBarConfiguration *)configuration {
    // 透明栏不绘制任何背景，调用方已用是否可见过滤，此处再兜底一次。
    if (configuration.transparent) {
        self.effectView.effect = nil;
        self.backgroundImageView.image = nil;
        self.backgroundImageView.hidden = YES;
        self.backgroundColorView.backgroundColor = UIColor.clearColor;
        self.shadowView.hidden = YES;
        [self setNeedsLayout];
        return;
    }

    // 层级从下到上：模糊 -> 背景图 -> 底色，与真实导航栏一致，
    // 保证半透明颜色能正确叠加在模糊之上，背景图保持清晰。
    self.backgroundImageView.image = configuration.backgroundImage;
    self.backgroundImageView.hidden = !configuration.backgroundImage;

    UIColor *backgroundColor = configuration.backgroundColor;
    if (!backgroundColor && !configuration.backgroundImage && !configuration.translucent) {
        if (@available(iOS 13.0, *)) {
            backgroundColor = UIColor.systemBackgroundColor;
        } else {
            backgroundColor = configuration.barStyle == UIBarStyleDefault
                ? UIColor.whiteColor
                : UIColor.blackColor;
        }
    }
    self.backgroundColorView.backgroundColor = backgroundColor ?: UIColor.clearColor;

    UIBlurEffectStyle effectStyle = configuration.barStyle == UIBarStyleDefault
        ? UIBlurEffectStyleLight
        : UIBlurEffectStyleDark;
    self.effectView.effect = configuration.translucent
        ? [UIBlurEffect effectWithStyle:effectStyle]
        : nil;

    self.shadowView.hidden = !configuration.shadowImage;
    if (@available(iOS 13.0, *)) {
        self.shadowView.backgroundColor = UIColor.separatorColor;
    } else {
        self.shadowView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    }
    [self setNeedsLayout];
}

@end

@implementation ZKNavigationBarTransitionCenter

- (instancetype)initWithDefaultBarConfiguration:(id<ZKNavigationBarConfigureStyle>)_default {
    NSParameterAssert(_default);
    self = [super init];
    if (self) {
        _defaultBarConfigure = [[ZKBarConfiguration alloc] initWithBarConfigurationOwner:_default];
    }

    return self;
}

#pragma mark - fakeBar

- (UIView *)fromViewControllerFakeBar {
    if (!_fromViewControllerFakeBar) {
        _fromViewControllerFakeBar = [[ZKNavigationBarFakeView alloc] init];
    }

    return _fromViewControllerFakeBar;
}

- (UIView *)toViewControllerFakeBar {
    if (!_toViewControllerFakeBar) {
        _toViewControllerFakeBar = [[ZKNavigationBarFakeView alloc] init];
    }

    return _toViewControllerFakeBar;
}

- (void)removeFakeBars {
    [_fromViewControllerFakeBar removeFromSuperview];
    [_toViewControllerFakeBar removeFromSuperview];
}

#pragma mark - transition

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {

    ZKBarConfiguration *currentConfigure = [navigationController.navigationBar currentBarConfigure] ?: self.defaultBarConfigure;
    ZKBarConfiguration *showConfigure    = self.defaultBarConfigure;
    if ([viewController kai_customNavigationBarStyleEnabled]) {
        id<ZKNavigationBarConfigureStyle> owner = (id<ZKNavigationBarConfigureStyle>)viewController;
        showConfigure                           = [[ZKBarConfiguration alloc] initWithBarConfigurationOwner:owner];
    }

    UINavigationBar *const navigationBar = navigationController.navigationBar;

    BOOL showFakeBar = KAITransitionNeedShowFakeBar(currentConfigure, showConfigure);

    self.transitionNavigationBar = YES;

    if (showConfigure.navigationBarHidden != navigationController.navigationBarHidden) {
        [navigationController setNavigationBarHidden:showConfigure.navigationBarHidden animated:animated];
    }

    ZKBarConfiguration *transparentConfigure = nil;
    if (showFakeBar) {
        ZKNavigationBarConfigurations transparentConf = ZKNavigationBarConfigurationsDefault | ZKNavigationBarBackgroundStyleTransparent;
        if (showConfigure.barStyle == UIBarStyleBlack) transparentConf |= ZKNavigationBarStyleBlack;
        transparentConfigure = [[ZKBarConfiguration alloc] initWithBarConfigurations:transparentConf
                                                                           tintColor:showConfigure.tintColor
                                                                     backgroundColor:nil
                                                                     backgroundImage:nil
                                                           backgroundImageIdentifier:nil];
    }

    if (!showConfigure.navigationBarHidden) {
        [navigationBar kai_commitBarConfiguration:transparentConfigure ?: showConfigure];
    } else {
        [navigationBar kai_adaptWithBarStyle:showConfigure.barStyle tintColor:currentConfigure.tintColor];
    }

    if (!animated) {
        // If animated if false, navigation controller will call did show immediately
        // So Fake bar is not needed any more
        // just return is ok
        return;
    }

    [navigationController.transitionCoordinator
        animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
        if (showFakeBar) {
            [UIView setAnimationsEnabled:NO];

            UIViewController *const fromVC = [context viewControllerForKey:UITransitionContextFromViewControllerKey];
            UIViewController *const toVC   = [context viewControllerForKey:UITransitionContextToViewControllerKey];

            if (fromVC && [currentConfigure isVisible]) {
                CGRect fakeBarFrame = [fromVC kai_fakeBarFrameForNavigationBar:navigationBar];
                if (!CGRectIsNull(fakeBarFrame)) {
                    ZKNavigationBarFakeView *fakeBar = (ZKNavigationBarFakeView *)self.fromViewControllerFakeBar;
                    [fakeBar applyBarConfiguration:currentConfigure];
                    fakeBar.frame = fakeBarFrame;
                    [fromVC.view addSubview:fakeBar];
                }
            }

            if (toVC && [showConfigure isVisible]) {
                CGRect fakeBarFrame = [toVC kai_fakeBarFrameForNavigationBar:navigationBar];
                if (!CGRectIsNull(fakeBarFrame)) {
//                        if (toVC.extendedLayoutIncludesOpaqueBars ||
//                            showConfigure.translucent) {
//                            fakeBarFrame.origin.y = toVC.view.bounds.origin.y;
//                        }

                    ZKNavigationBarFakeView *fakeBar = (ZKNavigationBarFakeView *)self.toViewControllerFakeBar;
                    [fakeBar applyBarConfiguration:showConfigure];
                    fakeBar.frame = fakeBarFrame;
                    [toVC.view addSubview:fakeBar];
                }
            }

            ctx.toVC = toVC;
            [toVC setAssociateValue:@YES withKey:_cmd];
            [toVC.view addObserver:self
                        forKeyPath:NSStringFromSelector(@selector(bounds))
                            options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                            context:&ctx];
            [toVC.view addObserver:self
                        forKeyPath:NSStringFromSelector(@selector(frame))
                            options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                            context:&ctx];

            [UIView setAnimationsEnabled:YES];
        }
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
        UIViewController *const toVC = [context viewControllerForKey:UITransitionContextToViewControllerKey];
        if ([context isCancelled] && viewController == toVC) {
            [self removeFakeBars];
            [navigationBar kai_commitBarConfiguration:currentConfigure];
            
            if (currentConfigure.navigationBarHidden != navigationController.navigationBarHidden) {
                [navigationController setNavigationBarHidden:showConfigure.navigationBarHidden animated:animated];
            }
        }
        
        /// Xcode 16, iOS 18 这个completion Block 会调用两次，animateAlongsideTransition 的block 之调用一次
        /// 两次 removeObserver 会导致程序闪退，这里加个判断
        if (showFakeBar && ctx.toVC == toVC && [[toVC associatedValueForKey:_cmd] boolValue]) {
            [toVC setAssociateValue:@NO withKey:_cmd];
            [toVC.view removeObserver:self
                           forKeyPath:NSStringFromSelector(@selector(bounds))
                              context:&ctx];
            [toVC.view removeObserver:self
                           forKeyPath:NSStringFromSelector(@selector(frame))
                              context:&ctx];
        }
        
        if (self) self.transitionNavigationBar = NO;
    }];

    void (^popInteractionEndBlock)(id<UIViewControllerTransitionCoordinatorContext>) =
        ^(id<UIViewControllerTransitionCoordinatorContext> context) {
            if ([context isCancelled]) {
                // revert statusbar's style
                [navigationBar kai_adaptWithBarStyle:currentConfigure.barStyle
                                           tintColor:currentConfigure.tintColor];
            }
        };

    if (@available(iOS 10, *)) {
        [navigationController.transitionCoordinator notifyWhenInteractionChangesUsingBlock:popInteractionEndBlock];
    } else {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
        [navigationController.transitionCoordinator notifyWhenInteractionEndsUsingBlock:popInteractionEndBlock];
#pragma GCC diagnostic pop
    }
}

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
    [self removeFakeBars];

    ZKBarConfiguration *showConfigure = self.defaultBarConfigure;
    if ([viewController kai_customNavigationBarStyleEnabled]) {
        id<ZKNavigationBarConfigureStyle> owner = (id<ZKNavigationBarConfigureStyle>)viewController;
        showConfigure                           = [[ZKBarConfiguration alloc] initWithBarConfigurationOwner:owner];
    }

    UINavigationBar *const navigationBar = navigationController.navigationBar;
    [navigationBar kai_commitBarConfiguration:showConfigure];

    self.transitionNavigationBar = NO;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (context == &ctx) {
        UIViewController *tovc = ctx.toVC;
        UIView *fakeBar        = self.toViewControllerFakeBar;
        if (fakeBar.superview == tovc.view) {
            UINavigationBar *bar = tovc.navigationController.navigationBar;
            CGRect fakeBarFrame  = [tovc kai_fakeBarFrameForNavigationBar:bar];
            if (!CGRectIsNull(fakeBarFrame)) {
                fakeBar.frame = fakeBarFrame;
            }
        }
    }
}

@end
