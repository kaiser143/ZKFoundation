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
    
    [self.collectionView.collectionAdapter registerNibs:@[@"ZKCollectionViewCell"]];
    [self.collectionView.collectionAdapter didSizeForItemAtIndexPath:^CGSize(UICollectionView * _Nonnull collectionView, UICollectionViewLayout * _Nonnull layout, NSIndexPath * _Nonnull indexPath, id  _Nonnull dataSource) {
        return CGSizeMake(80, 80);
    }];
    [self.collectionView.collectionAdapter cellItemMargin:^UIEdgeInsets(UICollectionView * _Nonnull collectionView, UICollectionViewLayout * _Nonnull layout, NSInteger section, id  _Nonnull dataSource) {
        return UIEdgeInsetsMake(5, 5, 5, 5);
    }];
    [self.collectionView.collectionAdapter minimumInteritemSpacingForSection:^CGFloat(UICollectionView * _Nonnull collectionView, UICollectionViewLayout * _Nonnull layout, NSInteger section, id  _Nonnull dataSource) {
        return 0;
    }];
    [self.collectionView.collectionAdapter didSelectItem:^(UICollectionView * _Nonnull collectionView, NSIndexPath * _Nonnull indexPath, id  _Nonnull dataSource) {
        
    }];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    
    [self.collectionView.collectionAdapter stripAdapterData:@[@1, @2, @3, @4, @5, @6, @6, @6, @6, @6, @6, @6, @6, @6, @6, @6, @6]];
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
