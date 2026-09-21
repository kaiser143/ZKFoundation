//
//  ZKBarConfiguration.h
//  ZKFoundation
//
//  Created by zhangkai on 2019/11/14.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ZKNavigationBarProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZKBarConfiguration : NSObject

@property (nonatomic, assign, readonly) BOOL navigationBarHidden;
@property (nonatomic, assign, readonly) UIBarStyle barStyle;
@property (nonatomic, assign, readonly) BOOL translucent;
@property (nonatomic, assign, readonly) BOOL transparent;
@property (nonatomic, assign, readonly) BOOL shadowImage;
@property (nonatomic, strong, readonly) UIColor *tintColor;
@property (nonatomic, strong, readonly, nullable) UIColor *backgroundColor;
@property (nonatomic, strong, readonly, nullable) UIImage *backgroundImage;
@property (nonatomic, strong, readonly, nullable) NSString *backgroundImageIdentifier;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithBarConfigurations:(ZKNavigationBarConfigurations)configurations
                                tintColor:(nullable UIColor *)tintColor
                          backgroundColor:(nullable UIColor *)backgroundColor
                          backgroundImage:(nullable UIImage *)backgroundImage
                backgroundImageIdentifier:(nullable NSString *)backgroundImageIdentifier NS_DESIGNATED_INITIALIZER;

@end

@interface ZKBarConfiguration (ZKBarTransition)

- (instancetype)initWithBarConfigurationOwner:(id<ZKNavigationBarConfigureStyle>)owner;

- (BOOL)isVisible;

- (BOOL)useSystemBarBackground;

@end

@interface UINavigationBar (ZKPrivate)

@property (nonatomic, strong, readonly) ZKBarConfiguration *currentBarConfigure;
@property (nonatomic, strong, readonly, nullable) UIView *kai_backgroundView;

/// 仅Liquid Glass悬浮栏返回 YES，其它系统版本与风格一律返回 NO，保证旧交互不变。
BOOL ZKNavigationBarUsesLiquidGlass(UINavigationBar *navigationBar);

- (void)kai_adaptWithBarStyle:(UIBarStyle)barStyle tintColor:(UIColor *)tintColor;
- (void)kai_commitBarConfiguration:(ZKBarConfiguration *)configure;

@end

@interface UIToolbar (ZKPrivate)

- (void)kai_commitBarConfiguration:(ZKBarConfiguration *)configure;

@end

NS_ASSUME_NONNULL_END
