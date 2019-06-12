//
//  UIScrollView+ZKHelper.h
//  Masonry
//
//  Created by Kaiser on 2019/6/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ZKStretchyHeaderView;

@interface UIScrollView (ZKHelper)

- (void)kai_fixZPositionsForStretchyHeaderView:(ZKStretchyHeaderView *)headerView;

- (void)kai_arrangeStretchyHeaderView:(ZKStretchyHeaderView *)headerView;
- (void)kai_layoutStretchyHeaderView:(ZKStretchyHeaderView *)headerView
                       contentOffset:(CGPoint)contentOffset
               previousContentOffset:(CGPoint)previousContentOffset;

@end

NS_ASSUME_NONNULL_END
