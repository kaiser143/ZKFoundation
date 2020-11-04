//
//  ZKRouterViewController.m
//  ZKFoundation
//
//  Created by zhangkai on 2020/11/4.
//  Copyright © 2020 zhangkai. All rights reserved.
//

#import "ZKRouterViewController.h"

#if __has_include(<ZKCategories / ZKCategories.h>)
#import <ZKCategories/ZKCategories.h>
#else
#import "ZKCategories.h"
#endif

#if __has_include(<Masonry / Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif

#import <ZKFoundation/ZKFoundation.h>
#import <Masonry/Masonry.h>
#import <MapKit/MapKit.h>

@interface ZKTableView : UITableView
@property (nonatomic, weak) MKMapView *mapView;
@property (nonatomic, assign) BOOL hits;

@end
@implementation ZKTableView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.hits) return nil;

    UIView *view = [super hitTest:point withEvent:event];
    if (self.mapView && (view == self.tableHeaderView || point.y < self.contentInsetTop)) {
        self.hits       = YES;
        CGPoint tmp     = [self.superview convertPoint:point fromView:self];
        UIView *hitView = [self.superview hitTest:tmp withEvent:event];
        self.hits       = NO;
        if (self.mapView == [hitView ancestorOrSelfWithClass:self.mapView.class]) return hitView;
    }

    return view;
}

@end

@interface ZKRouterViewController () <ZKNavigationBarConfigureStyle, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIPanGestureRecognizer *popGestureRecognizer;
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) ZKTableView *tableView;
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, strong) UIColor *barTintColor;

@end

@implementation ZKRouterViewController

#pragma mark - :. Initializer

#pragma mark - :. life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.edgesForExtendedLayout           = UIRectEdgeAll;
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.title                            = @"Demo";

    @weakify(self);
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.mapView];
    [self.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).priorityHigh();
        make.top.equalTo(self.mas_topLayoutGuideTop);
    }];

    self.barTintColor = UIColor.whiteColor;

    self.tableView                 = [[ZKTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.mapView         = self.mapView;
    self.tableView.backgroundColor = UIColor.clearColor;
    self.tableView.rowHeight       = 100;
    //    self.tableView.contentInsetTop = 550;

    self.tableView.tableHeaderView                 = UIView.new;
    self.tableView.tableHeaderView.height          = 550;
    self.tableView.tableHeaderView.backgroundColor = UIColor.clearColor;
    self.tableView.showsVerticalScrollIndicator    = NO;

    [self.tableView.tableAdapter registerNibs:@[@"UITableViewCell"]];
    [self.tableView.tableAdapter cellWillDisplay:^(__kindof UITableViewCell *_Nonnull cell, NSIndexPath *_Nonnull indexPath, id _Nonnull dataSource, BOOL isCellDisplay) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }];
    [self.tableView.tableAdapter scrollViewWillEndDragging:^(UIScrollView *_Nonnull scrollView, CGPoint velocity, CGPoint *_Nonnull targetContentOffset){

    }];
    [self.tableView.tableAdapter didScrollViewDidScroll:^(UIScrollView *_Nonnull scrollView) {
        @strongify(self);
        CGFloat headerHeight = 550;
        if (@available(iOS 11, *)) {
            headerHeight -= self.view.safeAreaInsets.top;
        } else {
            headerHeight -= [self.topLayoutGuide length];
        }

        CGFloat progress         = scrollView.contentOffset.y + scrollView.contentInset.top;
        CGFloat gradientProgress = MIN(1, MAX(0, progress / headerHeight));
        gradientProgress         = gradientProgress * gradientProgress * gradientProgress * gradientProgress;
        if (gradientProgress != self.progress) {
            self.progress = gradientProgress;
            [self kai_refreshNavigationBarStyle];
        }
    }];
    [self.tableView.tableAdapter stripAdapterData:@[@1, @1, @1, @1, @1, @1, @1, @1, @1, @1, @1, @1, @1, @1, @1, @1, @1, @1, @1, @1, @1, @1, @1, @1, @1, @1, @1, @1, @1, @1, @1, @1, @1, @1, @1, @1, @1]];

    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).priorityHigh();
        make.bottom.equalTo(self.mas_bottomLayoutGuideBottom);
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

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
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
    //    return ZKNavigationBarBackgroundStyleColor | ZKNavigationBarBackgroundStyleTranslucent | ZKNavigationBarConfigurationsDefault;
    ZKNavigationBarConfigurations configurations = ZKNavigationBarConfigurationsDefault;
    if (_progress < 0.5)
        configurations |= ZKNavigationBarStyleBlack;
    else if (_progress == 1)
        configurations |= ZKNavigationBarBackgroundStyleOpaque;

    configurations |= ZKNavigationBarBackgroundStyleColor;
    return configurations;
    ;
}

- (UIColor *)kai_barTintColor {
    //    return self.navigationController.viewControllers.count == 2 ? UIColor.cyanColor : self.barTintColor;
    return [UIColor.whiteColor colorWithAlphaComponent:self.progress];
}

- (UIColor *)kai_tintColor {
    return UIColor.blackColor;
}

#pragma mark - :. events response

#pragma mark - :. public method

#pragma mark - :. private method

- (void)bindViewModel {
}

- (void)setupViewConstraints {
}

#pragma mark - :. getters and setters

- (CGFloat)kai_interactivePopMaxAllowedInitialDistanceToLeftEdge {
    return 44;
}

@end
