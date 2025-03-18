//
//  ZKNavigationBarTransitionCenter.h
//  ZKFoundation
//
//  Created by zhangkai on 2019/11/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ZKNavigationBarConfigureStyle;

@interface ZKNavigationBarTransitionCenter : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)initWithDefaultBarConfiguration:(id<ZKNavigationBarConfigureStyle>)_default NS_DESIGNATED_INITIALIZER;

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
