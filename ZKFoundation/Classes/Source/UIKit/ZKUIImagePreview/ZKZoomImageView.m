//
//  ZKZoomImageView.m
//  ZKFoundation
//
//  Created by zhangkai on 2026/3/19.
//

#import "ZKZoomImageView.h"

@interface ZKZoomImageView () <UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;
@end

@implementation ZKZoomImageView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _maximumZoomScale = 2.0;
        _loadingColor = [UIColor whiteColor];
        self.contentMode = UIViewContentModeCenter;
        self.backgroundColor = [UIColor clearColor];
        
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.minimumZoomScale = 0;
        _scrollView.maximumZoomScale = _maximumZoomScale;
        _scrollView.delegate = self;
        _scrollView.scrollEnabled = NO;
        _scrollView.alwaysBounceVertical = NO;
        _scrollView.alwaysBounceHorizontal = NO;
        if (@available(iOS 11.0, *)) {
            _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [self addSubview:_scrollView];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        singleTap.numberOfTapsRequired = 1;
        singleTap.delegate = self;
        [self addGestureRecognizer:singleTap];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTap];
        [singleTap requireGestureRecognizerToFail:doubleTap];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        [self addGestureRecognizer:longPress];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (CGRectIsEmpty(self.bounds)) {
        return;
    }
    BOOL sizeChanged = !CGSizeEqualToSize(self.scrollView.bounds.size, self.bounds.size);
    self.scrollView.frame = self.bounds;
    self.loadingView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    if (sizeChanged && self.image) {
        [self revertZooming];
    }
}

- (void)setFrame:(CGRect)frame {
    BOOL sizeChanged = !CGSizeEqualToSize(frame.size, self.frame.size);
    [super setFrame:frame];
    if (sizeChanged) {
        [self revertZooming];
    }
}

#pragma mark - Image

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeCenter;
        [self.scrollView addSubview:_imageView];
    }
    return _imageView;
}

- (void)setImage:(UIImage *)image {
    _image = image;
    if (!image) {
        _imageView.image = nil;
        [_imageView removeFromSuperview];
        _imageView = nil;
        return;
    }
    
    [self hideEmptyView];
    self.imageView.image = image;
    self.imageView.transform = CGAffineTransformIdentity;
    self.imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    self.imageView.hidden = NO;
    [self revertZooming];
}

- (UIView *)contentView {
    return _imageView;
}

- (CGRect)contentViewRectInZoomImageView {
    if (!_imageView) {
        return CGRectZero;
    }
    [self layoutIfNeeded];
    return [_imageView convertRect:_imageView.bounds toView:self];
}

- (void)prepareForTransition {
    self.transform = CGAffineTransformIdentity;
    if (_imageView) {
        _imageView.transform = CGAffineTransformIdentity;
    }
    [self revertZooming];
    [self layoutIfNeeded];
}

#pragma mark - Zoom

- (void)setMaximumZoomScale:(CGFloat)maximumZoomScale {
    _maximumZoomScale = maximumZoomScale;
    self.scrollView.maximumZoomScale = maximumZoomScale;
}

- (CGRect)finalViewportRect {
    if (!CGRectIsEmpty(self.bounds)) {
        if (!CGSizeEqualToSize(self.scrollView.bounds.size, self.bounds.size)) {
            [self setNeedsLayout];
            [self layoutIfNeeded];
        }
        return self.bounds;
    }
    return CGRectZero;
}

- (CGFloat)minimumZoomScale {
    if (!self.image) {
        return 1.0;
    }
    CGSize mediaSize = self.image.size;
    if (mediaSize.width <= 0 || mediaSize.height <= 0) {
        return 1.0;
    }
    CGRect viewport = [self finalViewportRect];
    if (CGRectIsEmpty(viewport)) {
        return 1.0;
    }
    CGFloat scaleX = CGRectGetWidth(viewport) / mediaSize.width;
    CGFloat scaleY = CGRectGetHeight(viewport) / mediaSize.height;
    
    if (self.contentMode == UIViewContentModeScaleAspectFit) {
        return MIN(scaleX, scaleY);
    }
    if (self.contentMode == UIViewContentModeScaleAspectFill) {
        return MAX(scaleX, scaleY);
    }
    if (scaleX >= 1 && scaleY >= 1) {
        return 1.0;
    }
    return MIN(scaleX, scaleY);
}

- (BOOL)enabledZoomImageView {
    if ([self.delegate respondsToSelector:@selector(enabledZoomViewInZoomImageView:)]) {
        return [self.delegate enabledZoomViewInZoomImageView:self];
    }
    return self.image != nil;
}

- (void)updateScrollInteractionEnabled {
    BOOL enabled = [self enabledZoomImageView];
    BOOL zoomedIn = self.scrollView.zoomScale > self.scrollView.minimumZoomScale + 0.01;
    self.scrollView.pinchGestureRecognizer.enabled = enabled;
    self.scrollView.panGestureRecognizer.enabled = enabled && zoomedIn;
    self.scrollView.scrollEnabled = enabled && zoomedIn;
}

- (void)revertZooming {
    if (CGRectIsEmpty(self.bounds)) {
        return;
    }
    self.transform = CGAffineTransformIdentity;
    
    BOOL enabled = [self enabledZoomImageView];
    CGFloat minimumZoomScale = [self minimumZoomScale];
    CGFloat maximumZoomScale = enabled ? self.maximumZoomScale : minimumZoomScale;
    maximumZoomScale = MAX(minimumZoomScale, maximumZoomScale);
    
    self.scrollView.minimumZoomScale = minimumZoomScale;
    self.scrollView.maximumZoomScale = maximumZoomScale;
    
    if (_imageView && self.image) {
        _imageView.transform = CGAffineTransformIdentity;
        _imageView.frame = CGRectMake(0, 0, self.image.size.width, self.image.size.height);
    }
    
    BOOL shouldFireManual = fabs(self.scrollView.zoomScale - minimumZoomScale) < CGFLOAT_EPSILON;
    self.scrollView.zoomScale = minimumZoomScale;
    if (shouldFireManual) {
        [self handleDidEndZooming];
    }
    [self updateScrollInteractionEnabled];
    
    CGRect viewport = [self finalViewportRect];
    if (!CGRectIsEmpty(viewport)) {
        UIView *contentView = self.contentView;
        CGFloat x = self.scrollView.contentOffset.x;
        CGFloat y = self.scrollView.contentOffset.y;
        if (contentView && CGRectGetWidth(viewport) < CGRectGetWidth(contentView.frame)) {
            x = (CGRectGetWidth(contentView.frame) / 2.0 - CGRectGetWidth(viewport) / 2.0) - CGRectGetMinX(viewport);
        }
        if (contentView && CGRectGetHeight(viewport) < CGRectGetHeight(contentView.frame)) {
            y = (CGRectGetHeight(contentView.frame) / 2.0 - CGRectGetHeight(viewport) / 2.0) - CGRectGetMinY(viewport);
        }
        self.scrollView.contentOffset = CGPointMake(x, y);
    }
}

- (void)handleDidEndZooming {
    CGRect viewport = [self finalViewportRect];
    if (CGRectIsEmpty(viewport)) {
        return;
    }
    
    UIView *contentView = self.contentView;
    if (!contentView) {
        return;
    }
    
    [self layoutIfNeeded];
    CGRect contentViewFrame = [self convertRect:contentView.frame fromView:contentView.superview];
    UIEdgeInsets contentInset = UIEdgeInsetsZero;
    
    contentInset.top = CGRectGetMinY(viewport);
    contentInset.left = CGRectGetMinX(viewport);
    contentInset.right = CGRectGetWidth(self.bounds) - CGRectGetMaxX(viewport);
    contentInset.bottom = CGRectGetHeight(self.bounds) - CGRectGetMaxY(viewport);
    
    if (CGRectGetHeight(viewport) > CGRectGetHeight(contentViewFrame)) {
        contentInset.top = floor(CGRectGetMidY(viewport) - CGRectGetHeight(contentViewFrame) / 2.0);
        contentInset.bottom = floor(CGRectGetHeight(self.bounds) - CGRectGetMidY(viewport) - CGRectGetHeight(contentViewFrame) / 2.0);
    }
    if (CGRectGetWidth(viewport) > CGRectGetWidth(contentViewFrame)) {
        contentInset.left = floor(CGRectGetMidX(viewport) - CGRectGetWidth(contentViewFrame) / 2.0);
        contentInset.right = floor(CGRectGetWidth(self.bounds) - CGRectGetMidX(viewport) - CGRectGetWidth(contentViewFrame) / 2.0);
    }
    
    self.scrollView.contentInset = contentInset;
    self.scrollView.contentSize = contentView.frame.size;
}

#pragma mark - Loading

- (UIActivityIndicatorView *)loadingView {
    if (!_loadingView) {
        UIActivityIndicatorViewStyle style = UIActivityIndicatorViewStyleGray;
        _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style];
        _loadingView.color = self.loadingColor;
        _loadingView.hidesWhenStopped = YES;
        [self addSubview:_loadingView];
    }
    return _loadingView;
}

- (void)setLoadingColor:(UIColor *)loadingColor {
    _loadingColor = loadingColor ?: [UIColor whiteColor];
    _loadingView.color = _loadingColor;
}

- (void)showLoading {
    [self.loadingView startAnimating];
    self.loadingView.hidden = NO;
    [self bringSubviewToFront:self.loadingView];
    [self setNeedsLayout];
}

- (void)hideEmptyView {
    [_loadingView stopAnimating];
    _loadingView.hidden = YES;
}

#pragma mark - Gestures

- (void)handleSingleTap:(UITapGestureRecognizer *)gesture {
    CGPoint location = [gesture locationInView:self];
    if ([self.delegate respondsToSelector:@selector(singleTouchInZoomingImageView:location:)]) {
        [self.delegate singleTouchInZoomingImageView:self location:location];
    }
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)gesture {
    CGPoint location = [gesture locationInView:self];
    if ([self.delegate respondsToSelector:@selector(doubleTouchInZoomingImageView:location:)]) {
        [self.delegate doubleTouchInZoomingImageView:self location:location];
    }
    
    if (![self enabledZoomImageView]) {
        return;
    }
    
    if (self.scrollView.zoomScale >= self.scrollView.maximumZoomScale - 0.01) {
        [UIView animateWithDuration:0.25 animations:^{
            self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
        }];
        return;
    }
    
    CGFloat newZoomScale = self.scrollView.zoomScale < 1 ? 1 : self.scrollView.maximumZoomScale;
    CGPoint tapPoint = [self.contentView convertPoint:location fromView:self];
    CGRect zoomRect = CGRectMake(0, 0, CGRectGetWidth(self.bounds) / newZoomScale, CGRectGetHeight(self.bounds) / newZoomScale);
    zoomRect.origin.x = tapPoint.x - CGRectGetWidth(zoomRect) / 2.0;
    zoomRect.origin.y = tapPoint.y - CGRectGetHeight(zoomRect) / 2.0;
    [UIView animateWithDuration:0.25 animations:^{
        [self.scrollView zoomToRect:zoomRect animated:NO];
    }];
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state != UIGestureRecognizerStateBegan) {
        return;
    }
    if ([self enabledZoomImageView] && [self.delegate respondsToSelector:@selector(longPressInZoomingImageView:)]) {
        [self.delegate longPressInZoomingImageView:self];
    }
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.contentView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self handleDidEndZooming];
    [self updateScrollInteractionEnabled];
}

@end
