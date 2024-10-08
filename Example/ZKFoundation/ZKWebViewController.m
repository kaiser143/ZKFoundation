//
//  ZKWebViewController.m
//  ZKFoundation_Example
//
//  Created by Kaiser on 2019/11/15.
//  Copyright © 2019 zhangkai. All rights reserved.
//

#import "ZKWebViewController.h"
#import <ZKFoundation.h>
#import <ZKCategories.h>

@interface ZKWebViewController () <ZKNavigationBarConfigureStyle>

@end

@implementation ZKWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    @weakify(self);
    self.progressTintColor = UIColor.orangeColor;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:nil action:nil];
    self.navigationItem.rightBarButtonItem.actionBlock = ^(id _Nonnull sender) {
        @strongify(self);
        [self.webView evaluateJavaScript:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '200%'"completionHandler:nil];
    };
    self.challengeHandler = ^NSURLSessionAuthChallengeDisposition(WKWebView * _Nonnull webView, NSURLAuthenticationChallenge * _Nonnull challenge, NSURLCredential * _Nullable __autoreleasing * _Nullable credential) {
        *credential = [[NSURLCredential alloc] initWithTrust:challenge.protectionSpace.serverTrust];
        return NSURLSessionAuthChallengeUseCredential;
    };
    
    self.kai_prefersPopViewControllerInjectBlock = ^(UIViewController * _Nonnull controller) {
        @strongify(self);
        [self kai_popViewControllerAnimated];
    };
}

#pragma mark - :. ZKNavigationBarConfigureStyle

- (ZKNavigationBarConfigurations)kai_navigtionBarConfiguration {
    return ZKNavigationBarBackgroundStyleColor | ZKNavigationBarBackgroundStyleOpaque;
}

- (UIColor *)kai_navigationItemTintColor {
    return nil; //UIColor.whiteColor;
}

- (UIColor *)kai_navigationBarTintColor {
    return UIColor.whiteColor;
}

@end
