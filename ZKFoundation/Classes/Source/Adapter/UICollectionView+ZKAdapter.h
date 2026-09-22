//
//  UICollectionView+ZKHelper.h
//  ZKFoundation
//
//  Created by Kaiser on 2019/3/25.
//

#import <UIKit/UIKit.h>
#import "ZKCollectionViewAdapter.h"

NS_ASSUME_NONNULL_BEGIN

@interface UICollectionView (ZKAdapter)

@property (nonatomic, strong, readonly) ZKCollectionViewAdapter *adapter;

@end

NS_ASSUME_NONNULL_END
