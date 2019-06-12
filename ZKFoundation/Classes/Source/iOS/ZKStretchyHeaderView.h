//
//  ZKStretchyHeaderView.h
//  Masonry
//
//  Created by Kaiser on 2019/6/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Specifies where the contentView will stick to the top or the bottom of the header view.
 *  This property is used when the scrollView bounces (scrollView.contentOffset < scrollView.contentInset.top)
 */
typedef NS_ENUM(NSUInteger, ZKStretchyHeaderViewContentAnchor) {
    /**
     *  The content view sticks to the top of the header view when it bounces
     */
    ZKStretchyHeaderViewContentAnchorTop = 0,
    /**
     *  The content view sticks to the bottom of the header view when it bounces
     */
    ZKStretchyHeaderViewContentAnchorBottom = 1
};

/**
 *  Specifies wether how the stretchy header view will be expanded
 */
typedef NS_ENUM(NSUInteger, ZKStretchyHeaderViewExpansionMode) {
    /**
     *  The header view will expand only at the top of the scroll view
     */
    ZKStretchyHeaderViewExpansionModeTopOnly = 0,
    /**
     *  The header view will expand as soon as the user scrolls down
     */
    ZKStretchyHeaderViewExpansionModeImmediate = 1
};

@interface ZKStretchyHeaderView : UIView

/**
 *  Specifies wether the header view will grow only when the top of the scroll view
 *  is visible, or as soon as the user scrolls down.
 */
#if TARGET_INTERFACE_BUILDER
@property(nonatomic) IBInspectable NSUInteger expansionMode;
#else
@property(nonatomic) ZKStretchyHeaderViewExpansionMode expansionMode;
#endif

/**
 *  The main view to which you add your custom content.
 */
@property(nonatomic, readonly) UIView *contentView;

/**
 *  The height of the header view when it's expanded. Default value is equal to the initial frame height, or 240 if unspecified.
 */
@property(nonatomic) IBInspectable CGFloat maximumContentHeight;

/**
 *  The minimum height of the header view. You usually want to set it to a value larger than 64 if you want to simulate a navigation bar. Defaults to 0.
 */
@property(nonatomic) IBInspectable CGFloat minimumContentHeight;

/**
 *  The contentInset for the contentView. Defaults to UIEdgeInsetsZero.
 */
@property(nonatomic) IBInspectable UIEdgeInsets contentInset;

/**
 *  Specifies wether the contentView sticks to the top or the bottom of the headerView.
 *  Default value is ZKStretchyHeaderContentViewAnchorTop.
 *  This has effect only if contentShrinks and/or contentExpands are set to NO.
 */
#if TARGET_INTERFACE_BUILDER
@property(nonatomic) IBInspectable NSUInteger contentAnchor;
#else
@property(nonatomic) ZKStretchyHeaderViewContentAnchor contentAnchor;
#endif

/**
 *  Indicates if the header view changes the scrollView insets automatically. You usually want to
 *  enable this property, unless you have a table view with sticky visible section headers.
 *  Have a look at this issue for more information: https://github.com/gskbyte/GSKStretchyHeaderView/issues/17
 *  Default value is YES.
 */
@property(nonatomic) BOOL manageScrollViewInsets;

/**
 * Indicates if the view hierarchy of the containing scroll view should be manipulated to fix some artifacts,
 * such as section header and supplementary views appearing on top of this header view.
 * This may involve moving views behind the header view, like UICollectionReusableView and UITableViewHeaderFooterView,
 * and adjusting `zPosition` for some views on iOS 11.
 *
 * - Please see UIScrollView+ZKHelper.m for more information.
 * - Have a look at this issue for more information: https://github.com/gskbyte/GSKStretchyHeaderView/issues/63
 * - OpenRadar issue: http://www.openradar.me/34308893
 *
 * Default value is YES
 */
@property(nonatomic) BOOL manageScrollViewSubviewHierarchy;

/**
 *  Specifies wether the contentView height shrinks when scrolling up. Default is YES.
 */
@property(nonatomic) IBInspectable BOOL contentShrinks;

/**
 *  Specifies wether the contentView height will be increased when scrolling down.
 *  Default is YES.
 */
@property(nonatomic) IBInspectable BOOL contentExpands;

/**
 *  Sets a new maximumContent height and scrolls to the top.
 */
- (void)setMaximumContentHeight:(CGFloat)maximumContentHeight
                  resetAnimated:(BOOL)animated;

@end


@protocol ZKStretchyHeaderViewStretchDelegate <NSObject>

/**
 *  Called when the stretchy header view's stretch factor changes
 *
 *  @param headerView    The header view this object is delegate of
 *  @param stretchFactor The new stretch factor for the given header view
 */
- (void)stretchyHeaderView:(ZKStretchyHeaderView *)headerView
    didChangeStretchFactor:(CGFloat)stretchFactor;

@end


@interface ZKStretchyHeaderView (StretchFactor)

/**
 *  The stretch factor is the relation between the current content height and the maximum (1) and minimum (0) contentHeight.
 *  Can be greater than 1 if contentViewBounces equals YES.
 */
@property (nonatomic, readonly) CGFloat stretchFactor;

/**
 *  The stretch delegate will be notified every time the stretchFactor changes.
 */
@property (nonatomic, weak) id<ZKStretchyHeaderViewStretchDelegate> stretchDelegate;

/**
 *  This method will be called every time the stretchFactor changes.
 *  Can be overriden by subclasses to adjust subviews depending on the value of the stretchFactor.
 *  @param stretchFactor The new stretchFactor
 */
- (void)didChangeStretchFactor:(CGFloat)stretchFactor;

@end


@interface ZKStretchyHeaderView (Layout)

/**
 *  This method will be called after the contentView performs -layoutSubviews. It can be useful to
 *  retrieve initial values for views added to the contentView. The default implementation does nothing.
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
