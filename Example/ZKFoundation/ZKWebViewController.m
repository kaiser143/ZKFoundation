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
}

#pragma mark - :. ZKNavigationBarConfigureStyle

- (ZKNavigationBarConfigurations)kai_navigtionBarConfiguration {
    return ZKNavigationBarBackgroundStyleColor | ZKNavigationBarBackgroundStyleOpaque;
}

- (UIColor *)kai_tintColor {
    return UIColor.whiteColor;
}

- (UIColor *)kai_barTintColor {
    return UIColor.redColor;
}

- (BOOL)kai_prefersNavigationBarHidden {
    return NO;
}

@end
