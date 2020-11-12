//
//  UIScrollView+ZKHelper.h
//  ZKFoundation
//
//  Created by Kaiser on 2019/6/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ZKStretchyHeaderView;
@class ZKScrollViewAdapter;

@interface UIScrollView (ZKHelper)

- (void)kai_fixZPositionsForStretchyHeaderView:(ZKStretchyHeaderView *)headerView;

- (void)kai_arrangeStretchyHeaderView:(ZKStretchyHeaderView *)headerView;
- (void)kai_layoutStretchyHeaderView:(ZKStretchyHeaderView *)headerView
                       contentOffset:(CGPoint)contentOffset
               previousContentOffset:(CGPoint)previousContentOffset;

@end

@interface UIScrollView (ZKAdapter)

@property (nonatomic, strong, readonly) ZKScrollViewAdapter *adapter;

@end

NS_ASSUME_NONNULL_END
