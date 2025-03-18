//
//  ZKSegment.h
//  ZKFoundation
//
//  Created by Kaiser on 2019/5/5.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@protocol ZKSegmentControlDelegate <NSObject>

@optional
- (void)didScrollSelectedIndex:(NSInteger)index;

@end

/**
 e.g
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.segmentView didBeginDraaWillBeginDragging:scrollView.contentOffset];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.segmentView didScrollViewDidScroll:scrollView];
}

- (void)didScrollSelectedIndex:(NSInteger)index {
    if (self.contentScrollView.contentOffsetX != index * self.contentScrollView.width)
        [self.contentScrollView scrollToHorizontalPageIndex:index animated:YES];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self.segmentView didScrollViewDidEndDecelerating:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self.segmentView didScrollViewDidEndDragging:scrollView willDecelerate:decelerate];
}
*/

@interface ZKSegmentControl : UIScrollView

@property (nonatomic, weak) id<ZKSegmentControlDelegate> kai_delegate;
/** 当前选中下标 **/
@property (nonatomic, assign) NSInteger currentIndex;
/** 默认显示颜色 **/
@property (nonatomic, strong) UIColor *titleColor;
/** 选中后默认显示颜色 **/
@property (nonatomic, strong) UIColor *titleSelectedColor;
/** 滑块颜色 **/
@property (nonatomic, strong) UIColor *sliderColor;
/** 底部线偏移 **/
@property(nonatomic, assign) NSInteger lineOffsetY;
/** 底部线高度 **/
@property (nonatomic, assign) CGFloat lineHeight;
/** 底部线宽度 **/
@property (nonatomic, assign) CGFloat lineWidth;
/** 是否显示滑块 **/
@property (nonatomic, assign) BOOL isSlider;
/** 是否铺满 **/
@property (nonatomic, assign) BOOL isFullof;
/** 是否显示虚线 **/
@property (nonatomic, assign) BOOL isLine;
/** 是否使用动画 **/
@property (nonatomic, assign) BOOL animation;

@property (nonatomic, assign) BOOL shadow;

@property (nonatomic, assign) BOOL isTitleLength;


- (void)setItems:(NSArray *)arr;


/** 开始滚动 **/
-(void)didBeginDraaWillBeginDragging:(CGPoint)offset;

/** 滚动过程 **/
- (void)didScrollViewDidScroll:(UIScrollView *)scrollView;

- (void)didScrollViewDidEndDecelerating:(UIScrollView *)scrollView;

- (void)didScrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;

@end

NS_ASSUME_NONNULL_END
