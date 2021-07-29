//
//  ZKNavigationConfigureViewController.h
//  ZKFoundation_Example
//
//  Created by zhangkai on 2021/7/28.
//  Copyright © 2021 zhangkai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ZKFoundation/ZKFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZKNavigationConfigureViewController : UIViewController

@property (nonatomic, assign) ZKNavigationBarConfigurations configurations;
@property (nonatomic, strong) UIColor *tintColor;
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) UIImage *backgroundImage;
@property (nonatomic, copy)  NSString *backgroundImageName;

@end

NS_ASSUME_NONNULL_END
