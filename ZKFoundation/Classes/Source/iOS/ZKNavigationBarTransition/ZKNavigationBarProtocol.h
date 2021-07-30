//
//  ZKNavigationBarProtocol.h
//  ZKFoundation
//
//  Created by zhangkai on 2019/11/14.
//

#ifndef ZKNavigationBarProtocol_h
#define ZKNavigationBarProtocol_h

typedef NS_OPTIONS(NSUInteger, ZKNavigationBarConfigurations) {
    // bar style
    ZKNavigationBarStyleLight = 0 << 4,  // UIbarStyleDefault
    ZKNavigationBarStyleBlack = 1 << 4,  // UIbarStyleBlack
    
    ZKNavigationBarBackgroundStyleTranslucent = 0 << 8,
    ZKNavigationBarBackgroundStyleOpaque      = 1 << 8,     // 不透明
    ZKNavigationBarBackgroundStyleTransparent = 2 << 8,     // 透明、半透明
    
    // bar background
    ZKNavigationBarBackgroundStyleNone  = 0 << 16,
    ZKNavigationBarBackgroundStyleColor = 1 << 16,
    ZKNavigationBarBackgroundStyleImage = 2 << 16,
    
    // shadow image
    ZKNavigationBarShowShadowImage = 1 << 20,
    
    ZKNavigationBarConfigurationsDefault = 0,
};

@protocol ZKNavigationBarConfigureStyle <NSObject>

@required
- (ZKNavigationBarConfigurations)kai_navigtionBarConfiguration;

/*!
 *  @brief    navigationBar上面的按钮颜色
 */
- (UIColor *)kai_tintColor;


@optional

/*
 *  identifier 用来比较image的name是否是同，如果不传，会使用image的isEqual来比较
 */
- (UIImage *)kai_navigationBackgroundImageWithIdentifier:(NSString **)identifier;

/*!
 *  @brief    navigationBar背景颜色
 */
- (UIColor *)kai_barTintColor;


@end

#endif /* ZKNavigationBarProtocol_h */
