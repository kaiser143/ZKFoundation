//
//  UICollectionView+ZKHelper.h
//  ZKFoundation
//
//  Created by Kaiser on 2019/3/25.
//

#import <UIKit/UIKit.h>
#import "ZKCollectionViewHelper.h"

NS_ASSUME_NONNULL_BEGIN

@interface UICollectionView (ZKHelper)

@property (nonatomic, strong, readonly) ZKCollectionViewHelper *collectionHelper;

@end

NS_ASSUME_NONNULL_END
