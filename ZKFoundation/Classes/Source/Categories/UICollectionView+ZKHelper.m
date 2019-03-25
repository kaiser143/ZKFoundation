//
//  UICollectionView+ZKHelper.m
//  FBSnapshotTestCase
//
//  Created by Kaiser on 2019/3/25.
//

#import "UICollectionView+ZKHelper.h"
#import <objc/runtime.h>

@implementation UICollectionView (ZKHelper)

- (ZKCollectionViewHelper *)collectionHelper {
    ZKCollectionViewHelper *curTableHelper = objc_getAssociatedObject(self, _cmd);
    if (curTableHelper) return curTableHelper;
    
    curTableHelper = ZKCollectionViewHelper.new;
    self.delegate = curTableHelper;
    self.dataSource = curTableHelper;
    curTableHelper.kai_collectionView = self;
    objc_setAssociatedObject(self, _cmd, curTableHelper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    return curTableHelper;
}

@end
