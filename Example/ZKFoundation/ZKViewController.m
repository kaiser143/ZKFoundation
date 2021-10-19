//
//  ZKViewController.m
//  ZKFoundation
//
//  Created by zhangkai on 03/08/2019.
//  Copyright (c) 2019 zhangkai. All rights reserved.
//

#import "ZKViewController.h"
#import <Masonry/Masonry.h>
#import <ZKCategories/ZKCategories.h>
#import <ZKFoundation/ZKFoundation.h>
#import "ZKWebViewController.h"
#import "ZKCollectionViewController.h"
#import "ZKMapViewController.h"
#import "ZKTableViewController.h"
#import "ZKRouterViewController.h"
#import "ZKNavigationConfigureViewController.h"

@interface ZKViewController () <ZKNavigationBarConfigureStyle, UIScrollViewDelegate, ZKPopupControllerDelegate>

@property (nonatomic, strong) UIColor *barTintColor;
@property (nonatomic, strong) ZKStorkInteractiveTransition *animator;
@property (nonatomic, strong) ZKPopupController *popup;

@end

@implementation ZKViewController {
    CGFloat _progress;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = UIColor.whiteColor;
    self.title                = @"ZKFoundation";
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars = YES;
    
//    self.barTintColor = [UIColor.redColor colorWithAlphaComponent:0.5];
    self.barTintColor = UIColor.redColor;
    self.navigationController.view.backgroundColor = UIColor.whiteColor;
    
    UIScrollView *scrollView = UIScrollView.new;
//    scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAutomatic;
    scrollView.delegate = self;
    [self.view addSubview:scrollView];
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    @weakify(self);
    ZKInitialsPlaceholderView *placeholderView = [[ZKInitialsPlaceholderView alloc] initWithDiameter:50];
    placeholderView.initials                   = @"张";
    placeholderView.circleColor                = [UIColor randomColor];
    [scrollView addSubview:placeholderView];
    [placeholderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(scrollView);
        make.top.equalTo(scrollView).offset(200);
        make.size.mas_equalTo(CGSizeMake(50, 50));
    }];

    UIView *view = UIView.new;
    [scrollView addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(placeholderView.mas_bottom).offset(100);
        make.centerX.equalTo(self.view);
    }];

    UIButton *normal = [UIButton buttonWithType:UIButtonTypeCustom];
    [normal setImage:[UIImage imageNamed:@"arrow_l"] forState:UIControlStateNormal];
    [normal setTitle:@"去开启" forState:UIControlStateNormal];
    [normal setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    normal.titleLabel.font     = [UIFont systemFontOfSize:12];
    normal.contentEdgeInsets = UIEdgeInsetsMake(4, 8, 4, 8);
    kai_view_border_radius(normal, 3, 1.f, UIColor.redColor);
    [view addSubview:normal];
    [normal mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.lessThanOrEqualTo(view);
        make.left.centerY.equalTo(view);
//        make.size.mas_equalTo(CGSizeMake(100, 100));
    }];

    ZKButton *button = [ZKButton buttonWithType:UIButtonTypeCustom];
    button.style     = ZKButtonStyleImageAtLeft;
    [button setImage:[UIImage imageNamed:@"arrow_l"] forState:UIControlStateNormal];
    [button setTitle:@"去开启" forState:UIControlStateNormal];
    [button setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:12];
    button.space = 8.f;
    button.contentEdgeInsets = UIEdgeInsetsMake(4, 8, 4, 8);
    kai_view_border_radius(button, 3, 1.f, UIColor.redColor);
    [view addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(normal.mas_right).offset(20);
        make.right.centerY.equalTo(view);
        make.height.lessThanOrEqualTo(view);
//        make.size.mas_equalTo(CGSizeMake(100, 100));
    }];

    ZKTintedActionButton *action = [ZKTintedActionButton buttonWithType:UIButtonTypeCustom];
    action.tintColor             = UIColor.redColor;
    action.layer.cornerRadius    = 8;
    [action setTitle:@"Collection" forState:UIControlStateNormal];
    [action addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:action];
    [action mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(220);
        make.height.mas_equalTo(48);
        make.centerX.equalTo(self.view);
        make.top.equalTo(view.mas_bottom).offset(30);
    }];

    ZKAuto test             = [ZKTintedActionButton buttonWithType:UIButtonTypeCustom];
    test.tintColor          = UIColor.redColor;
    test.layer.cornerRadius = 8;
    [test setTitle:@"Table" forState:UIControlStateNormal];
    [test addBlockForControlEvents:UIControlEventTouchUpInside
                             block:^(__kindof UIControl *_Nonnull sender) {
                                 @strongify(self);
                                 [self kai_pushViewController:ZKTableViewController.new];
                             }];
    [scrollView addSubview:test];
    [test mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(220);
        make.height.mas_equalTo(48);
        make.centerX.equalTo(self.view);
        make.top.equalTo(action.mas_bottom).offset(20);
    }];
    
    action             = [ZKTintedActionButton buttonWithType:UIButtonTypeCustom];
    action.tintColor          = UIColor.redColor;
    action.layer.cornerRadius = 8;
    [action setTitle:@"地图" forState:UIControlStateNormal];
    [action addBlockForControlEvents:UIControlEventTouchUpInside
                             block:^(__kindof UIControl *_Nonnull sender) {
                                 @strongify(self);
                                 [self kai_pushViewController:ZKMapViewController.new];
                             }];
    [scrollView addSubview:action];
    [action mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(220);
        make.height.mas_equalTo(48);
        make.centerX.equalTo(self.view);
        make.top.equalTo(test.mas_bottom).offset(20);
    }];

    test             = [ZKTintedActionButton buttonWithType:UIButtonTypeCustom];
    test.tintColor          = UIColor.redColor;
    test.layer.cornerRadius = 8;
    [test setTitle:@"webView" forState:UIControlStateNormal];
    [test addBlockForControlEvents:UIControlEventTouchUpInside
                             block:^(__kindof UIControl *_Nonnull sender) {
                                 @strongify(self);
                                 NSString *const githubLink = @"http://www.baidu.com";
                                 ZKWebViewController *controller = [[ZKWebViewController alloc] initWithURL:githubLink.URL];
                                 [self kai_pushViewController:controller];
                             }];
    [scrollView addSubview:test];
    [test mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(220);
        make.height.mas_equalTo(48);
        make.centerX.equalTo(self.view);
        make.top.equalTo(action.mas_bottom).offset(20);
    }];
    
    action             = [ZKTintedActionButton buttonWithType:UIButtonTypeCustom];
    action.tintColor          = UIColor.redColor;
    action.layer.cornerRadius = 8;
    [action setTitle:@"地图&Table" forState:UIControlStateNormal];
    [action addBlockForControlEvents:UIControlEventTouchUpInside
                             block:^(__kindof UIControl *_Nonnull sender) {
                                 @strongify(self);
                                 [self kai_pushViewController:ZKRouterViewController.new];
                             }];
    [scrollView addSubview:action];
    [action mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(220);
        make.height.mas_equalTo(48);
        make.centerX.equalTo(self.view);
        make.top.equalTo(test.mas_bottom).offset(20);
    }];
    
    test             = [ZKTintedActionButton buttonWithType:UIButtonTypeCustom];
    test.tintColor          = UIColor.redColor;
    test.layer.cornerRadius = 8;
    [test setTitle:@"present" forState:UIControlStateNormal];
    [test addBlockForControlEvents:UIControlEventTouchUpInside
                             block:^(__kindof UIControl *_Nonnull sender) {
                                 @strongify(self);
                                 ZKAuto controller = ZKTableViewController.new;
                                 UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
                                 nav.modalPresentationStyle = UIModalPresentationCustom;

                                 self.animator = [[ZKStorkInteractiveTransition alloc] initWithModalViewController:nav];
                                 self.animator.transitionDuration = 0.6f;
                                 [self.animator setContentScrollView:controller.tableView];

                                 nav.transitioningDelegate = self.animator;
                                 [self presentViewController:nav animated:YES completion:nil];
        
                             }];
    [scrollView addSubview:test];
    [test mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(220);
        make.height.mas_equalTo(48);
        make.centerX.equalTo(self.view);
        make.top.equalTo(action.mas_bottom).offset(20);
    }];
    
    action             = [ZKTintedActionButton buttonWithType:UIButtonTypeCustom];
    action.tintColor          = UIColor.redColor;
    action.layer.cornerRadius = 8;
    [action setTitle:@"Popup" forState:UIControlStateNormal];
    [action addBlockForControlEvents:UIControlEventTouchUpInside
                             block:^(__kindof UIControl *_Nonnull sender) {
                                 @strongify(self);
        [self showPopupWithStyle:ZKPopupStyleActionSheet];
                             }];
    [scrollView addSubview:action];
    [action mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(220);
        make.height.mas_equalTo(48);
        make.centerX.equalTo(self.view);
        make.top.equalTo(test.mas_bottom).offset(20);
    }];
    
    test             = [ZKTintedActionButton buttonWithType:UIButtonTypeCustom];
    test.tintColor          = UIColor.redColor;
    test.layer.cornerRadius = 8;
    [test setTitle:@"NavigationBar" forState:UIControlStateNormal];
    [test addBlockForControlEvents:UIControlEventTouchUpInside
                             block:^(__kindof UIControl *_Nonnull sender) {
                                 @strongify(self);
                                 ZKAuto controller         = ZKNavigationConfigureViewController.new;
                                 controller.configurations = ZKNavigationBarBackgroundStyleOpaque;
                                 [self kai_pushViewController:controller];
                             }];
    [scrollView addSubview:test];
    [test mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(220);
        make.height.mas_equalTo(48);
        make.centerX.equalTo(self.view);
        make.top.equalTo(action.mas_bottom).offset(20);
        make.bottom.lessThanOrEqualTo(scrollView).offset(-20);
    }];
    
    if (self.navigationController.viewControllers.count != 1) {
        UIBarButtonItem *popToRoot = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                                   target:nil
                                                                                   action:nil];
        popToRoot.actionBlock = ^(id _Nonnull sender) {
            @strongify(self);
            [self kai_popToRootViewControllerAnimated];
        };
        self.navigationItem.rightBarButtonItem = popToRoot;
    } else {
        UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                     target:self
                                                                                     action:@selector(shareAction:)];
        self.navigationItem.rightBarButtonItem = shareButton;
    }
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

#pragma mark - :. UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat headerHeight = 80;
    if (@available(iOS 11,*)) {
       headerHeight -= self.view.safeAreaInsets.top;
    } else {
       headerHeight -= [self.topLayoutGuide length];
    }

    CGFloat progress = scrollView.contentOffset.y;// + scrollView.contentInset.top;
    CGFloat gradientProgress = MIN(1, MAX(0, progress  / headerHeight));
    gradientProgress = gradientProgress * gradientProgress * gradientProgress * gradientProgress;
    if (gradientProgress != _progress) {
       _progress = gradientProgress;
       [self kai_refreshNavigationBarStyle];
    }
}

#pragma mark - :. ZKNavigationBarConfigureStyle

- (ZKNavigationBarConfigurations)kai_navigtionBarConfiguration {
//    return ZKNavigationBarBackgroundStyleColor | ZKNavigationBarBackgroundStyleTranslucent | ZKNavigationBarConfigurationsDefault;
    ZKNavigationBarConfigurations configurations = ZKNavigationBarConfigurationsDefault;
    if (_progress == 0) configurations |= ZKNavigationBarBackgroundStyleTransparent;
    else if (_progress < 0.5) configurations |= ZKNavigationBarStyleBlack;
    else if (_progress == 1) configurations |= ZKNavigationBarBackgroundStyleOpaque;
        
    configurations |= ZKNavigationBarBackgroundStyleColor;
    return configurations;;
}

- (UIColor *)kai_barTintColor {
//    return self.navigationController.viewControllers.count == 2 ? UIColor.cyanColor : self.barTintColor;
    return [UIColor.redColor colorWithAlphaComponent:_progress];
}

- (UIColor *)kai_tintColor {
//    return nil; //UIColor.redColor;
    return UIColor.whiteColor;
}

#pragma mark - :. ZKPopupControllerDelegate

- (void)popupControllerDidDismiss:(ZKPopupController *)controller {
    
}

- (void)popupControllerDidPresent:(ZKPopupController *)controller {
    
}

#pragma mark - :. event Handle

- (void)shareAction:(id)sender {
    NSString *const githubLink      = @"https://github.com/kaiser143/ZKFoundation";
    NSURL *shareURL                 = [NSURL URLWithString:githubLink];
    UIActivityViewController *share = [[UIActivityViewController alloc] initWithActivityItems:@[shareURL]
                                                                        applicationActivities:nil];
    share.popoverPresentationController.barButtonItem = sender;
    [self presentViewController:share animated:YES completion:nil];
}

- (void)buttonTapped:(UIButton *)sender {
    //    ZKViewController *controller = [[ZKViewController alloc] init];
    //    [self kai_pushViewController:controller animated:YES];

//        NSString *const githubLink = @"http://www.baidu.com";
//        ZKWebViewController *controller = [[ZKWebViewController alloc] initWithURL:githubLink.URL];
//        [self kai_pushViewController:controller];

    ZKAuto controller = ZKCollectionViewController.new;
    [self kai_pushViewController:controller];

    //    UIViewController *controller = UIViewController.new;
    //    controller.view.backgroundColor = UIColor.randomColor;
    //    controller.title = @"ViewController";
    //    [self kai_pushViewController:controller];

    //    [ZKPermission.manager requestWithType:ZKPermissionTypeContact
    //                                 callback:^(BOOL response, ZKPermissionAuthorizationStatus status) {
    //                                     if (response) {
    //                                         UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
    //                                                                                                        message:@"获取权限成功"
    //                                                                                                 preferredStyle:UIAlertControllerStyleAlert];
    //                                         UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK"
    //                                                                                          style:UIAlertActionStyleDefault
    //                                                                                        handler:^(UIAlertAction * _Nonnull action) {
    //
    //                                                                                        }];
    //                                         [alert addAction:action];
    //                                         [self presentViewController:alert animated:YES completion:nil];
    //                                     }
    //                                 }];
}

//- (CGFloat)kai_interactivePopMaxAllowedInitialDistanceToLeftEdge {
//    return 80;
//}

- (UIColor *)barTintColor {
    if (!_barTintColor) {
        _barTintColor = UIColor.randomColor;
    }
    return _barTintColor;
}

#pragma mark - :. private methods

- (void)showPopupWithStyle:(ZKPopupStyle)popupStyle {
    @weakify(self);
    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSAttributedString *title = [[NSAttributedString alloc] initWithString:@"It's A Popup!" attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:24], NSParagraphStyleAttributeName : paragraphStyle}];
    NSAttributedString *lineOne = [[NSAttributedString alloc] initWithString:@"You can add text and images" attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18], NSParagraphStyleAttributeName : paragraphStyle}];
    NSAttributedString *lineTwo = [[NSAttributedString alloc] initWithString:@"With style, using NSAttributedString" attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18], NSForegroundColorAttributeName : [UIColor colorWithRed:0.46 green:0.8 blue:1.0 alpha:1.0], NSParagraphStyleAttributeName : paragraphStyle}];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 200, 60)];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [button setTitle:@"Close Me" forState:UIControlStateNormal];
    button.backgroundColor = [UIColor colorWithRed:0.46 green:0.8 blue:1.0 alpha:1.0];
    button.layer.cornerRadius = 4;
    [button addBlockForControlEvents:UIControlEventTouchUpInside block:^(__kindof UIButton * _Nonnull sender) {
        @strongify(self);
        [self.popup dismissPopupControllerAnimated:YES];
        NSLog(@"Block for button: %@", sender.titleLabel.text);
    }];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.numberOfLines = 0;
    titleLabel.attributedText = title;
    
    UILabel *lineOneLabel = [[UILabel alloc] init];
    lineOneLabel.numberOfLines = 0;
    lineOneLabel.attributedText = lineOne;
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithColor:[UIColor randomColor]]];
    imageView.size = CGSizeMake(150, 200);
    
    UILabel *lineTwoLabel = [[UILabel alloc] init];
    lineTwoLabel.numberOfLines = 0;
    lineTwoLabel.attributedText = lineTwo;
    
    
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 55)];
    customView.backgroundColor = [UIColor lightGrayColor];
    
    UITextField *textFied = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, 230, 35)];
    textFied.borderStyle = UITextBorderStyleRoundedRect;
    textFied.placeholder = @"Custom view!";
    [customView addSubview:textFied];
    
    self.popup = [[ZKPopupController alloc] initWithContents:@[titleLabel, lineOneLabel, imageView, lineTwoLabel, customView, button]];
    self.popup.theme = [ZKPopupTheme defaultTheme];
    self.popup.theme.popupStyle = popupStyle;
    self.popup.theme.maxPopupWidth = ZKScreenSize().width;
    self.popup.delegate = self;
    [self.popup presentPopupControllerAnimated:YES];
}

@end
