//
//  ViewController.m
//  ZKNavigation
//
//  Created by Kaiser on 2017/2/4.
//  Copyright © 2017年 Kaiser. All rights reserved.
//

#import "ZKMapViewController.h"
#import <ZKCategories/ZKCategories.h>
#import "UIViewController+ZKNavigationBarTransition.h"
#import <ZKFoundation/ZKFoundation.h>
#import <Masonry/Masonry.h>
#import <MapKit/MapKit.h>

@interface ZKMapViewController () <ZKNavigationBarConfigureStyle, UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UIPanGestureRecognizer *popGestureRecognizer;
@property (nonatomic, strong) MKMapView *mapView;

@end

@implementation ZKMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    @weakify(self);
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                           target:nil
                                                                           action:nil];
    space.width = -8;

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"barbuttonicon_back_cube"
                                              inBundle:nil
                         compatibleWithTraitCollection:nil]
            forState:UIControlStateNormal];
    [button addTarget:self action:@selector(didTappedBackButton) forControlEvents:UIControlEventTouchUpInside];
    [button addBlockForControlEvents:UIControlEventTouchUpInside
                               block:^(__kindof UIControl *_Nonnull sender) {
                                   @strongify(self);
                                   [self kai_popViewControllerAnimated];
                               }];
    [button sizeToFit];

    UIBarButtonItem *backBarButtonItem     = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItems = @[space, backBarButtonItem];

    self.mapView = [[MKMapView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.mapView];
    [self.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    NSArray *internalTargets = [self.navigationController.interactivePopGestureRecognizer valueForKey:@"targets"];
    id internalTarget        = [internalTargets.firstObject valueForKey:@"target"];
    SEL internalAction       = NSSelectorFromString(@"handleNavigationTransition:");

    self.popGestureRecognizer          = [[UIPanGestureRecognizer alloc] initWithTarget:internalTarget action:internalAction];
    self.popGestureRecognizer.delegate = self;
    [self.mapView addGestureRecognizer:self.popGestureRecognizer];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark - :. UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return [self interactivePopEnable:gestureRecognizer];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    BOOL result = NO;
    if ((gestureRecognizer == self.popGestureRecognizer) && [self interactivePopEnable:self.popGestureRecognizer] && [[otherGestureRecognizer view] isDescendantOfView:[gestureRecognizer view]]) {
        result = YES;
    }
    return result;
}

//location_X可自己定义,其代表的是滑动返回距左边的有效长度
- (BOOL)interactivePopEnable:(UIGestureRecognizer *)gestureRecognizer {
    //是滑动返回距左边的有效长度
    int location_X = ZKScreenSize().width * 0.15;
    if (gestureRecognizer == self.popGestureRecognizer) {
        UIGestureRecognizerState state = gestureRecognizer.state;
        if (UIGestureRecognizerStateBegan == state || UIGestureRecognizerStatePossible == state) {
            CGPoint location = [gestureRecognizer locationInView:gestureRecognizer.view];

            //这是允许每张图片都可实现滑动返回
            int temp1    = location.x;
            int temp2    = ZKScreenSize().width;
            NSInteger XX = temp1 % temp2;
            return (XX < location_X);
        }
    }
    return NO;
}

#pragma mark - :. ZKNavigationBarConfigureStyle

- (ZKNavigationBarConfigurations)kai_navigtionBarConfiguration {
    return ZKNavigationBarBackgroundStyleNone | ZKNavigationBarBackgroundStyleTransparent;
}

/*!
 *  @brief    navigationBar上面的按钮颜色
 */
- (UIColor *)kai_tintColor {
    return UIColor.whiteColor;
}

- (void)didTappedBackButton {
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
