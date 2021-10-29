//
//  ZKNavigationController.m
//  ZKFoundation
//
//  Created by zhangkai on 2019/11/14.
//

#import "ZKNavigationController.h"
#import "ZKNavigationControllerDelegateProxy.h"
#import "ZKNavigationBarTransitionCenter.h"
#import "ZKNavigationBarProtocol.h"

#define ZKMethodNotImplemented() \
    if (self.class == ZKNavigationController.class) {\
        @throw [NSException exceptionWithName:NSInternalInconsistencyException \
                                       reason:[NSString stringWithFormat:@"You must override %@ in a subclass.", NSStringFromSelector(_cmd)] \
                                     userInfo:nil];\
    }

@interface ZKNavigationController () <UIGestureRecognizerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) ZKNavigationBarTransitionCenter *center;
@property (nonatomic, weak, nullable) id<UINavigationControllerDelegate> navigationDelegate;
@property (nonatomic, strong, nullable) ZKNavigationControllerDelegateProxy *delegateProxy;
@property (assign, getter=isAnimation) BOOL animation;

@end

@implementation ZKNavigationController

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self == nil) return nil;
    
    ZKMethodNotImplemented();
    
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self == nil) return nil;
    
    ZKMethodNotImplemented();
    
    return self;
}

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    self = [super initWithRootViewController:rootViewController];
    if (self == nil) return nil;
    
    ZKMethodNotImplemented();
    
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self == nil) return nil;
    
    ZKMethodNotImplemented();
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    id configuration;
    if ([self conformsToProtocol:@protocol(ZKNavigationBarConfigureStyle)])
        configuration = self;
    else
        configuration = self.viewControllers.firstObject;

    _center = [[ZKNavigationBarTransitionCenter alloc] initWithDefaultBarConfiguration:(id<ZKNavigationBarConfigureStyle>)configuration];
    if (!self.delegate) {
        self.delegate = self;
    }
    self.animation                                = NO;
    self.interactivePopGestureRecognizer.delegate = self;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    self.animation = YES;
    [super pushViewController:viewController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    self.animation = YES;
    return [super popViewControllerAnimated:animated];
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
    self.animation = NO;
}

#pragma mark - :. private methods

- (BOOL)shouldAutorotate {
    return self.topViewController.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return self.topViewController.supportedInterfaceOrientations;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return self.topViewController.preferredInterfaceOrientationForPresentation;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    UIStatusBarStyle style = self.navigationBar.barStyle == UIBarStyleBlack ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
    return style;
}

#pragma mark - :. getters and setters

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

@end
