//
//  ZKUIImagePreviewViewController.m
//  ZKFoundation
//
//  Created by zhangkai on 2026/3/19.
//

#import "ZKUIImagePreviewViewController.h"
#import "ZKUIImagePreviewViewTransitionAnimator.h"

const CGFloat ZKUIImagePreviewViewControllerCornerRadiusAutomaticDimension = -1;

@interface ZKUIImagePreviewViewController ()
@property (nonatomic, strong, readwrite) ZKUIImagePreviewView *imagePreviewView;
@property (nonatomic, strong) UIPanGestureRecognizer *dismissingGesture;
@property (nonatomic, assign) CGPoint gestureBeganLocation;
@property (nonatomic, weak) ZKZoomImageView *gestureZoomImageView;
@property (nonatomic, assign) BOOL originalStatusBarHidden;
@property (nonatomic, assign) BOOL statusBarHidden;
@property (nonatomic, assign) BOOL appeared;
@end

@implementation ZKUIImagePreviewViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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
    _backgroundColor = [UIColor blackColor];
    _sourceImageCornerRadius = ZKUIImagePreviewViewControllerCornerRadiusAutomaticDimension;
    _dismissingGestureEnabled = YES;
    _presentingStyle = ZKUIImagePreviewViewControllerTransitioningStyleFade;
    _dismissingStyle = ZKUIImagePreviewViewControllerTransitioningStyleFade;
    
    self.transitioningAnimator = [[ZKUIImagePreviewViewTransitionAnimator alloc] init];
    self.modalPresentationStyle = UIModalPresentationCustom;
    self.modalPresentationCapturesStatusBarAppearance = YES;
    self.transitioningDelegate = self;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    _backgroundColor = backgroundColor;
    if (self.isViewLoaded) {
        self.view.backgroundColor = backgroundColor;
    }
}

- (ZKUIImagePreviewView *)imagePreviewView {
    if (!_imagePreviewView) {
        _imagePreviewView = [[ZKUIImagePreviewView alloc] initWithFrame:self.isViewLoaded ? self.view.bounds : CGRectZero];
    }
    return _imagePreviewView;
}

- (void)loadView {
    [super loadView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = self.backgroundColor;
    [self.view addSubview:self.imagePreviewView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.imagePreviewView.frame = self.view.bounds;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.presentingViewController) {
        [self initObjectsForZoomStyleIfNeeded];
    }
    [self.imagePreviewView.collectionView reloadData];
    [self.imagePreviewView.collectionView layoutIfNeeded];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.appeared = YES;
    if (self.presentingViewController) {
        self.statusBarHidden = YES;
        ZKZoomImageView *zoomImageView = [self.imagePreviewView zoomImageViewAtIndex:self.imagePreviewView.currentImageIndex];
        [zoomImageView prepareForTransition];
    }
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.statusBarHidden = self.originalStatusBarHidden;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.appeared = NO;
    [self removeObjectsForZoomStyle];
    [self resetDismissingGesture];
}

- (void)setPresentingStyle:(ZKUIImagePreviewViewControllerTransitioningStyle)presentingStyle {
    _presentingStyle = presentingStyle;
    _dismissingStyle = presentingStyle;
}

- (void)setTransitioningAnimator:(__kindof ZKUIImagePreviewViewTransitionAnimator *)transitioningAnimator {
    _transitioningAnimator = transitioningAnimator;
    transitioningAnimator.imagePreviewViewController = self;
}

- (BOOL)prefersStatusBarHidden {
    if (!self.appeared) {
        if (self.presentingViewController) {
            BOOL hidden = NO;
            if (@available(iOS 13.0, *)) {
                hidden = self.presentingViewController.view.window.windowScene.statusBarManager.statusBarHidden;
            } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                hidden = UIApplication.sharedApplication.isStatusBarHidden;
#pragma clang diagnostic pop
            }
            self.originalStatusBarHidden = hidden;
            return self.originalStatusBarHidden;
        }
        return [super prefersStatusBarHidden];
    }
    return self.statusBarHidden;
}

- (BOOL)prefersHomeIndicatorAutoHidden {
    return YES;
}

#pragma mark - Dismiss Gesture

- (void)initObjectsForZoomStyleIfNeeded {
    if (!self.dismissingGesture && self.dismissingGestureEnabled) {
        self.dismissingGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleDismissingPreviewGesture:)];
        [self.view addGestureRecognizer:self.dismissingGesture];
    }
}

- (void)removeObjectsForZoomStyle {
    [self.dismissingGesture removeTarget:self action:@selector(handleDismissingPreviewGesture:)];
    [self.view removeGestureRecognizer:self.dismissingGesture];
    self.dismissingGesture = nil;
}

- (void)handleDismissingPreviewGesture:(UIPanGestureRecognizer *)gesture {
    if (!self.dismissingGestureEnabled) {
        return;
    }
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            self.gestureBeganLocation = [gesture locationInView:self.view];
            self.gestureZoomImageView = [self.imagePreviewView zoomImageViewAtIndex:self.imagePreviewView.currentImageIndex];
            self.gestureZoomImageView.scrollView.clipsToBounds = NO;
            break;
            
        case UIGestureRecognizerStateChanged: {
            CGPoint location = [gesture locationInView:self.view];
            CGFloat horizontalDistance = location.x - self.gestureBeganLocation.x;
            CGFloat verticalDistance = location.y - self.gestureBeganLocation.y;
            CGFloat ratio = 1.0;
            CGFloat alpha = 1.0;
            
            if (verticalDistance > 0) {
                ratio = 1.0 - verticalDistance / CGRectGetHeight(self.view.bounds) / 2.0;
                alpha = 1.0 - verticalDistance / CGRectGetHeight(self.view.bounds) * 1.8;
            } else {
                CGFloat a = self.gestureBeganLocation.y + 100;
                CGFloat b = 1 - pow((a - fabs(verticalDistance)) / a, 2);
                CGFloat contentViewHeight = CGRectGetHeight([self.gestureZoomImageView contentViewRectInZoomImageView]);
                CGFloat c = (CGRectGetHeight(self.view.bounds) - contentViewHeight) / 2.0;
                verticalDistance = -c * b;
            }
            
            CGAffineTransform transform = CGAffineTransformMakeTranslation(horizontalDistance, verticalDistance);
            transform = CGAffineTransformScale(transform, ratio, ratio);
            self.gestureZoomImageView.transform = transform;
            self.view.backgroundColor = [self.backgroundColor colorWithAlphaComponent:MAX(alpha, 0)];
            
            BOOL statusBarHidden = alpha >= 1 ? YES : self.originalStatusBarHidden;
            if (statusBarHidden != self.statusBarHidden) {
                self.statusBarHidden = statusBarHidden;
                [self setNeedsStatusBarAppearanceUpdate];
            }
        }
            break;
            
        case UIGestureRecognizerStateEnded: {
            CGPoint location = [gesture locationInView:self.view];
            CGFloat verticalDistance = location.y - self.gestureBeganLocation.y;
            if (verticalDistance > CGRectGetHeight(self.view.bounds) / 6.0) {
                [self dismissViewControllerAnimated:YES completion:nil];
            } else {
                [self cancelDismissingGesture];
            }
        }
            break;
            
        default:
            [self cancelDismissingGesture];
            break;
    }
}

- (void)cancelDismissingGesture {
    self.statusBarHidden = YES;
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self setNeedsStatusBarAppearanceUpdate];
        [self resetDismissingGesture];
    } completion:nil];
}

- (void)resetDismissingGesture {
    self.gestureZoomImageView.transform = CGAffineTransformIdentity;
    self.gestureZoomImageView.scrollView.clipsToBounds = YES;
    self.gestureBeganLocation = CGPointZero;
    self.gestureZoomImageView = nil;
    self.view.backgroundColor = self.backgroundColor;
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return self.transitioningAnimator;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self.transitioningAnimator;
}

@end
