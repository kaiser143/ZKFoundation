//
//  ZKCollectionViewPagingLayout.m
//  ZKFoundation
//
//  Created by zhangkai on 2026/3/19.
//

#import "ZKCollectionViewPagingLayout.h"

@interface ZKCollectionViewPagingLayout ()
@property (nonatomic, assign) CGSize finalItemSize;
@end

@implementation ZKCollectionViewPagingLayout

- (instancetype)init {
    self = [super init];
    if (self) {
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.minimumLineSpacing = 0;
        self.minimumInteritemSpacing = 0;
        _allowsMultipleItemScroll = NO;
        _velocityForEnsurePageDown = 0.4;
        _multipleItemScrollVelocityLimit = 2.5;
        _pagingThreshold = 2.0 / 3.0;
    }
    return self;
}

- (void)prepareLayout {
    [super prepareLayout];
    CGSize itemSize = self.itemSize;
    id<UICollectionViewDelegateFlowLayout> layoutDelegate = (id<UICollectionViewDelegateFlowLayout>)self.collectionView.delegate;
    if ([layoutDelegate respondsToSelector:@selector(collectionView:layout:sizeForItemAtIndexPath:)]) {
        itemSize = [layoutDelegate collectionView:self.collectionView
                                           layout:self
                           sizeForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    }
    self.finalItemSize = itemSize;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return !CGSizeEqualToSize(self.collectionView.bounds.size, newBounds.size);
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    if (self.scrollDirection != UICollectionViewScrollDirectionHorizontal) {
        return [super targetContentOffsetForProposedContentOffset:proposedContentOffset withScrollingVelocity:velocity];
    }
    
    CGFloat itemSpacing = self.finalItemSize.width + self.minimumLineSpacing;
    if (itemSpacing <= 0) {
        return [super targetContentOffsetForProposedContentOffset:proposedContentOffset withScrollingVelocity:velocity];
    }
    
    CGSize contentSize = self.collectionViewContentSize;
    CGSize frameSize = self.collectionView.bounds.size;
    UIEdgeInsets contentInset = self.collectionView.adjustedContentInset;
    
    BOOL scrollingToRight = proposedContentOffset.x < self.collectionView.contentOffset.x;
    BOOL forcePaging = NO;
    CGPoint translation = [self.collectionView.panGestureRecognizer translationInView:self.collectionView];
    
    if (!self.allowsMultipleItemScroll || fabs(velocity.x) <= fabs(self.multipleItemScrollVelocityLimit)) {
        proposedContentOffset = self.collectionView.contentOffset;
        if (fabs(velocity.x) > self.velocityForEnsurePageDown) {
            forcePaging = YES;
        }
    }
    
    if (proposedContentOffset.x < -contentInset.left ||
        proposedContentOffset.x >= contentSize.width + contentInset.right - frameSize.width) {
        return proposedContentOffset;
    }
    
    CGFloat progress = ((contentInset.left + proposedContentOffset.x) + self.finalItemSize.width / 2.0) / itemSpacing;
    NSInteger currentIndex = (NSInteger)progress;
    NSInteger targetIndex = currentIndex;
    
    CGFloat remainder = progress - currentIndex;
    CGFloat offset = remainder * itemSpacing;
    BOOL shouldNext = (forcePaging || (offset / self.finalItemSize.width >= self.pagingThreshold)) && !scrollingToRight && velocity.x > 0;
    BOOL shouldPrev = (forcePaging || (offset / self.finalItemSize.width <= 1.0 - self.pagingThreshold)) && scrollingToRight && velocity.x < 0;
    
    // 手指位移超过半页时仍要根据 contentOffset 判断是否翻页，否则会出现「已经滑过一半却回弹」的问题
    if (translation.x < 0 && fabs(translation.x) > self.finalItemSize.width / 2.0 + self.minimumLineSpacing) {
        if (shouldNext) {
            targetIndex = currentIndex + 1;
        }
    } else if (translation.x > 0 && fabs(translation.x) > self.finalItemSize.width / 2.0) {
        if (shouldPrev) {
            targetIndex = currentIndex - 1;
        }
    } else {
        targetIndex = currentIndex + (shouldNext ? 1 : (shouldPrev ? -1 : 0));
    }
    
    proposedContentOffset.x = -contentInset.left + targetIndex * itemSpacing;
    return proposedContentOffset;
}

@end
