//
//  ZKMarqueeLabel.m
//  ZKFoundation
//
//  跑马灯 UILabel 实现；依赖 ZKCategories（几何工具、 NSObject 安全调用与关联对象）。
//

#import "ZKMarqueeLabel.h"
#import <ZKCategories/ZKCategories.h>

@interface ZKMarqueeLabel ()

@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) CGFloat offsetX;
@property (nonatomic, assign) CGSize textSize;
@property (nonatomic, assign) CGFloat fadeStartPercent;
@property (nonatomic, assign) CGFloat fadeEndPercent;

@property (nonatomic, assign) BOOL isFirstDisplay;

@property (nonatomic, strong) CAGradientLayer *fadeLayer;

/// 自定义绘制时横向重复绘制次数；1 不衔接，大于 1 首尾衔接。
@property (nonatomic, assign) NSInteger textRepeatCount;

@property (nonatomic, assign) CGRect prevBounds;

@end

@implementation ZKMarqueeLabel

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.lineBreakMode = NSLineBreakByClipping;
        self.clipsToBounds = YES;
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
    self.speed = .5;
    self.fadeStartPercent = 0;
    self.fadeEndPercent = .2;
    self.pauseDurationWhenMoveToEdge = 2.5;
    self.spacingBetweenHeadToTail = 40;
    self.automaticallyValidateVisibleFrame = YES;
    self.shouldFadeAtEdge = YES;
    self.textStartAfterFade = NO;

    self.isFirstDisplay = YES;
    self.textRepeatCount = 2;
}

- (void)dealloc {
    [self.displayLink invalidate];
    self.displayLink = nil;
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    if (self.window) {
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(handleDisplayLink:)];
        [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    } else {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }

    self.attributedText = self.attributedText;
}

- (void)setFadeWidthPercent:(CGFloat)fadeWidthPercent {
    if (fadeWidthPercent < 0.0 || fadeWidthPercent > 1.0) {
        return;
    }
    _fadeWidthPercent = fadeWidthPercent;

    self.fadeEndPercent = fadeWidthPercent;
}

- (void)setText:(NSString *)text {
    [super setText:text];
    self.offsetX = 0;
    self.textSize = [self sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
    self.displayLink.paused = ![self shouldPlayDisplayLink];
    [self checkIfShouldShowGradientLayer];
    [self setNeedsLayout];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    [super setAttributedText:attributedText];
    self.offsetX = 0;
    self.textSize = [self sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
    self.displayLink.paused = ![self shouldPlayDisplayLink];
    [self checkIfShouldShowGradientLayer];
    [self setNeedsLayout];
}

- (void)drawTextInRect:(CGRect)rect {
    CGFloat textInitialX = 0;
    if (self.textAlignment == NSTextAlignmentLeft) {
        textInitialX = 0;
    } else if (self.textAlignment == NSTextAlignmentCenter) {
        textInitialX = MAX(0, CGFloatGetCenter(CGRectGetWidth(self.bounds), self.textSize.width));
    } else if (self.textAlignment == NSTextAlignmentRight) {
        textInitialX = MAX(0, CGRectGetWidth(self.bounds) - self.textSize.width);
    }

    CGFloat textOffsetXByFade = 0;
    BOOL shouldTextStartAfterFade = self.shouldFadeAtEdge && self.textStartAfterFade && self.textSize.width > CGRectGetWidth(self.bounds);
    CGFloat fadeWidth = CGRectGetWidth(self.bounds) * .5 * MAX(0, self.fadeEndPercent - self.fadeStartPercent);
    if (shouldTextStartAfterFade && textInitialX < fadeWidth) {
        textOffsetXByFade = fadeWidth;
    }
    textInitialX += textOffsetXByFade;

    for (NSInteger i = 0; i < self.textRepeatCountConsiderTextWidth; i++) {
        CGRect drawRect = CGRectMake(
            self.offsetX + (self.textSize.width + self.spacingBetweenHeadToTail) * i + textInitialX,
            CGRectGetMinY(rect) + CGFloatGetCenter(CGRectGetHeight(rect), self.textSize.height),
            self.textSize.width,
            self.textSize.height);
        [self.attributedText drawInRect:drawRect];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];

    if (self.fadeLayer) {
        self.fadeLayer.frame = self.bounds;
    }

    if (!CGSizeEqualToSize(self.prevBounds.size, self.bounds.size)) {
        self.offsetX = 0;
        self.displayLink.paused = ![self shouldPlayDisplayLink];
        self.prevBounds = self.bounds;

        [self checkIfShouldShowGradientLayer];
    }
}

- (NSInteger)textRepeatCountConsiderTextWidth {
    if (self.textSize.width < CGRectGetWidth(self.bounds)) {
        return 1;
    }
    return self.textRepeatCount;
}

- (void)handleDisplayLink:(CADisplayLink *)displayLink {
    if (self.offsetX == 0) {
        displayLink.paused = YES;
        [self setNeedsDisplay];

        int64_t delay = (self.isFirstDisplay || self.textRepeatCount <= 1) ? self.pauseDurationWhenMoveToEdge : 0;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            displayLink.paused = ![self shouldPlayDisplayLink];
            if (!displayLink.paused) {
                self.offsetX -= self.speed;
            }
        });

        if (delay > 0 && self.textRepeatCount > 1) {
            self.isFirstDisplay = NO;
        }

        return;
    }

    self.offsetX -= self.speed;
    [self setNeedsDisplay];

    if (-self.offsetX >= self.textSize.width + (self.textRepeatCountConsiderTextWidth > 1 ? self.spacingBetweenHeadToTail : 0)) {
        displayLink.paused = YES;
        int64_t delay = self.textRepeatCount > 1 ? self.pauseDurationWhenMoveToEdge : 0;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.offsetX = 0;
            [self handleDisplayLink:displayLink];
        });
    }
}

- (BOOL)shouldPlayDisplayLink {
    BOOL result = self.window && CGRectGetWidth(self.bounds) > 0 && self.textSize.width > CGRectGetWidth(self.bounds);

    if (result && self.automaticallyValidateVisibleFrame) {
        CGRect rectInWindow = [self.window convertRect:self.frame fromView:self.superview];
        if (!CGRectIntersectsRect(self.window.bounds, rectInWindow)) {
            return NO;
        }
    }

    return result;
}

- (void)setShouldFadeAtEdge:(BOOL)shouldFadeAtEdge {
    _shouldFadeAtEdge = shouldFadeAtEdge;

    [self checkIfShouldShowGradientLayer];
    [self setNeedsLayout];
}

- (void)checkIfShouldShowGradientLayer {
    BOOL shouldShowFadeLayer = self.window && self.shouldFadeAtEdge && CGRectGetWidth(self.bounds) > 0 && self.textSize.width > CGRectGetWidth(self.bounds);

    if (shouldShowFadeLayer) {
        _fadeLayer = [CAGradientLayer layer];
        self.fadeLayer.locations = @[@(self.fadeStartPercent), @(self.fadeEndPercent), @(1 - self.fadeEndPercent), @(1 - self.fadeStartPercent)];
        self.fadeLayer.startPoint = CGPointMake(0, .5);
        self.fadeLayer.endPoint = CGPointMake(1, .5);
        UIColor *opaqueWhite = [UIColor colorWithWhite:1 alpha:1];
        UIColor *transparentWhite = [UIColor colorWithWhite:1 alpha:0];
        self.fadeLayer.colors = @[
            (id)transparentWhite.CGColor,
            (id)opaqueWhite.CGColor,
            (id)opaqueWhite.CGColor,
            (id)transparentWhite.CGColor
        ];
        self.layer.mask = self.fadeLayer;
        [self setNeedsLayout];
    } else {
        if (self.layer.mask == self.fadeLayer) {
            self.layer.mask = nil;
        }
    }
}

#pragma mark - Superclass

- (void)setNumberOfLines:(NSInteger)numberOfLines {
    numberOfLines = 1;
    [super setNumberOfLines:numberOfLines];
}

@end

@implementation ZKMarqueeLabel (ReusableView)

- (BOOL)requestToStartAnimation {
    self.automaticallyValidateVisibleFrame = NO;
    BOOL shouldPlay = [self shouldPlayDisplayLink];
    if (shouldPlay) {
        self.displayLink.paused = NO;
    }
    return shouldPlay;
}

- (BOOL)requestToStopAnimation {
    self.displayLink.paused = YES;
    return YES;
}

@end

static char kZKNativeMarqueeWasRunningKey;

@implementation UILabel (ZKMarquee)

- (void)kai_startNativeMarquee {
    BOOL running = YES;
    self.numberOfLines = 1;
    self.clipsToBounds = YES;
    [self safePerform:NSSelectorFromString(@"setMarqueeEnabled:") withArguments:&running, nil];
    [self safePerform:NSSelectorFromString(@"setMarqueeRunning:") withArguments:&running, nil];
    [self zk_mq_removeObservers];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(__kai_handleApplicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(__kai_handleApplicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)kai_stopNativeMarquee {
    BOOL running = NO;
    [self safePerform:NSSelectorFromString(@"setMarqueeRunning:") withArguments:&running, nil];
    [self safePerform:NSSelectorFromString(@"setMarqueeEnabled:") withArguments:&running, nil];
    [self zk_mq_removeObservers];
}

- (BOOL)kai_nativeMarqueeRunning {
    BOOL running = NO;
    [self safePerform:NSSelectorFromString(@"marqueeRunning") withPrimitiveReturnValue:&running arguments:nil];
    return running;
}

- (void)__kai_handleApplicationDidEnterBackground:(NSNotification *)notification {
    [self setAssociateValue:@(self.kai_nativeMarqueeRunning) withKey:&kZKNativeMarqueeWasRunningKey];
}

- (void)__kai_handleApplicationDidBecomeActive:(NSNotification *)notification {
    NSNumber *wasRunning = [self associatedValueForKey:&kZKNativeMarqueeWasRunningKey];
    if (wasRunning.boolValue) {
        [self kai_stopNativeMarquee];
        [self kai_startNativeMarquee];
    }
}

- (void)zk_mq_removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

@end
