//
//  ZKNavigationBarTransitionCenterInternal.h
//  ZKFoundation
//
//  Created by zhangkai on 2019/11/14.
//

#ifndef ZKNavigationBarTransitionCenterInternal_h
#define ZKNavigationBarTransitionCenterInternal_h

#import <ZKFoundation/ZKBarConfiguration.h>

BOOL KAITransitionNeedShowFakeBar(ZKBarConfiguration *from, ZKBarConfiguration *to);

@interface ZKNavigationBarTransitionCenter () <UIToolbarDelegate>

@property (nonatomic, strong) UIToolbar *fromViewControllerFakeBar;
@property (nonatomic, strong) UIToolbar *toViewControllerFakeBar;
@property (nonatomic, assign, getter=isTransitionNavigationBar) BOOL transitionNavigationBar;

@property (nonatomic, strong, readonly) ZKBarConfiguration *defaultBarConfigure;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)initWithDefaultBarConfiguration:(id<ZKNavigationBarConfigureStyle>)_default NS_DESIGNATED_INITIALIZER;

@end

#endif /* ZKNavigationBarTransitionCenterInternal_h */
