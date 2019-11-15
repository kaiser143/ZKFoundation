//
//  ZKBarConfiguration.h
//  ZKFoundation
//
//  Created by zhangkai on 2019/11/14.
//

#import <Foundation/Foundation.h>
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
                      navigationBarHidden:(BOOL)navigationBarHidden
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

@interface UIToolbar (ZKPrivate)

- (void)kai_commitBarConfiguration:(ZKBarConfiguration *)configure;

@end

@interface UINavigationBar (ZKPrivate)

@property (nonatomic, strong, readonly) ZKBarConfiguration *currentBarConfigure;

- (void)kai_adaptWithBarStyle:(UIBarStyle)barStyle tintColor:(UIColor *)tintColor;
- (void)kai_commitBarConfiguration:(ZKBarConfiguration *)configure;

- (UIView *)kai_backgroundView;

@end

NS_ASSUME_NONNULL_END
