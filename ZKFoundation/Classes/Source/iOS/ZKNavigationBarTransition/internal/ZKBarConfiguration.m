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
        barBackgroundView.alpha = 0;
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
}

- (ZKBarConfiguration *)currentBarConfigure {
    return [self associatedValueForKey:_cmd];
}

- (void)setCurrentBarConfigure:(ZKBarConfiguration *)currentBarConfigure {
    [self setAssociateValue:currentBarConfigure withKey:@selector(currentBarConfigure)];
}

@end

@implementation UIToolbar (ZKPrivate)

- (void)kai_commitBarConfiguration:(ZKBarConfiguration *)configure {
    self.barStyle = configure.barStyle;
    
    UIImage* const transpanrentImage = UIImage.new;
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
            UIImage* backgroundImage = configure.backgroundImage;
            if (!backgroundImage && configure.backgroundColor) {
                backgroundImage = [UIImage imageWithColor:configure.backgroundColor];
            }
            [self setBackgroundImage:backgroundImage forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
        }
    }
    
    UIImage* shadowImage = configure.shadowImage ? nil : transpanrentImage;
    [self setShadowImage:shadowImage forToolbarPosition:UIBarPositionAny];
}

@end
