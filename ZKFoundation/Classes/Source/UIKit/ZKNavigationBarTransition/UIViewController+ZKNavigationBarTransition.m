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

    // Do not use UINavigationBar's private _backgroundView here. Starting with
    // the Liquid Glass design, a navigation bar no longer has a stable,
    // full-width background view that can be used as a geometry reference.
    CGRect navigationBarFrame = [navigationBar convertRect:navigationBar.bounds toView:self.view];
    if (CGRectIsNull(navigationBarFrame) || CGRectIsInfinite(navigationBarFrame)) return CGRectNull;

    // The old bar background extended behind the status bar. Recreate that
    // geometry from public view coordinates so the fake background continues
    // to cover the complete top edge during a transition.
    CGFloat minY = MIN(CGRectGetMinY(self.view.bounds), CGRectGetMinY(navigationBarFrame));
    CGFloat maxY = CGRectGetMaxY(navigationBarFrame);
    CGRect frame = CGRectMake(CGRectGetMinX(self.view.bounds),
                              minY,
                              CGRectGetWidth(self.view.bounds),
                              MAX(0, maxY - minY));
    return frame;
}

@end
