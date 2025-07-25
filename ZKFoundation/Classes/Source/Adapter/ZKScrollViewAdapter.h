//
//  ZKScrollViewAdapter.h
//  ZKFoundation
//
//  Created by Kaiser on 2020/11/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^ZKScrollAdapterWillBeginDraggingBlock)(UIScrollView *scrollView);
typedef void (^ZKScrollAdapterDidScrollBlock)(UIScrollView *scrollView);
typedef void (^ZKScrollAdapterScrollViewDidEndScrollingAnimationBlock)(UIScrollView *scrollView);
typedef void (^ZKScrollAdapterDidEndDraggingBlock)(UIScrollView *scrollView, BOOL decelerate);
typedef void (^ZKScrollAdapterWillEndDraggingBlock)(UIScrollView *scrollView, CGPoint velocity, CGPoint *targetContentOffset);
typedef void (^ZKScrollAdapterDidEndDeceleratingBlock)(UIScrollView *scrollView);

@interface ZKScrollViewAdapter : NSObject

@property (nonatomic, weak) UIScrollView *kai_scrollView;

- (void)willBeginDragging:(ZKScrollAdapterWillBeginDraggingBlock)block;
- (void)didScroll:(ZKScrollAdapterDidScrollBlock)block;

- (void)willEndDragging:(ZKScrollAdapterWillEndDraggingBlock)block;
- (void)didEndDragging:(ZKScrollAdapterDidEndDraggingBlock)block;

- (void)didEndDecelerating:(ZKScrollAdapterDidEndDeceleratingBlock)block;

@end

NS_ASSUME_NONNULL_END
