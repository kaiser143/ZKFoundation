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

    // 非Liquid Glass走旧逻辑：以真栏私有背景视图为几何基准，保证 push/pop 与提交前一致。
    if (!ZKNavigationBarUsesLiquidGlass(navigationBar)) {
        UIView *backgroundView = [navigationBar kai_backgroundView];
        CGRect frame;
        if (@available(iOS 18, *)) {
            // iOS 18 backgroundView.superview 返回了 nil
            frame = [navigationBar convertRect:backgroundView.frame toView:self.view];
        } else {
            frame = [backgroundView.superview convertRect:backgroundView.frame toView:self.view];
        }
        frame.origin.x = self.view.bounds.origin.x;
        return frame;
    }

    // Liquid Glass下没有稳定的全宽背景视图，才改用公开坐标换算出覆盖状态栏的完整顶部区域。
    CGRect navigationBarFrame = [navigationBar convertRect:navigationBar.bounds toView:self.view];
    if (CGRectIsNull(navigationBarFrame) || CGRectIsInfinite(navigationBarFrame)) return CGRectNull;

    // 旧版栏背景会延伸到状态栏后方，重建该几何，假栏覆盖完整顶部边缘。
    CGFloat minY = MIN(CGRectGetMinY(self.view.bounds), CGRectGetMinY(navigationBarFrame));
    CGFloat maxY = CGRectGetMaxY(navigationBarFrame);
    CGRect frame = CGRectMake(CGRectGetMinX(self.view.bounds),
                              minY,
                              CGRectGetWidth(self.view.bounds),
                              MAX(0, maxY - minY));
    return frame;
}

@end
