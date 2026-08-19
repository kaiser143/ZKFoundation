//
//  ZKUIImagePreviewView.m
//  ZKFoundation
//
//  Created by zhangkai on 2026/3/19.
//

#import "ZKUIImagePreviewView.h"

static NSString * const kZKPreviewImageCellIdentifier = @"imageorunknown";
static NSString * const kZKPreviewLivePhotoCellIdentifier = @"livephoto";
static NSString * const kZKPreviewVideoCellIdentifier = @"video";

@interface ZKUIImagePreviewCell : UICollectionViewCell
@property (nonatomic, strong) ZKZoomImageView *zoomImageView;
@end

@implementation ZKUIImagePreviewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _zoomImageView = [[ZKZoomImageView alloc] init];
        [self.contentView addSubview:_zoomImageView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.zoomImageView.frame = self.contentView.bounds;
}

@end

@interface ZKUIImagePreviewView () <ZKZoomImageViewDelegate>
@property (nonatomic, assign) BOOL isChangingCollectionViewBounds;
@property (nonatomic, assign) CGFloat previousIndexWhenScrolling;
@end

@implementation ZKUIImagePreviewView

@synthesize currentImageIndex = _currentImageIndex;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    _collectionViewLayout = [[ZKCollectionViewPagingLayout alloc] init];
    _collectionViewLayout.allowsMultipleItemScroll = NO;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:_collectionViewLayout];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.scrollsToTop = NO;
    _collectionView.delaysContentTouches = NO;
    _collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    _collectionView.pagingEnabled = NO;
    if (@available(iOS 11.0, *)) {
        _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [_collectionView registerClass:[ZKUIImagePreviewCell class] forCellWithReuseIdentifier:kZKPreviewImageCellIdentifier];
    [_collectionView registerClass:[ZKUIImagePreviewCell class] forCellWithReuseIdentifier:kZKPreviewLivePhotoCellIdentifier];
    [_collectionView registerClass:[ZKUIImagePreviewCell class] forCellWithReuseIdentifier:kZKPreviewVideoCellIdentifier];
    [self addSubview:_collectionView];
    
    _loadingColor = [UIColor whiteColor];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    BOOL sizeChanged = !CGSizeEqualToSize(self.collectionView.bounds.size, self.bounds.size);
    if (!sizeChanged) {
        return;
    }
    
    self.isChangingCollectionViewBounds = YES;
    [self.collectionViewLayout invalidateLayout];
    self.collectionView.frame = self.bounds;
    if ([self.collectionView numberOfItemsInSection:0] > 0 && self.currentImageIndex < [self.collectionView numberOfItemsInSection:0]) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentImageIndex inSection:0]
                                    atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                            animated:NO];
    }
    self.isChangingCollectionViewBounds = NO;
}

- (void)setCurrentImageIndex:(NSUInteger)currentImageIndex {
    [self setCurrentImageIndex:currentImageIndex animated:NO];
}

- (void)setCurrentImageIndex:(NSUInteger)currentImageIndex animated:(BOOL)animated {
    _currentImageIndex = currentImageIndex;
    [self.collectionView reloadData];
    if (currentImageIndex < [self.collectionView numberOfItemsInSection:0]) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:currentImageIndex inSection:0]
                                    atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                            animated:animated];
        [self.collectionView layoutIfNeeded];
    }
}

- (void)setLoadingColor:(UIColor *)loadingColor {
    BOOL changed = _loadingColor && ![_loadingColor isEqual:loadingColor];
    _loadingColor = loadingColor ?: [UIColor whiteColor];
    if (changed) {
        [self.collectionView reloadItemsAtIndexPaths:self.collectionView.indexPathsForVisibleItems];
    }
}

#pragma mark - Lookup

- (NSInteger)indexForZoomImageView:(ZKZoomImageView *)zoomImageView {
    UIView *cellView = zoomImageView.superview.superview;
    if (![cellView isKindOfClass:[ZKUIImagePreviewCell class]]) {
        return NSNotFound;
    }
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:(ZKUIImagePreviewCell *)cellView];
    return indexPath ? indexPath.item : NSNotFound;
}

- (ZKZoomImageView *)zoomImageViewAtIndex:(NSUInteger)index {
    ZKUIImagePreviewCell *cell = (ZKUIImagePreviewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    return cell.zoomImageView;
}

#pragma mark - UICollectionViewDataSource / Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(numberOfImagesInImagePreviewView:)]) {
        return [self.delegate numberOfImagesInImagePreviewView:self];
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = kZKPreviewImageCellIdentifier;
    if ([self.delegate respondsToSelector:@selector(imagePreviewView:assetTypeAtIndex:)]) {
        ZKUIImagePreviewMediaType type = [self.delegate imagePreviewView:self assetTypeAtIndex:indexPath.item];
        if (type == ZKUIImagePreviewMediaTypeLivePhoto) {
            identifier = kZKPreviewLivePhotoCellIdentifier;
        } else if (type == ZKUIImagePreviewMediaTypeVideo) {
            identifier = kZKPreviewVideoCellIdentifier;
        }
    }
    
    ZKUIImagePreviewCell *cell = (ZKUIImagePreviewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    ZKZoomImageView *zoomView = cell.zoomImageView;
    zoomView.loadingColor = self.loadingColor;
    zoomView.delegate = self;
    zoomView.image = nil;
    
    if ([self.delegate respondsToSelector:@selector(imagePreviewView:renderZoomImageView:atIndex:)]) {
        [self.delegate imagePreviewView:self renderZoomImageView:zoomView atIndex:indexPath.item];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    ZKUIImagePreviewCell *previewCell = (ZKUIImagePreviewCell *)cell;
    [previewCell.zoomImageView revertZooming];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return collectionView.bounds.size;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView != self.collectionView) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(imagePreviewView:didScrollToIndex:)]) {
        [self.delegate imagePreviewView:self didScrollToIndex:self.currentImageIndex];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView != self.collectionView || self.isChangingCollectionViewBounds) {
        return;
    }
    
    CGFloat pageWidth = CGRectGetWidth(self.collectionView.bounds);
    if (pageWidth <= 0) {
        return;
    }
    CGFloat pageHorizontalMargin = self.collectionViewLayout.minimumLineSpacing;
    CGFloat index = self.collectionView.contentOffset.x / (pageWidth + pageHorizontalMargin);
    
    BOOL isFirstDidScroll = self.previousIndexWhenScrolling == 0;
    BOOL fastToRight = (floor(index) - floor(self.previousIndexWhenScrolling) >= 1.0) && (floor(index) - self.previousIndexWhenScrolling > 0.5);
    BOOL turnPageToRight = fastToRight || (self.previousIndexWhenScrolling <= floor(index) + 0.5 && floor(index) + 0.5 <= index);
    BOOL fastToLeft = (floor(self.previousIndexWhenScrolling) - floor(index) >= 1.0) && (self.previousIndexWhenScrolling - ceil(index) > 0.5);
    BOOL turnPageToLeft = fastToLeft || (index <= floor(index) + 0.5 && floor(index) + 0.5 <= self.previousIndexWhenScrolling);
    
    if (!isFirstDidScroll && (turnPageToRight || turnPageToLeft)) {
        NSInteger rounded = (NSInteger)round(index);
        NSInteger count = [self.collectionView numberOfItemsInSection:0];
        if (rounded >= 0 && rounded < count) {
            _currentImageIndex = (NSUInteger)rounded;
            if ([self.delegate respondsToSelector:@selector(imagePreviewView:willScrollHalfToIndex:)]) {
                [self.delegate imagePreviewView:self willScrollHalfToIndex:(NSUInteger)rounded];
            }
        }
    }
    self.previousIndexWhenScrolling = index;
}

#pragma mark - ZKZoomImageViewDelegate

- (void)singleTouchInZoomingImageView:(ZKZoomImageView *)imageView location:(CGPoint)location {
    if ([self.delegate respondsToSelector:@selector(singleTouchInZoomingImageView:location:)]) {
        [self.delegate singleTouchInZoomingImageView:imageView location:location];
    }
}

- (void)doubleTouchInZoomingImageView:(ZKZoomImageView *)imageView location:(CGPoint)location {
    if ([self.delegate respondsToSelector:@selector(doubleTouchInZoomingImageView:location:)]) {
        [self.delegate doubleTouchInZoomingImageView:imageView location:location];
    }
}

- (void)longPressInZoomingImageView:(ZKZoomImageView *)imageView {
    if ([self.delegate respondsToSelector:@selector(longPressInZoomingImageView:)]) {
        [self.delegate longPressInZoomingImageView:imageView];
    }
}

- (BOOL)enabledZoomViewInZoomImageView:(ZKZoomImageView *)imageView {
    if ([self.delegate respondsToSelector:@selector(enabledZoomViewInZoomImageView:)]) {
        return [self.delegate enabledZoomViewInZoomImageView:imageView];
    }
    return YES;
}

@end
