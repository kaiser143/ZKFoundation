//
//  UICollectionView+ZKHelper.m
//  ZKFoundation
//
//  Created by Kaiser on 2019/3/25.
//

#import "UICollectionView+ZKAdapter.h"
#import <objc/runtime.h>

@implementation UICollectionView (ZKAdapter)

- (ZKCollectionViewAdapter *)collectionAdapter {
    ZKCollectionViewAdapter *tableHelper = objc_getAssociatedObject(self, _cmd);
    if (tableHelper) return tableHelper;
    
    tableHelper = ZKCollectionViewAdapter.new;
    tableHelper.kai_collectionView = self;
    self.delegate = tableHelper;
    self.dataSource = tableHelper;
    objc_setAssociatedObject(self, _cmd, tableHelper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return tableHelper;
}

@end
