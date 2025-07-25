//
//  UICollectionView+ZKHelper.m
//  ZKFoundation
//
//  Created by Kaiser on 2019/3/25.
//

#import "UICollectionView+ZKAdapter.h"
#import "NSObject+ZKMultipleDelegates.h"
#import <ZKCategories/ZKCategories.h>

@implementation UICollectionView (ZKAdapter)

- (ZKCollectionViewAdapter *)adapter {
    ZKCollectionViewAdapter<UICollectionViewDelegate, UICollectionViewDataSource> *tableHelper = [self associatedValueForKey:_cmd];
    if (tableHelper) return tableHelper;
    
    tableHelper = ZKCollectionViewAdapter.new;
    tableHelper.kai_collectionView = self;
    self.kai_multipleDelegatesEnabled = YES;
    self.delegate = tableHelper;
    self.dataSource = tableHelper;
    [self setAssociateValue:tableHelper withKey:_cmd];
    return tableHelper;
}

@end
