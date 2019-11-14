//
//  ZKNavigationController.m
//  Masonry
//
//  Created by zhangkai on 2019/11/14.
//

#import "ZKNavigationController.h"
#import "ZKNavigationControllerDelegateProxy.h"
#import "ZKNavigationBarTransitionCenter.h"
#import "ZKNavigationBarProtocol.h"

@interface ZKNavigationController () <UIGestureRecognizerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) ZKNavigationBarTransitionCenter *center;
@property (nonatomic, weak, nullable) id<UINavigationControllerDelegate> navigationDelegate;
@property (nonatomic, strong, nullable) ZKNavigationControllerDelegateProxy *delegateProxy;
@property (assign) BOOL isAnimation;

@end

@implementation ZKNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _center = [[ZKNavigationBarTransitionCenter alloc] initWithDefaultBarConfiguration:(id<ZKNavigationBarConfigureStyle>)self];
    if (!self.delegate) {
        self.delegate = self;
    }
    self.isAnimation                              = NO;
    self.interactivePopGestureRecognizer.delegate = self;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    self.isAnimation = YES;
    [super pushViewController:viewController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    self.isAnimation = YES;
    return [super popViewControllerAnimated:animated];
}

- (void)setDelegate:(id<UINavigationControllerDelegate>)delegate {
    if (delegate == self || delegate == nil) {
        _navigationDelegate = nil;
        _delegateProxy      = nil;
        super.delegate      = self;
    } else {
        _navigationDelegate = delegate;
        _delegateProxy      = [[ZKNavigationControllerDelegateProxy alloc] initWithNavigationTarget:_navigationDelegate
                                                                                   interceptor:self];
        super.delegate = (id<UINavigationControllerDelegate>)_delegateProxy;
    }
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
    id<UINavigationControllerDelegate> navigationDelegate = self.navigationDelegate;
    if ([navigationDelegate respondsToSelector:@selector(navigationController:willShowViewController:animated:)]) {
        [navigationDelegate navigationController:navigationController
                          willShowViewController:viewController
                                        animated:animated];
    }

    [self.center navigationController:navigationController
               willShowViewController:viewController
                             animated:animated];
}

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
    id<UINavigationControllerDelegate> navigationDelegate = self.navigationDelegate;
    if ([navigationDelegate respondsToSelector:@selector(navigationController:didShowViewController:animated:)]) {
        [navigationDelegate navigationController:navigationController
                           didShowViewController:viewController
                                        animated:animated];
    }

    [self.center navigationController:navigationController
                didShowViewController:viewController
                             animated:animated];
    self.isAnimation = NO;
}

@end
