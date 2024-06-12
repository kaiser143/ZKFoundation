//
//  NavigationController.m
//  ZKFoundation_Example
//
//  Created by zhangkai on 2019/11/15.
//  Copyright © 2019 zhangkai. All rights reserved.
//

#import "NavigationController.h"
#import <ZKFoundation.h>

@interface NavigationController () <ZKNavigationBarConfigureStyle>

@end

@implementation NavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = UIColor.lightGrayColor;
}

- (BOOL)shouldAutorotate {
    return self.topViewController.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return self.topViewController.supportedInterfaceOrientations;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return self.topViewController.preferredInterfaceOrientationForPresentation;
}

#pragma mark - :. ZKNavigationBarConfigureStyle

- (ZKNavigationBarConfigurations)kai_navigtionBarConfiguration {
    return ZKNavigationBarStyleLight | ZKNavigationBarBackgroundStyleColor | ZKNavigationBarBackgroundStyleTransparent;
}

- (UIColor *)kai_navigationItemTintColor {
    return nil; //UIColor.whiteColor;
}

- (UIColor *)kai_navigationBarTintColor {
    return UIColor.lightGrayColor;
}

@end
