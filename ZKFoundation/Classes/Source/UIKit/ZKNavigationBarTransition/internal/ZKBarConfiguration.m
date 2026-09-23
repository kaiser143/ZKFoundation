//
//  ZKBarConfiguration.m
//  ZKFoundation
//
//  Created by zhangkai on 2019/11/14.
//

#import "ZKBarConfiguration.h"
#import "ZKCategoriesImport.h"

@implementation ZKBarConfiguration

- (instancetype)init {
    return [self initWithBarConfigurations:ZKNavigationBarConfigurationsDefault
                                 tintColor:nil
                           backgroundColor:nil
                           backgroundImage:nil
                 backgroundImageIdentifier:nil];
}

- (instancetype)initWithBarConfigurations:(ZKNavigationBarConfigurations)configurations
                                tintColor:(nullable UIColor *)tintColor
                          backgroundColor:(nullable UIColor *)backgroundColor
                          backgroundImage:(nullable UIImage *)backgroundImage
                backgroundImageIdentifier:(nullable NSString *)backgroundImageIdentifier {
    self = [super init];
    if (!self) return nil;
    
    do {
        _navigationBarHidden = (configurations & ZKNavigationBarHidden) > 0;
        
        _barStyle = (configurations & ZKNavigationBarStyleBlack) > 0 ? UIBarStyleBlack : UIBarStyleDefault;
        if (!tintColor) {
            tintColor = _barStyle == UIBarStyleBlack ? [UIColor whiteColor] : [UIColor blackColor];
        }
        _tintColor = tintColor;
        
        if (_navigationBarHidden) break;
        
        _transparent = (configurations & ZKNavigationBarBackgroundStyleTransparent) > 0;
        if (_transparent) break;
        
        // 仅在非透明时显示阴影图像
        _shadowImage = (configurations & ZKNavigationBarShowShadowImage) > 0;
        _translucent = (configurations & ZKNavigationBarBackgroundStyleOpaque) == 0;
        
        if ((configurations & ZKNavigationBarBackgroundStyleImage) > 0 && backgroundImage) {
            _backgroundImage           = backgroundImage;
            _backgroundImageIdentifier = [backgroundImageIdentifier copy];
        } else if (configurations & ZKNavigationBarBackgroundStyleColor) {
            _backgroundColor = backgroundColor;
        }
    } while (0);
    
    return self;
}

@end

@implementation ZKBarConfiguration (ZKBarTransition)

- (instancetype)initWithBarConfigurationOwner:(id<ZKNavigationBarConfigureStyle>)owner {
    ZKNavigationBarConfigurations configurations = [owner kai_navigtionBarConfiguration];
    UIColor *tintColor                           = [owner kai_navigationItemTintColor];
    
    UIImage *backgroundImage  = nil;
    NSString *imageIdentifier = nil;
    UIColor *backgroundColor  = nil;
    
    if (!(configurations & ZKNavigationBarBackgroundStyleTransparent)) {
        if (configurations & ZKNavigationBarBackgroundStyleImage) {
            backgroundImage = [owner kai_navigationBackgroundImageWithIdentifier:&imageIdentifier];
        } else if (configurations & ZKNavigationBarBackgroundStyleColor) {
            backgroundColor = [owner kai_navigationBarTintColor];
        }
    }
    
    return [self initWithBarConfigurations:configurations
                                 tintColor:tintColor
                           backgroundColor:backgroundColor
                           backgroundImage:backgroundImage
                 backgroundImageIdentifier:imageIdentifier];
}

- (BOOL)isVisible {
    return !self.navigationBarHidden && !self.transparent;
}

- (BOOL)useSystemBarBackground {
    return !self.backgroundColor && !self.backgroundImage;
}

@end

@implementation UINavigationBar (ZKPrivate)

/// 任一条件不满足即返回 NO，调用方走旧 UIToolbar 假栏逻辑。
/// iOS15~25、以及 iOS26 开启 UIDesignRequiresCompatibility 时一律走旧逻辑。
BOOL ZKNavigationBarUsesLiquidGlass(UINavigationBar *navigationBar) {
    if (!navigationBar) return NO;
    if (@available(iOS 26.0, *)) {
        // 开发者可在 Info.plist 置 UIDesignRequiresCompatibility = YES 强制旧外观，
        // 此时系统仍跑在 iOS 26 上，但没有Liquid Glass，必须走旧逻辑。
        NSNumber *compatibility = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UIDesignRequiresCompatibility"];
        if ([compatibility boolValue]) return NO;
        // glass 运行时类不存在说明当前环境实际不可用，兜底走旧逻辑。
        if (!NSClassFromString(@"UIGlassEffect")) return NO;
        return YES;
    }
    return NO;
}

/// 玻璃背景几何查找：返回与 _UIBarBackground 等高的全宽顶部区（带顶部安全距离），
/// 圆角取其内部悬浮内容的最大圆角。假栏按此绘制：宽度为屏幕宽，仅左上右上圆角。
CGRect ZKNavigationBarGlassRectForBar(UINavigationBar *navigationBar, CGFloat *outRadius) {
    if (outRadius) *outRadius = 0;
    if (!navigationBar || CGRectIsEmpty(navigationBar.bounds)) return CGRectNull;
    UIView *bg = nil;
    NSMutableArray<UIView *> *stack = [NSMutableArray arrayWithObject:navigationBar];
    while (stack.count) {
        UIView *v = stack.lastObject;
        [stack removeLastObject];
        if (v != (UIView *)navigationBar) {
            NSString *clsName = NSStringFromClass(v.class);
            if ([clsName isEqualToString:@"_UIBarBackground"] || [clsName hasSuffix:@"BarBackground"]) {
                bg = v;
                break;
            }
        }
        for (UIView *sub in v.subviews) [stack addObject:sub];
    }
    if (!bg) return CGRectNull;
    CGFloat radius = 0;
    stack = [NSMutableArray arrayWithObject:bg];
    while (stack.count) {
        UIView *v = stack.lastObject;
        [stack removeLastObject];
        if (v != bg) {
            NSString *clsName = NSStringFromClass(v.class);
            if ([clsName containsString:@"Button"] || [clsName containsString:@"Item"]) {
                for (UIView *sub in v.subviews) [stack addObject:sub];
                continue;
            }
            CGFloat r = v.layer.cornerRadius;
            CGFloat w = CGRectGetWidth(v.bounds);
            CGFloat h = CGRectGetHeight(v.bounds);
            if (r >= 8 && w >= 100 && h >= 28 && h <= 90 && w >= h * 1.5 && r > radius) {
                radius = r;
            }
        }
        for (UIView *sub in v.subviews) [stack addObject:sub];
    }
    if (outRadius) *outRadius = radius;
    UIView *parent = bg.superview ?: navigationBar;
    return [parent convertRect:bg.frame toView:navigationBar];
}

/// 玻璃真栏显隐：transparent Appearance 在 Liquid Glass 下藏不住悬浮胶囊，
/// 此处直接按名称找到 _UIBarBackground / 背景容器改 alpha，保证转场期间真假栏不叠加。
/// 非透明时恢复 alpha = 1。找不到背景视图时不做任何处理，避免误藏标题按钮。
static void ZKSetGlassBackgroundHidden(UINavigationBar *navigationBar, BOOL hidden) {
    if (@available(iOS 26.0, *)) {
        NSMutableArray<UIView *> *stack = [NSMutableArray arrayWithObject:navigationBar];
        while (stack.count) {
            UIView *v = stack.lastObject;
            [stack removeLastObject];
            if (v != (UIView *)navigationBar) {
                NSString *clsName = NSStringFromClass(v.class);
                if ([clsName isEqualToString:@"_UIBarBackground"] || [clsName hasSuffix:@"BarBackground"]) {
                    v.alpha = hidden ? 0 : 1;
                    break;
                }
            }
            for (UIView *sub in v.subviews) [stack addObject:sub];
        }
    }
}
/// 液态玻璃圆角补偿：有底色时 _UIBarBackground 会填满直角盖住系统圆角，
/// 无底色时看到的即系统圆角。单次遍历同时找到背景视图与系统圆角，对齐系统数值后只保留左上右上。
static void ZKApplyLiquidGlassTopCorners(UINavigationBar *navigationBar, BOOL hiddenOrTransparent) {
    if (@available(iOS 26.0, *)) {
        UIView *bg = nil;
        CGFloat radius = 0;
        NSMutableArray<UIView *> *stack = [NSMutableArray arrayWithObject:navigationBar];
        while (stack.count) {
            UIView *v = stack.lastObject;
            [stack removeLastObject];
            NSString *clsName = NSStringFromClass(v.class);
            if ([clsName isEqualToString:@"_UIBarBackground"] || [clsName hasSuffix:@"BarBackground"]) {
                bg = v;
                break;
            }
            for (UIView *sub in v.subviews) [stack addObject:sub];
        }
        if (!bg) return;
        // 模态浮层（Stork/自定义 present）由浮层自身裁圆角，栏不再叠加 mask，
        // 否则栏圆角半径与浮层半径不一致，会出现图1这种灰边/双层圆角。
        UIViewController *host = nil;
        UIResponder *next = navigationBar.nextResponder;
        while (next) {
            if ([next isKindOfClass:[UIViewController class]]) {
                host = (UIViewController *)next;
                break;
            }
            next = next.nextResponder;
        }
        UINavigationController *nav = (UINavigationController *)host;
        if (![nav isKindOfClass:[UINavigationController class]]) nav = host.navigationController;
        if (nav && nav.presentingViewController && nav.modalPresentationStyle != UIModalPresentationFullScreen) {
            bg.layer.mask = nil;
            bg.layer.cornerRadius = 0;
            return;
        }
        if (hiddenOrTransparent) {
            bg.layer.mask = nil;
            bg.layer.cornerRadius = 0;
            return;
        }
        stack = [NSMutableArray arrayWithObject:bg];
        while (stack.count) {
            UIView *v = stack.lastObject;
            [stack removeLastObject];
            if (v != bg && v.layer.cornerRadius > radius) radius = v.layer.cornerRadius;
            for (UIView *sub in v.subviews) [stack addObject:sub];
        }
        if (radius <= 0) radius = navigationBar.layer.cornerRadius;
        if (radius <= 0) {
            CGFloat h = CGRectGetHeight(bg.bounds);
            if (h <= 0) h = CGRectGetHeight(navigationBar.bounds);
            if (h > 0) radius = round(h / 2.0);
        }
        if (radius <= 0) return;
        CAShapeLayer *mask = [CAShapeLayer layer];
        mask.path = [UIBezierPath bezierPathWithRoundedRect:bg.bounds
                                          byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight)
                                                cornerRadii:CGSizeMake(radius, radius)].CGPath;
        bg.layer.mask = mask;
    }
}

- (void)kai_adaptWithBarStyle:(UIBarStyle)barStyle tintColor:(UIColor *)tintColor {
    self.barStyle  = barStyle;
    self.tintColor = tintColor;
}

- (UIView *)kai_backgroundView {
    return [self valueForKey:@"_backgroundView"];
}

- (void)kai_commitBarConfiguration:(ZKBarConfiguration *)configure {
#if DEBUG
    if (@available(iOS 11, *)) {
        NSAssert(!self.prefersLargeTitles, @"large titles is not supported");
    }
#endif
    
    [self kai_adaptWithBarStyle:configure.barStyle
                      tintColor:configure.tintColor];
    
    // 旧系统靠隐藏私有背景视图来藏起真栏，避免转场期间真假栏叠加。
    // Liquid Glass下没有稳定的全宽背景视图，改走透明 Appearance，此处按分支处理。
    UIView *barBackgroundView = ZKNavigationBarUsesLiquidGlass(self) ? nil : [self kai_backgroundView];
    UIImage *const transpanrentImage = UIImage.new;
    if (configure.transparent) {
        barBackgroundView.alpha = 0;
        if (ZKNavigationBarUsesLiquidGlass(self)) ZKSetGlassBackgroundHidden(self, YES);
        if (@available(iOS 13.0, *)) {
            UINavigationBarAppearance *appearance = [[self standardAppearance] copy];
            [appearance configureWithTransparentBackground];
            self.scrollEdgeAppearance = appearance;
            self.standardAppearance = appearance;
        } else {
            self.translucent = YES;
            [self setBackgroundImage:transpanrentImage forBarMetrics:UIBarMetricsDefault];
        }
    } else {
        barBackgroundView.alpha = 1;
        if (ZKNavigationBarUsesLiquidGlass(self)) ZKSetGlassBackgroundHidden(self, NO);
        if (@available(iOS 13.0, *)) {
            UINavigationBarAppearance *appearance = [[self standardAppearance] copy];
            if (configure.translucent) {
                [appearance configureWithDefaultBackground];
                UIBlurEffectStyle effectStyle = configure.barStyle == UIBarStyleDefault ? UIBlurEffectStyleLight : UIBlurEffectStyleDark;
                appearance.backgroundEffect = [UIBlurEffect effectWithStyle:effectStyle];
            } else {
                [appearance configureWithOpaqueBackground];
            }
            if (configure.backgroundImage) {
                appearance.backgroundImage = configure.backgroundImage;
            } else if (configure.backgroundColor) {
                appearance.backgroundColor = configure.backgroundColor;
            }
            if (!configure.shadowImage) {
                appearance.shadowImage = nil;
                appearance.shadowColor = nil;
            }
            self.scrollEdgeAppearance = appearance;
            self.standardAppearance = appearance;
        } else {
            self.translucent = configure.translucent;
            UIImage* backgroundImage = configure.backgroundImage;
            if (!backgroundImage && configure.backgroundColor) {
                backgroundImage = [UIImage imageWithColor:configure.backgroundColor];
            }
            [self setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
        }
    }
    
    self.shadowImage = configure.shadowImage ? nil : transpanrentImage;
    
    [self setCurrentBarConfigure:configure];

    // 液态玻璃：有底色时给 _UIBarBackground 补左上/右上圆角，防止直角盖住系统圆角。
    if (ZKNavigationBarUsesLiquidGlass(self)) {
        ZKApplyLiquidGlassTopCorners(self, configure.navigationBarHidden || configure.transparent);
        // 布局完成后 bounds 才稳定，再校准一次 mask 路径。
        dispatch_async(dispatch_get_main_queue(), ^{
            ZKApplyLiquidGlassTopCorners(self, configure.navigationBarHidden || configure.transparent);
        });
    }
}

- (ZKBarConfiguration *)currentBarConfigure {
    return [self associatedValueForKey:_cmd];
}

- (void)setCurrentBarConfigure:(ZKBarConfiguration *)currentBarConfigure {
    [self setAssociateValue:currentBarConfigure withKey:@selector(currentBarConfigure)];
}

@end

@implementation UIToolbar (ZKPrivate)

// 旧系统转场假栏实现：沿用系统 Toolbar 的模糊与底色叠放，保证与提交前效果一致。
// 仅非Liquid Glass分支使用，Liquid Glass分支改用 ZKNavigationBarFakeView 自绘。
- (void)kai_commitBarConfiguration:(ZKBarConfiguration *)configure {
    self.barStyle = configure.barStyle;

    UIImage *const transpanrentImage = UIImage.new;
    if (configure.transparent) {
        if (@available(iOS 13.0, *)) {
            UIToolbarAppearance *appearance = [[self standardAppearance] copy];
            [appearance configureWithTransparentBackground];
            if (@available(iOS 15.0, *)) {
                self.scrollEdgeAppearance = appearance;
            }
            self.standardAppearance = appearance;
        } else {
            self.translucent = YES;
            [self setBackgroundImage:transpanrentImage forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
        }
    } else {
        if (@available(iOS 13.0, *)) {
            UIToolbarAppearance *appearance = [[self standardAppearance] copy];
            if (configure.translucent) {
                [appearance configureWithDefaultBackground];
                UIBlurEffectStyle effectStyle = configure.barStyle == UIBarStyleDefault ? UIBlurEffectStyleLight : UIBlurEffectStyleDark;
                appearance.backgroundEffect = [UIBlurEffect effectWithStyle:effectStyle];
            } else {
                [appearance configureWithOpaqueBackground];
            }
            if (configure.backgroundImage) {
                appearance.backgroundImage = configure.backgroundImage;
            } else if (configure.backgroundColor) {
                appearance.backgroundColor = configure.backgroundColor;
            }
            if (!configure.shadowImage) {
                appearance.shadowImage = nil;
                appearance.shadowColor = nil;
            }
            if (@available(iOS 15.0, *)) {
                self.scrollEdgeAppearance = appearance;
            }
            self.standardAppearance = appearance;
        } else {
            self.translucent = configure.translucent;
            UIImage *backgroundImage = configure.backgroundImage;
            if (!backgroundImage && configure.backgroundColor) {
                backgroundImage = [UIImage imageWithColor:configure.backgroundColor];
            }
            [self setBackgroundImage:backgroundImage forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
        }
    }

    UIImage *shadowImage = configure.shadowImage ? nil : transpanrentImage;
    [self setShadowImage:shadowImage forToolbarPosition:UIBarPositionAny];
}

@end
