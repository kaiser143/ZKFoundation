//
//  ZKFloatLayoutView.m
//  ZKFoundation
//
//  Created by zhangkai on 2025/7/14.
//

#import "ZKFloatLayoutView.h"
#import <ZKCategories/ZKCategories.h>

#define ValueSwitchAlignLeftOrRight(alignRight, valueLeft, valueRight) ((alignRight) ? (valueRight) : (valueLeft))

const CGSize ZKUIFloatLayoutViewAutomaticalMaximumItemSize = {-1, -1};

@implementation ZKFloatLayoutView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.contentMode = UIViewContentModeLeft;
    self.minimumItemSize = CGSizeZero;
    self.maximumItemSize = ZKUIFloatLayoutViewAutomaticalMaximumItemSize;
}

#pragma mark - Auto Layout

- (CGSize)intrinsicContentSize {
    CGFloat layoutWidth = self.bounds.size.width;
    if (layoutWidth > 0) {
        CGSize fitSize = [self layoutSubviewsWithSize:CGSizeMake(layoutWidth, CGFLOAT_MAX) shouldLayout:NO];
        return CGSizeMake(UIViewNoIntrinsicMetric, fitSize.height);
    }
    
    CGSize fitSize = [self layoutSubviewsWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) shouldLayout:NO];
    return CGSizeMake(fitSize.width, fitSize.height);
}

- (CGSize)systemLayoutSizeFittingSize:(CGSize)targetSize
        withHorizontalFittingPriority:(UILayoutPriority)horizontalFittingPriority
              verticalFittingPriority:(UILayoutPriority)verticalFittingPriority {
    CGFloat layoutWidth = targetSize.width;
    if (layoutWidth <= 0) {
        layoutWidth = self.bounds.size.width;
    }
    if (layoutWidth <= 0 && horizontalFittingPriority < UILayoutPriorityRequired) {
        layoutWidth = CGFLOAT_MAX;
    }
    return [self layoutSubviewsWithSize:CGSizeMake(layoutWidth, CGFLOAT_MAX) shouldLayout:NO];
}

- (void)didAddSubview:(UIView *)subview {
    [super didAddSubview:subview];
    [self invalidateIntrinsicContentSize];
}

- (void)willRemoveSubview:(UIView *)subview {
    [super willRemoveSubview:subview];
    [self invalidateIntrinsicContentSize];
}

#pragma mark - Property Setters

- (void)setPadding:(UIEdgeInsets)padding {
    if (UIEdgeInsetsEqualToEdgeInsets(_padding, padding)) {
        return;
    }
    _padding = padding;
    [self invalidateIntrinsicContentSize];
    [self setNeedsLayout];
}

- (void)setMinimumItemSize:(CGSize)minimumItemSize {
    if (CGSizeEqualToSize(_minimumItemSize, minimumItemSize)) {
        return;
    }
    _minimumItemSize = minimumItemSize;
    [self invalidateIntrinsicContentSize];
    [self setNeedsLayout];
}

- (void)setMaximumItemSize:(CGSize)maximumItemSize {
    if (CGSizeEqualToSize(_maximumItemSize, maximumItemSize)) {
        return;
    }
    _maximumItemSize = maximumItemSize;
    [self invalidateIntrinsicContentSize];
    [self setNeedsLayout];
}

- (void)setItemMargins:(UIEdgeInsets)itemMargins {
    if (UIEdgeInsetsEqualToEdgeInsets(_itemMargins, itemMargins)) {
        return;
    }
    _itemMargins = itemMargins;
    [self invalidateIntrinsicContentSize];
    [self setNeedsLayout];
}

- (void)setContentMode:(UIViewContentMode)contentMode {
    if (self.contentMode == contentMode) {
        return;
    }
    [super setContentMode:contentMode];
    [self invalidateIntrinsicContentSize];
    [self setNeedsLayout];
}

#pragma mark - Layout

- (CGSize)sizeThatFits:(CGSize)size {
    return [self layoutSubviewsWithSize:size shouldLayout:NO];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self layoutSubviewsWithSize:self.bounds.size shouldLayout:YES];
}

- (CGSize)layoutSubviewsWithSize:(CGSize)size shouldLayout:(BOOL)shouldLayout {
    NSArray<UIView *> *visibleItemViews = [self visibleSubviews];
    
    if (visibleItemViews.count == 0) {
        return CGSizeMake(UIEdgeInsetsGetHorizontalValue(self.padding), UIEdgeInsetsGetVerticalValue(self.padding));
    }
    
    BOOL hasFixedWidth = isfinite(size.width) && size.width < CGFLOAT_MAX / 2;
    BOOL alignRight = [self shouldAlignRight] && hasFixedWidth;
    
    // 如果是左对齐，则代表 item 左上角的坐标，如果是右对齐，则代表 item 右上角的坐标
    CGPoint itemViewOrigin = CGPointMake(ValueSwitchAlignLeftOrRight(alignRight, self.padding.left, size.width - self.padding.right), self.padding.top);
    CGFloat currentRowMaxY = itemViewOrigin.y;
    CGFloat contentMaxWidth = UIEdgeInsetsGetHorizontalValue(self.padding);
    CGSize maximumItemSize = CGSizeEqualToSize(self.maximumItemSize, ZKUIFloatLayoutViewAutomaticalMaximumItemSize) ? CGSizeMake(size.width - UIEdgeInsetsGetHorizontalValue(self.padding), size.height - UIEdgeInsetsGetVerticalValue(self.padding)) : self.maximumItemSize;
    NSInteger line = -1;
    for (NSInteger i = 0, l = visibleItemViews.count; i < l; i++) {
        UIView *itemView = visibleItemViews[i];
        
        CGRect itemViewFrame;
        CGSize itemViewSize = [self itemViewSizeForView:itemView fittingMaximumSize:maximumItemSize];
        itemViewSize.width = MIN(maximumItemSize.width, MAX(self.minimumItemSize.width, itemViewSize.width));
        itemViewSize.height = MIN(maximumItemSize.height, MAX(self.minimumItemSize.height, itemViewSize.height));
        
        BOOL shouldBreakline = i == 0 ? YES : ValueSwitchAlignLeftOrRight(alignRight, itemViewOrigin.x + self.itemMargins.left + itemViewSize.width + self.padding.right > size.width,
                                                           itemViewOrigin.x - self.itemMargins.right - itemViewSize.width - self.padding.left < 0);
        if (shouldBreakline) {
            line++;
            currentRowMaxY += line > 0 ? self.itemMargins.top : 0;
            // 换行，每一行第一个 item 是不考虑 itemMargins 的
            itemViewFrame = CGRectMake(ValueSwitchAlignLeftOrRight(alignRight, self.padding.left, size.width - self.padding.right - itemViewSize.width), currentRowMaxY, itemViewSize.width, itemViewSize.height);
            itemViewOrigin.y = CGRectGetMinY(itemViewFrame);
        } else {
            // 当前行放得下
            itemViewFrame = CGRectMake(ValueSwitchAlignLeftOrRight(alignRight, itemViewOrigin.x + self.itemMargins.left, itemViewOrigin.x - self.itemMargins.right - itemViewSize.width), itemViewOrigin.y, itemViewSize.width, itemViewSize.height);
        }
        itemViewOrigin.x = ValueSwitchAlignLeftOrRight(alignRight, CGRectGetMaxX(itemViewFrame) + self.itemMargins.right, CGRectGetMinX(itemViewFrame) - self.itemMargins.left);
        currentRowMaxY = MAX(currentRowMaxY, CGRectGetMaxY(itemViewFrame) + self.itemMargins.bottom);
        contentMaxWidth = MAX(contentMaxWidth, CGRectGetMaxX(itemViewFrame) + self.padding.right);
        
        if (shouldLayout) {
            if (!itemView.translatesAutoresizingMaskIntoConstraints) {
                itemView.translatesAutoresizingMaskIntoConstraints = YES;
            }
            itemView.frame = itemViewFrame;
            [itemView layoutIfNeeded];
        }
    }
    
    // 最后一行不需要考虑 itemMarins.bottom，所以这里减掉
    currentRowMaxY -= self.itemMargins.bottom;
    
    CGFloat resultWidth = hasFixedWidth ? size.width : contentMaxWidth;
    CGSize resultSize = CGSizeMake(resultWidth, currentRowMaxY + self.padding.bottom);
    return resultSize;
}

- (CGSize)itemViewSizeForView:(UIView *)itemView fittingMaximumSize:(CGSize)maximumItemSize {
    CGSize fittingSize = maximumItemSize;
    if (!isfinite(fittingSize.width) || fittingSize.width <= 0) {
        fittingSize.width = UILayoutFittingCompressedSize.width;
    }
    if (!isfinite(fittingSize.height) || fittingSize.height <= 0) {
        fittingSize.height = UILayoutFittingCompressedSize.height;
    }
    
    CGSize itemViewSize = [itemView systemLayoutSizeFittingSize:fittingSize
                                  withHorizontalFittingPriority:UILayoutPriorityFittingSizeLevel
                                        verticalFittingPriority:UILayoutPriorityFittingSizeLevel];
    if (itemViewSize.width <= 0 || itemViewSize.height <= 0) {
        itemViewSize = [itemView sizeThatFits:maximumItemSize];
    }
    return itemViewSize;
}

- (NSArray<UIView *> *)visibleSubviews {
    NSMutableArray<UIView *> *visibleItemViews = [[NSMutableArray alloc] init];
    
    for (NSInteger i = 0, l = self.subviews.count; i < l; i++) {
        UIView *itemView = self.subviews[i];
        if (!itemView.hidden) {
            [visibleItemViews addObject:itemView];
        }
    }
    
    return visibleItemViews;
}

- (BOOL)shouldAlignRight {
    return self.contentMode == UIViewContentModeRight;
}


@end
