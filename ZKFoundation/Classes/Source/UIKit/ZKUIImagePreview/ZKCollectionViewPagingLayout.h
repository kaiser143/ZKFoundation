//
//  ZKCollectionViewPagingLayout.h
//  ZKFoundation
//
//  Created by zhangkai on 2026/3/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 横向分页 UICollectionViewFlowLayout。
 * 用于 ZKUIImagePreviewView 一页一图的滚动体验。
 */
@interface ZKCollectionViewPagingLayout : UICollectionViewFlowLayout

/// 是否允许一次滑动翻过多页，默认 NO
@property (nonatomic, assign) BOOL allowsMultipleItemScroll;

/// 超过该速度强制翻页，默认 0.4
@property (nonatomic, assign) CGFloat velocityForEnsurePageDown;

/// 支持多页滚动时的速度阈值，默认 2.5
@property (nonatomic, assign) CGFloat multipleItemScrollVelocityLimit;

/// 翻页临界比例，默认 2/3
@property (nonatomic, assign) CGFloat pagingThreshold;

@end

NS_ASSUME_NONNULL_END
