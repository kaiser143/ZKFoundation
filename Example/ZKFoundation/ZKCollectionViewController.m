//
//  ZKCollectionViewController.m
//  ZKFoundation_Example
//
//  Created by zhangkai on 2019/12/3.
//  Copyright © 2019 zhangkai. All rights reserved.
//

#import "ZKCollectionViewController.h"
#import <ZKFoundation/ZKFoundation.h>
#import <Masonry/Masonry.h>
#import "ZKCollectionViewCell.h"
#import <ZKCategories/ZKCategories.h>

@interface ZKCollectionViewController () <ZKNavigationBarConfigureStyle>

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation ZKCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
    
    [self.collectionView.adapter registerNibs:@[@"ZKCollectionViewCell"]];
    [self.collectionView.adapter didSizeForItemAtIndexPath:^CGSize(UICollectionView * _Nonnull collectionView, UICollectionViewLayout * _Nonnull layout, NSIndexPath * _Nonnull indexPath, id  _Nonnull dataSource) {
        return CGSizeMake(ZKScreenSize().width/4 - 10, 80);
    }];
    [self.collectionView.adapter cellItemMargin:^UIEdgeInsets(UICollectionView * _Nonnull collectionView, UICollectionViewLayout * _Nonnull layout, NSInteger section, id  _Nonnull dataSource) {
        return UIEdgeInsetsMake(5, 5, 5, 5);
    }];
    [self.collectionView.adapter minimumInteritemSpacingForSection:^CGFloat(UICollectionView * _Nonnull collectionView, UICollectionViewLayout * _Nonnull layout, NSInteger section, id  _Nonnull dataSource) {
        return 0;
    }];
    [self.collectionView.adapter didSelectItem:^(UICollectionView * _Nonnull collectionView, NSIndexPath * _Nonnull indexPath, id  _Nonnull dataSource) {
        
    }];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    
    [self.collectionView.adapter stripAdapterData:@[@1, @2, @3, @4, @5, @6, @6, @6, @6, @6, @6, @6, @6, @6, @6, @6, @6]];
    
    [self setInterfaceOrientation:UIInterfaceOrientationLandscapeRight];
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeRight;
}

// 默认方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeRight;
}

- (void)setInterfaceOrientation:(UIInterfaceOrientation)orientation {
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        UIInterfaceOrientation val = orientation;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (CGFloat)kai_interactivePopMaxAllowedInitialDistanceToLeftEdge {
    return 44;
}

#pragma mark - :. ZKNavigationBarConfigureStyle

- (ZKNavigationBarConfigurations)kai_navigtionBarConfiguration {
    return ZKNavigationBarStyleBlack | ZKNavigationBarBackgroundStyleColor | ZKNavigationBarBackgroundStyleTranslucent;
}

- (UIColor *)kai_tintColor {
    return UIColor.whiteColor;
}

- (UIColor *)kai_barTintColor {
    return UIColor.orangeColor;
}

#pragma mark - :. getters and setters

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        ZKCollectionViewFlowLayout *layout = ZKCollectionViewFlowLayout.new;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.alwaysBounceVertical = YES;
        _collectionView.backgroundColor = UIColor.lightGrayColor;
        
        [self.view addSubview:_collectionView];
    }
    return _collectionView;
}

@end
