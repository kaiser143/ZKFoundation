//
//  ZKStretchyHeaderView.h
//  ZKFoundation
//
//  Created by Kaiser on 2019/6/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  指定 contentView 固定在头部视图的顶部还是底部。
 *  该属性在 scrollView 回弹时使用（scrollView.contentOffset < scrollView.contentInset.top）。
 */
typedef NS_ENUM(NSUInteger, ZKStretchyHeaderViewContentAnchor) {
    /**
     *  回弹时内容视图固定在头部视图顶部
     */
    ZKStretchyHeaderViewContentAnchorTop = 0,
    /**
     *  回弹时内容视图固定在头部视图底部
     */
    ZKStretchyHeaderViewContentAnchorBottom = 1
};

/**
 *  指定可拉伸头部视图的展开方式
 */
typedef NS_ENUM(NSUInteger, ZKStretchyHeaderViewExpansionMode) {
    /**
     *  头部视图仅在滚动到顶部时展开
     */
    ZKStretchyHeaderViewExpansionModeTopOnly = 0,
    /**
     *  用户向下滚动时头部视图立即展开
     */
    ZKStretchyHeaderViewExpansionModeImmediate = 1
};

@interface ZKStretchyHeaderView : UIView

/**
 *  指定头部视图仅在滚动视图顶部可见时展开，还是在用户向下滚动时立即展开。
 */
#if TARGET_INTERFACE_BUILDER
@property(nonatomic) IBInspectable NSUInteger expansionMode;
#else
@property(nonatomic) ZKStretchyHeaderViewExpansionMode expansionMode;
#endif

/**
 *  用于添加自定义内容的主视图。
 */
@property(nonatomic, readonly) UIView *contentView;

/**
 *  头部视图展开时的高度。默认值为初始 frame 高度，未指定时为 240。
 */
@property(nonatomic) IBInspectable CGFloat maximumContentHeight;

/**
 *  头部视图的最小高度。若要模拟导航栏，通常可设为大于 64 的值。默认为 0。
 */
@property(nonatomic) IBInspectable CGFloat minimumContentHeight;

/**
 *  contentView 的 contentInset。默认为 UIEdgeInsetsZero。
 */
@property(nonatomic) IBInspectable UIEdgeInsets contentInset;

/**
 *  指定 contentView 固定在 headerView 的顶部还是底部。
 *  默认值为 ZKStretchyHeaderContentViewAnchorTop。
 *  仅当 contentShrinks 和/或 contentExpands 设为 NO 时生效。
 */
#if TARGET_INTERFACE_BUILDER
@property(nonatomic) IBInspectable NSUInteger contentAnchor;
#else
@property(nonatomic) ZKStretchyHeaderViewContentAnchor contentAnchor;
#endif

/**
 *  是否由头部视图自动修改 scrollView 的 insets。通常建议开启，除非使用带吸顶 section header 的 tableView。
 *  详见：https://github.com/gskbyte/GSKStretchyHeaderView/issues/17
 *  默认值为 YES。
 */
@property(nonatomic) BOOL manageScrollViewInsets;

/**
 *  是否调整包含的 scrollView 的视图层级以修复一些显示问题，
 *  例如 section header 和 supplementary 视图出现在本头部视图上方。
 *  可能包括将 UICollectionReusableView、UITableViewHeaderFooterView 等视图移到头部视图后面，
 *  以及在 iOS 11 上调整部分视图的 `zPosition`。
 *
 * - 更多说明见 UIScrollView+ZKHelper.m。
 * - 详见：https://github.com/gskbyte/GSKStretchyHeaderView/issues/63
 * - OpenRadar：http://www.openradar.me/34308893
 *
 * 默认值为 YES。
 */
@property(nonatomic) BOOL manageScrollViewSubviewHierarchy;

/**
 *  指定向上滚动时 contentView 高度是否缩小。默认为 YES。
 */
@property(nonatomic) IBInspectable BOOL contentShrinks;

/**
 *  指定向下滚动时 contentView 高度是否增加。默认为 YES。
 */
@property(nonatomic) IBInspectable BOOL contentExpands;

/**
 *  设置新的 maximumContent 高度并滚动到顶部。
 */
- (void)setMaximumContentHeight:(CGFloat)maximumContentHeight
                  resetAnimated:(BOOL)animated;

@end


@protocol ZKStretchyHeaderViewStretchDelegate <NSObject>

/**
 *  当可拉伸头部视图的拉伸系数发生变化时调用
 *
 *  @param headerView    作为代理的头部视图
 *  @param stretchFactor 该头部视图新的拉伸系数
 */
- (void)stretchyHeaderView:(ZKStretchyHeaderView *)headerView
    didChangeStretchFactor:(CGFloat)stretchFactor;

@end


@interface ZKStretchyHeaderView (StretchFactor)

/**
 *  拉伸系数为当前内容高度与最大(1)、最小(0) contentHeight 的比值。
 *  当 contentViewBounces 为 YES 时可能大于 1。
 */
@property (nonatomic, readonly) CGFloat stretchFactor;

/**
 *  每次 stretchFactor 变化时会通知该拉伸代理。
 */
@property (nonatomic, weak) id<ZKStretchyHeaderViewStretchDelegate> stretchDelegate;

/**
 *  每次 stretchFactor 变化时调用。
 *  子类可重写以根据 stretchFactor 调整子视图。
 *  @param stretchFactor 新的 stretchFactor
 */
- (void)didChangeStretchFactor:(CGFloat)stretchFactor;

@end


@interface ZKStretchyHeaderView (Layout)

/**
 *  在 contentView 执行 -layoutSubviews 之后调用。可用于获取添加到 contentView 的视图的初始值。
 *  默认实现为空。
 */
- (void)contentViewDidLayoutSubviews;

@end


@interface ZKStretchyHeaderView (Protected)

@property (nonatomic, readonly) CGFloat verticalInset;
@property (nonatomic, readonly) CGFloat horizontalInset;
@property (nonatomic, readonly) CGFloat maximumHeight;
@property (nonatomic, readonly) CGFloat minimumHeight;

- (void)setNeedsLayoutContentView;
- (void)layoutContentViewIfNeeded;

@end


NS_ASSUME_NONNULL_END
