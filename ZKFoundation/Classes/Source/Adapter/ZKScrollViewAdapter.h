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

@interface ZKScrollViewAdapter : NSObject

@property (nonatomic, weak) UIScrollView *kai_scrollView;

- (void)didScrollViewWillBeginDragging:(ZKScrollAdapterWillBeginDraggingBlock)block;
- (void)didScrollViewDidScroll:(ZKScrollAdapterDidScrollBlock)block;

- (void)scrollViewWillEndDragging:(ZKScrollAdapterWillEndDraggingBlock)block;
- (void)scrollViewDidEndDragging:(ZKScrollAdapterDidEndDraggingBlock)block;

@end

NS_ASSUME_NONNULL_END
