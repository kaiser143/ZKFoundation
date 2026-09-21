//
//  UIViewController+ZKNavigationBarTransition.m
//  ZKFoundation
//
//  Created by zhangkai on 2019/11/14.
//

#import "UIViewController+ZKNavigationBarTransition.h"
#import "ZKBarConfiguration.h"

@implementation UIViewController (ZKNavigationBarTransition)

- (BOOL)kai_customNavigationBarStyleEnabled {
    return [self conformsToProtocol:@protocol(ZKNavigationBarConfigureStyle)];
}

- (UINavigationBar *)__kai_navigationBar {
    if ([self isKindOfClass:[UINavigationController class]]) {
        return [(UINavigationController *)self navigationBar];
    }

    return [self.navigationController navigationBar];
}

- (void)kai_refreshNavigationBarStyle {
    NSParameterAssert([self kai_customNavigationBarStyleEnabled]);

    UINavigationBar *navigationBar = [self __kai_navigationBar];
    if (navigationBar.topItem == self.navigationItem) {
        id<ZKNavigationBarConfigureStyle> owner = (id<ZKNavigationBarConfigureStyle>)self;
        ZKBarConfiguration *configuration       = [[ZKBarConfiguration alloc] initWithBarConfigurationOwner:owner];
        [navigationBar kai_commitBarConfiguration:configuration];
    }
}

- (CGRect)kai_fakeBarFrameForNavigationBar:(UINavigationBar *)navigationBar {
    if (!navigationBar) return CGRectNull;

    // 此处不要使用 UINavigationBar 的私有 _backgroundView。从 Liquid Glass 设计开始，导航栏不再拥有一个稳定的、
    // 可用作几何参照的全宽背景视图。
    CGRect navigationBarFrame = [navigationBar convertRect:navigationBar.bounds toView:self.view];
    if (CGRectIsNull(navigationBarFrame) || CGRectIsInfinite(navigationBarFrame)) return CGRectNull;

    // 旧版栏背景会延伸到状态栏后方。这里通过公开的视图坐标重建这一几何区域，
    // 使模拟背景在转场期间仍能覆盖完整的顶部边缘。
    CGFloat minY = MIN(CGRectGetMinY(self.view.bounds), CGRectGetMinY(navigationBarFrame));
    CGFloat maxY = CGRectGetMaxY(navigationBarFrame);
    CGRect frame = CGRectMake(CGRectGetMinX(self.view.bounds),
                              minY,
                              CGRectGetWidth(self.view.bounds),
                              MAX(0, maxY - minY));
    return frame;
}

@end
