//
//  ZKScrollViewAdapter.m
//  ZKFoundation
//
//  Created by Kaiser on 2020/11/12.
//

#import "ZKScrollViewAdapter.h"

@interface ZKScrollViewAdapter () <UIScrollViewDelegate>

@property (nonatomic, copy) ZKScrollAdapterWillBeginDraggingBlock scrollViewBdBlock;
@property (nonatomic, copy) ZKScrollAdapterDidScrollBlock scrollViewddBlock;

@property (nonatomic, copy) ZKScrollAdapterWillEndDraggingBlock scrollViewWillEndDraggingBlock;
@property (nonatomic, copy) ZKScrollAdapterDidEndDraggingBlock scrollViewDidEndDraggingBlock;
@property (nonatomic, copy) ZKScrollAdapterScrollViewDidEndScrollingAnimationBlock scrollViewDidEndScrollingAnimationBlock;

@end

@implementation ZKScrollViewAdapter

#pragma mark - :. UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.scrollViewBdBlock)
        self.scrollViewBdBlock(scrollView);
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.scrollViewddBlock) {
        self.scrollViewddBlock(scrollView);
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (self.scrollViewDidEndDraggingBlock)
        self.scrollViewDidEndDraggingBlock(scrollView, decelerate);
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (self.scrollViewWillEndDraggingBlock)
        self.scrollViewWillEndDraggingBlock(scrollView, velocity, targetContentOffset);
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(scrollViewDidEndScrollingAnimation:) object:scrollView];
    if (self.scrollViewDidEndScrollingAnimationBlock && scrollView)
        self.scrollViewDidEndScrollingAnimationBlock(scrollView);
}

#pragma mark - :. public methods

- (void)didScrollViewWillBeginDragging:(ZKScrollAdapterWillBeginDraggingBlock)block {
    self.scrollViewBdBlock = block;
}

- (void)didScrollViewDidScroll:(ZKScrollAdapterDidScrollBlock)block {
    self.scrollViewddBlock = block;
}

- (void)scrollViewWillEndDragging:(ZKScrollAdapterWillEndDraggingBlock)block {
    self.scrollViewWillEndDraggingBlock = block;
}

- (void)scrollViewDidEndDragging:(ZKScrollAdapterDidEndDraggingBlock)block {
    self.scrollViewDidEndDraggingBlock = block;
}

@end
