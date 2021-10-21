//
//  ZKBarConfiguration.m
//  ZKFoundation
//
//  Created by zhangkai on 2019/11/14.
//

#import "ZKBarConfiguration.h"
#import <ZKCategories/ZKCategories.h>

@implementation ZKBarConfiguration

- (instancetype)init {
    return [self initWithBarConfigurations:ZKNavigationBarConfigurationsDefault
                       navigationBarHidden:NO
                                 tintColor:nil
                           backgroundColor:nil
                           backgroundImage:nil
                 backgroundImageIdentifier:nil];
}

- (instancetype)initWithBarConfigurations:(ZKNavigationBarConfigurations)configurations
                      navigationBarHidden:(BOOL)navigationBarHidden
                                tintColor:(nullable UIColor *)tintColor
                          backgroundColor:(nullable UIColor *)backgroundColor
                          backgroundImage:(nullable UIImage *)backgroundImage
                backgroundImageIdentifier:(nullable NSString *)backgroundImageIdentifier {
    self = [super init];
    if (!self) return nil;

    do {
        _navigationBarHidden = navigationBarHidden;

        _barStyle = (configurations & ZKNavigationBarStyleBlack) > 0 ? UIBarStyleBlack : UIBarStyleDefault;
        if (!tintColor) {
            tintColor = _barStyle == UIBarStyleBlack ? [UIColor whiteColor] : [UIColor blackColor];
        }
        _tintColor = tintColor;

        if (_navigationBarHidden) break;

        _transparent = (configurations & ZKNavigationBarBackgroundStyleTransparent) > 0;
        if (_transparent) break;

        // show shadow image only if not transparent
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
    UIColor *tintColor                           = [owner kai_tintColor];

    UIImage *backgroundImage  = nil;
    NSString *imageIdentifier = nil;
    UIColor *backgroundColor  = nil;

    if (!(configurations & ZKNavigationBarBackgroundStyleTransparent)) {
        if (configurations & ZKNavigationBarBackgroundStyleImage) {
            backgroundImage = [owner kai_navigationBackgroundImageWithIdentifier:&imageIdentifier];
        } else if (configurations & ZKNavigationBarBackgroundStyleColor) {
            backgroundColor = [owner kai_barTintColor];
        }
    }

    return [self initWithBarConfigurations:configurations
                       navigationBarHidden:[(UIViewController *)owner kai_prefersNavigationBarHidden]
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

    UIView *barBackgroundView        = [self kai_backgroundView];
    UIImage *const transpanrentImage = UIImage.new;
    if (configure.transparent) {
//        barBackgroundView.alpha = 0;
        barBackgroundView.hidden = YES;
        self.translucent        = YES;
        self.barTintColor       = nil;

        if (@available(iOS 15.0, *)) {
            UINavigationBarAppearance *appearance = self.standardAppearance.copy;
            [appearance configureWithTransparentBackground];
            appearance.backgroundColor = configure.backgroundColor;
            appearance.backgroundImage = transpanrentImage;
            appearance.shadowColor = self.shadowImage ? nil : UIColor.clearColor;
            self.scrollEdgeAppearance  = appearance;
            self.standardAppearance    = appearance;
        } else {
            [self setBackgroundImage:transpanrentImage forBarMetrics:UIBarMetricsDefault];
        }
    } else {
        [UIView performWithoutAnimation:^{
            barBackgroundView.alpha = 1;
        }];
//        barBackgroundView.alpha  = 1;
        barBackgroundView.hidden = NO;
        self.translucent         = configure.translucent;
        UIImage *backgroundImage = configure.backgroundImage;
        if (!backgroundImage && configure.backgroundColor) {
            backgroundImage = [UIImage imageWithColor:configure.backgroundColor];
        }

        if (@available(iOS 15.0, *)) {
            UINavigationBarAppearance *appearance = self.standardAppearance.copy;
            appearance.backgroundColor            = configure.backgroundColor;
            appearance.backgroundImage            = backgroundImage;
            appearance.shadowColor = self.shadowImage ? nil : UIColor.clearColor;
            self.scrollEdgeAppearance             = appearance;
            self.standardAppearance               = appearance;
        } else {
            [self setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
        }
    }

    self.shadowImage = configure.shadowImage ? nil : transpanrentImage;

    [self setCurrentBarConfigure:configure];
}

- (ZKBarConfiguration *)currentBarConfigure {
    return [self associatedValueForKey:_cmd];
}

- (void)setCurrentBarConfigure:(ZKBarConfiguration *)currentBarConfigure {
    [self setAssociateValue:currentBarConfigure withKey:@selector(currentBarConfigure)];
}

@end

@implementation KAIToolbar

+ (void)load {
    [self swizzleMethod:@selector(layoutSubviews) withMethod:@selector(__kai_layoutSubviews)];
}

- (UIView *)kai_backgroundView {
    return [self valueForKey:@"_backgroundView"];
}

- (void)__kai_layoutSubviews {
    [self __kai_layoutSubviews];
    
    // iOS 15 在toolbar上加了一层毛玻璃，影响显示效果
    if (self.class == KAIToolbar.class) {
        UIView *barBackgroundView        = [self kai_backgroundView];
        UIView *view = [barBackgroundView descendantOrSelfWithClass:UIVisualEffectView.class];
        view.alpha = 0;
    }
}

- (void)kai_commitBarConfiguration:(ZKBarConfiguration *)configure {
    self.barStyle  = configure.barStyle;
    self.tintColor = configure.tintColor;

    UIImage *const transpanrentImage = UIImage.new;
    if (configure.transparent) {
        self.translucent  = YES;
        self.barTintColor = nil;

        if (@available(iOS 15.0, *)) {
            UIToolbarAppearance *appearance = self.standardAppearance.copy;
            [appearance configureWithTransparentBackground];
            appearance.backgroundColor = configure.backgroundColor;
            appearance.backgroundImage = transpanrentImage;
            appearance.shadowColor = configure.shadowImage ? nil : UIColor.clearColor;
            appearance.shadowImage = configure.shadowImage ? nil : transpanrentImage;
            self.scrollEdgeAppearance  = appearance;
            self.standardAppearance    = appearance;
        } else {
            [self setBackgroundImage:transpanrentImage forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
        }
    } else {
        self.translucent         = configure.translucent;
        UIImage *backgroundImage = configure.backgroundImage;
        if (!backgroundImage && configure.backgroundColor) {
            backgroundImage = [UIImage imageWithColor:configure.backgroundColor];
        }

        if (@available(iOS 15.0, *)) {
            UIToolbarAppearance *appearance = self.standardAppearance.copy;
            appearance.backgroundColor      = configure.backgroundColor;
            appearance.backgroundImage      = backgroundImage;
            appearance.shadowColor = configure.shadowImage ? nil : UIColor.clearColor;
            appearance.shadowImage = configure.shadowImage ? nil : transpanrentImage;
            self.scrollEdgeAppearance       = appearance;
            self.standardAppearance         = appearance;
        } else {
            [self setBackgroundImage:backgroundImage forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
        }
    }

    UIImage *shadowImage = configure.shadowImage ? nil : transpanrentImage;
    [self setShadowImage:shadowImage forToolbarPosition:UIBarPositionAny];
    self.clipsToBounds = !configure.shadowImage;
}

@end
