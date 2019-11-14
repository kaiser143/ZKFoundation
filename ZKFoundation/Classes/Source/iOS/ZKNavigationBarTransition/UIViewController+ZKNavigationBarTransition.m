//
//  UIViewController+ZKNavigationBarTransition.m
//  Masonry
//
//  Created by zhangkai on 2019/11/14.
//

#import "UIViewController+ZKNavigationBarTransition.h"
#import "ZKBarConfiguration.h"

@implementation UIViewController (ZKNavigationBarTransition)

- (BOOL)kai_customNavigationBarStyleEnable {
    return [self conformsToProtocol:@protocol(ZKNavigationBarConfigureStyle)];
}

- (UINavigationBar *)__kai_navigationBar {
    if ([self isKindOfClass:[UINavigationController class]]) {
        return [(UINavigationController *)self navigationBar];
    }

    return [self.navigationController navigationBar];
}

- (void)kai_refreshNavigationBarStyle {
    NSParameterAssert([self kai_customNavigationBarStyleEnable]);

    UINavigationBar *navigationBar = [self __kai_navigationBar];
    if (navigationBar.topItem == self.navigationItem) {
        id<ZKNavigationBarConfigureStyle> owner = (id<ZKNavigationBarConfigureStyle>)self;
        ZKBarConfiguration *configuration       = [[ZKBarConfiguration alloc] initWithBarConfigurationOwner:owner];
        [navigationBar kai_commitBarConfiguration:configuration];
    }
}

- (CGRect)kai_fakeBarFrameForNavigationBar:(UINavigationBar *)navigationBar {
    if (!navigationBar) return CGRectNull;

    UIView *backgroundView = [navigationBar kai_backgroundView];
    CGRect frame           = [backgroundView.superview convertRect:backgroundView.frame toView:self.view];
    frame.origin.x         = self.view.bounds.origin.x;
    return frame;
}

@end
