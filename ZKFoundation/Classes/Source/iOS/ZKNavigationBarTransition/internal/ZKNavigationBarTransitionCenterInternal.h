//
//  ZKNavigationBarTransitionCenterInternal.h
//  Pods
//
//  Created by zhangkai on 2019/11/14.
//

#ifndef ZKNavigationBarTransitionCenterInternal_h
#define ZKNavigationBarTransitionCenterInternal_h

#import <ZKFoundation/ZKBarConfiguration.h>

BOOL KAITransitionNeedShowFakeBar(ZKBarConfiguration *from, ZKBarConfiguration *to);

@interface ZKNavigationBarTransitionCenter () <UIToolbarDelegate> {
    BOOL _isTransitionNavigationBar;
}

@property (nonatomic, strong) UINavigationBar *fromViewControllerFakeBar;
@property (nonatomic, strong) UINavigationBar *toViewControllerFakeBar;

@property (nonatomic, strong, readonly) ZKBarConfiguration *defaultBarConfigure;

@end

#endif /* ZKNavigationBarTransitionCenterInternal_h */
