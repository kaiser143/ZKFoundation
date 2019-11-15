//
//  UIViewController+ZKNavigationBarTransition.h
//  ZKFoundation
//
//  Created by zhangkai on 2019/11/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (ZKNavigationBarTransition)

- (BOOL)kai_customNavigationBarStyleEnable;

- (void)kai_refreshNavigationBarStyle;

- (CGRect)kai_fakeBarFrameForNavigationBar:(UINavigationBar *)navigationBar;

@end

NS_ASSUME_NONNULL_END
