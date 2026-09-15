//
//  UIView+ZKBadge.m
//  ZKFoundation
//
//  Created by Kaiser on 2026/6/16.
//

#import "UIView+ZKBadge.h"
#import "ZKCategoriesImport.h"

static inline BOOL ZKBadgeIsLandscape(void) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication.statusBarOrientation);
#pragma clang diagnostic pop
}

@protocol _ZKBadgeLayoutProtocol <NSObject>
@required
@property (nonatomic, assign) CGPoint offset;
@property (nonatomic, assign) CGPoint offsetLandscape;
@end

@interface _ZKBadgeLabel : UILabel <_ZKBadgeLayoutProtocol>
@end

@interface _ZKUpdatesIndicatorView : UIView <_ZKBadgeLayoutProtocol>
@end

@interface UIView () <ZKBadgeProtocol>

@property (nonatomic, strong, readwrite) _ZKBadgeLabel *kai_badgeLabel;
@property (nonatomic, strong, readwrite) _ZKUpdatesIndicatorView *kai_updatesIndicatorView;
@property (nullable, nonatomic, strong) void (^kaibdg_layoutSubviewsBlock)(__kindof UIView *view);
@property (nonatomic, assign) BOOL kaibdg_hasAppliedDefaults;

@end

@implementation UIView (ZKBadge)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        OverrideImplementation([UIView class], @selector(setDidSubviewLayoutBlock:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIView *selfObject, void (^firstArgv)(__kindof UIView *aView)) {
                if (firstArgv && selfObject.kaibdg_layoutSubviewsBlock && firstArgv != selfObject.kaibdg_layoutSubviewsBlock) {
                    void (^userBlock)(__kindof UIView *) = [firstArgv copy];
                    firstArgv = ^(__kindof UIView *aaView) {
                        userBlock(aaView);
                        aaView.kaibdg_layoutSubviewsBlock(aaView);
                    };
                }

                void (*originSelectorIMP)(id, SEL, void (^)(__kindof UIView *));
                originSelectorIMP = (void (*)(id, SEL, void (^)(__kindof UIView *)))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, firstArgv);
            };
        });
    });
}

- (void)setKaibdg_layoutSubviewsBlock:(void (^)(__kindof UIView *))kaibdg_layoutSubviewsBlock {
    [self setAssociateValue:kaibdg_layoutSubviewsBlock withKey:@selector(kaibdg_layoutSubviewsBlock)];
}

- (void (^)(__kindof UIView *))kaibdg_layoutSubviewsBlock {
    return [self associatedValueForKey:_cmd];
}

- (void)setKaibdg_hasAppliedDefaults:(BOOL)kaibdg_hasAppliedDefaults {
    [self setAssociateValue:@(kaibdg_hasAppliedDefaults) withKey:@selector(kaibdg_hasAppliedDefaults)];
}

- (BOOL)kaibdg_hasAppliedDefaults {
    return [[self associatedValueForKey:_cmd] boolValue];
}

- (void)kaibdg_applyDefaultsIfNeeded {
    if (self.kaibdg_hasAppliedDefaults) {
        return;
    }
    self.kaibdg_hasAppliedDefaults = YES;

    // 仅在调用方未主动赋值时填入默认样式，避免把合法的 Zero 值误当成「未设置」。
    if (![self associatedValueForKey:@selector(kai_badgeBackgroundColor)]) {
        self.kai_badgeBackgroundColor = [UIColor redColor];
    }
    if (![self associatedValueForKey:@selector(kai_badgeTextColor)]) {
        self.kai_badgeTextColor = [UIColor whiteColor];
    }
    if (![self associatedValueForKey:@selector(kai_badgeFont)]) {
        self.kai_badgeFont = [UIFont boldSystemFontOfSize:11];
    }
    if (![self associatedValueForKey:@selector(kai_badgeContentEdgeInsets)]) {
        self.kai_badgeContentEdgeInsets = UIEdgeInsetsMake(2, 4, 2, 4);
    }
    if (![self associatedValueForKey:@selector(kai_badgeCornerRadius)]) {
        self.kai_badgeCornerRadius = -1;
    }
    if (![self associatedValueForKey:@selector(kai_badgeOffset)]) {
        self.kai_badgeOffset = CGPointMake(-9, 11);
    }
    if (![self associatedValueForKey:@selector(kai_badgeOffsetLandscape)]) {
        self.kai_badgeOffsetLandscape = CGPointMake(-9, 6);
    }

    if (![self associatedValueForKey:@selector(kai_updatesIndicatorColor)]) {
        self.kai_updatesIndicatorColor = [UIColor redColor];
    }
    if (![self associatedValueForKey:@selector(kai_updatesIndicatorSize)]) {
        self.kai_updatesIndicatorSize = CGSizeMake(7, 7);
    }
    if (![self associatedValueForKey:@selector(kai_updatesIndicatorOffset)]) {
        self.kai_updatesIndicatorOffset = CGPointMake(4, 7);
    }
    if (![self associatedValueForKey:@selector(kai_updatesIndicatorOffsetLandscape)]) {
        self.kai_updatesIndicatorOffsetLandscape = self.kai_updatesIndicatorOffset;
    }
}

#pragma mark - Badge

- (void)setKai_badgeInteger:(NSUInteger)kai_badgeInteger {
    [self setAssociateValue:@(kai_badgeInteger) withKey:@selector(kai_badgeInteger)];
    self.kai_badgeString = kai_badgeInteger > 0 ? [NSString stringWithFormat:@"%@", @(kai_badgeInteger)] : nil;
}

- (NSUInteger)kai_badgeInteger {
    return [[self associatedValueForKey:_cmd] unsignedIntegerValue];
}

- (void)setKai_badgeString:(NSString *)kai_badgeString {
    [self setAssociateValue:[kai_badgeString copy] withKey:@selector(kai_badgeString)];
    if (kai_badgeString.length) {
        [self kaibdg_applyDefaultsIfNeeded];
        if (!self.kai_badgeLabel) {
            self.kai_badgeLabel = [[_ZKBadgeLabel alloc] init];
            self.kai_badgeLabel.clipsToBounds = YES;
            self.kai_badgeLabel.textAlignment = NSTextAlignmentCenter;
            self.kai_badgeLabel.backgroundColor = self.kai_badgeBackgroundColor;
            self.kai_badgeLabel.textColor = self.kai_badgeTextColor;
            self.kai_badgeLabel.font = self.kai_badgeFont;
            self.kai_badgeLabel.textContainerInset = self.kai_badgeContentEdgeInsets;
            self.kai_badgeLabel.offset = self.kai_badgeOffset;
            self.kai_badgeLabel.offsetLandscape = self.kai_badgeOffsetLandscape;
            [self addSubview:self.kai_badgeLabel];
            [self kaibdg_updateLayoutSubviewsBlockIfNeeded];
        }
        self.kai_badgeLabel.text = kai_badgeString;
        self.kai_badgeLabel.hidden = NO;
        [self kaibdg_setNeedsUpdateBadgeLabelLayout];
        self.clipsToBounds = NO;
    } else {
        self.kai_badgeLabel.hidden = YES;
    }
}

- (NSString *)kai_badgeString {
    return [self associatedValueForKey:_cmd];
}

- (void)setKai_badgeBackgroundColor:(UIColor *)kai_badgeBackgroundColor {
    [self setAssociateValue:kai_badgeBackgroundColor withKey:@selector(kai_badgeBackgroundColor)];
    self.kai_badgeLabel.backgroundColor = kai_badgeBackgroundColor;
}

- (UIColor *)kai_badgeBackgroundColor {
    return [self associatedValueForKey:_cmd];
}

- (void)setKai_badgeTextColor:(UIColor *)kai_badgeTextColor {
    [self setAssociateValue:kai_badgeTextColor withKey:@selector(kai_badgeTextColor)];
    self.kai_badgeLabel.textColor = kai_badgeTextColor;
}

- (UIColor *)kai_badgeTextColor {
    return [self associatedValueForKey:_cmd];
}

- (void)setKai_badgeFont:(UIFont *)kai_badgeFont {
    [self setAssociateValue:kai_badgeFont withKey:@selector(kai_badgeFont)];
    if (self.kai_badgeLabel) {
        self.kai_badgeLabel.font = kai_badgeFont;
        [self kaibdg_setNeedsUpdateBadgeLabelLayout];
    }
}

- (UIFont *)kai_badgeFont {
    return [self associatedValueForKey:_cmd];
}

- (void)setKai_badgeContentEdgeInsets:(UIEdgeInsets)kai_badgeContentEdgeInsets {
    [self setAssociateValue:[NSValue valueWithUIEdgeInsets:kai_badgeContentEdgeInsets] withKey:@selector(kai_badgeContentEdgeInsets)];
    if (self.kai_badgeLabel) {
        self.kai_badgeLabel.textContainerInset = kai_badgeContentEdgeInsets;
        [self kaibdg_setNeedsUpdateBadgeLabelLayout];
    }
}

- (UIEdgeInsets)kai_badgeContentEdgeInsets {
    NSValue *value = [self associatedValueForKey:_cmd];
    return value ? value.UIEdgeInsetsValue : UIEdgeInsetsZero;
}

- (void)setKai_badgeCornerRadius:(CGFloat)kai_badgeCornerRadius {
    [self setAssociateValue:@(kai_badgeCornerRadius) withKey:@selector(kai_badgeCornerRadius)];
    if (self.kai_badgeLabel) {
        [self kaibdg_setNeedsUpdateBadgeLabelLayout];
    }
}

- (CGFloat)kai_badgeCornerRadius {
    NSNumber *number = [self associatedValueForKey:_cmd];
    return number ? number.doubleValue : -1;
}

- (void)setKai_badgeOffset:(CGPoint)kai_badgeOffset {
    [self setAssociateValue:[NSValue valueWithCGPoint:kai_badgeOffset] withKey:@selector(kai_badgeOffset)];
    self.kai_badgeLabel.offset = kai_badgeOffset;
}

- (CGPoint)kai_badgeOffset {
    NSValue *value = [self associatedValueForKey:_cmd];
    return value ? value.CGPointValue : CGPointZero;
}

- (void)setKai_badgeOffsetLandscape:(CGPoint)kai_badgeOffsetLandscape {
    [self setAssociateValue:[NSValue valueWithCGPoint:kai_badgeOffsetLandscape] withKey:@selector(kai_badgeOffsetLandscape)];
    self.kai_badgeLabel.offsetLandscape = kai_badgeOffsetLandscape;
}

- (CGPoint)kai_badgeOffsetLandscape {
    NSValue *value = [self associatedValueForKey:_cmd];
    return value ? value.CGPointValue : CGPointZero;
}

- (void)setKai_badgeLabel:(_ZKBadgeLabel *)kai_badgeLabel {
    [self setAssociateValue:kai_badgeLabel withKey:@selector(kai_badgeLabel)];
}

- (_ZKBadgeLabel *)kai_badgeLabel {
    return [self associatedValueForKey:_cmd];
}

- (void)kaibdg_setNeedsUpdateBadgeLabelLayout {
    if (self.kai_badgeString.length) {
        [self setNeedsLayout];
    }
}

#pragma mark - UpdatesIndicator

- (void)setKai_shouldShowUpdatesIndicator:(BOOL)kai_shouldShowUpdatesIndicator {
    [self setAssociateValue:@(kai_shouldShowUpdatesIndicator) withKey:@selector(kai_shouldShowUpdatesIndicator)];
    if (kai_shouldShowUpdatesIndicator) {
        [self kaibdg_applyDefaultsIfNeeded];
        if (!self.kai_updatesIndicatorView) {
            CGSize size = self.kai_updatesIndicatorSize;
            self.kai_updatesIndicatorView = [[_ZKUpdatesIndicatorView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
            self.kai_updatesIndicatorView.layer.cornerRadius = size.height / 2.0;
            self.kai_updatesIndicatorView.backgroundColor = self.kai_updatesIndicatorColor;
            self.kai_updatesIndicatorView.offset = self.kai_updatesIndicatorOffset;
            self.kai_updatesIndicatorView.offsetLandscape = self.kai_updatesIndicatorOffsetLandscape;
            [self addSubview:self.kai_updatesIndicatorView];
            [self kaibdg_updateLayoutSubviewsBlockIfNeeded];
        }
        [self kaibdg_setNeedsUpdateIndicatorLayout];
        self.clipsToBounds = NO;
        self.kai_updatesIndicatorView.hidden = NO;
    } else {
        self.kai_updatesIndicatorView.hidden = YES;
    }
}

- (BOOL)kai_shouldShowUpdatesIndicator {
    return [[self associatedValueForKey:_cmd] boolValue];
}

- (void)setKai_updatesIndicatorColor:(UIColor *)kai_updatesIndicatorColor {
    [self setAssociateValue:kai_updatesIndicatorColor withKey:@selector(kai_updatesIndicatorColor)];
    self.kai_updatesIndicatorView.backgroundColor = kai_updatesIndicatorColor;
}

- (UIColor *)kai_updatesIndicatorColor {
    return [self associatedValueForKey:_cmd];
}

- (void)setKai_updatesIndicatorSize:(CGSize)kai_updatesIndicatorSize {
    [self setAssociateValue:[NSValue valueWithCGSize:kai_updatesIndicatorSize] withKey:@selector(kai_updatesIndicatorSize)];
    if (self.kai_updatesIndicatorView) {
        self.kai_updatesIndicatorView.size = kai_updatesIndicatorSize;
        self.kai_updatesIndicatorView.layer.cornerRadius = kai_updatesIndicatorSize.height / 2.0;
        [self kaibdg_setNeedsUpdateIndicatorLayout];
    }
}

- (CGSize)kai_updatesIndicatorSize {
    NSValue *value = [self associatedValueForKey:_cmd];
    return value ? value.CGSizeValue : CGSizeZero;
}

- (void)setKai_updatesIndicatorOffset:(CGPoint)kai_updatesIndicatorOffset {
    [self setAssociateValue:[NSValue valueWithCGPoint:kai_updatesIndicatorOffset] withKey:@selector(kai_updatesIndicatorOffset)];
    if (self.kai_updatesIndicatorView) {
        self.kai_updatesIndicatorView.offset = kai_updatesIndicatorOffset;
        [self kaibdg_setNeedsUpdateIndicatorLayout];
    }
}

- (CGPoint)kai_updatesIndicatorOffset {
    NSValue *value = [self associatedValueForKey:_cmd];
    return value ? value.CGPointValue : CGPointZero;
}

- (void)setKai_updatesIndicatorOffsetLandscape:(CGPoint)kai_updatesIndicatorOffsetLandscape {
    [self setAssociateValue:[NSValue valueWithCGPoint:kai_updatesIndicatorOffsetLandscape] withKey:@selector(kai_updatesIndicatorOffsetLandscape)];
    if (self.kai_updatesIndicatorView) {
        self.kai_updatesIndicatorView.offsetLandscape = kai_updatesIndicatorOffsetLandscape;
        [self kaibdg_setNeedsUpdateIndicatorLayout];
    }
}

- (CGPoint)kai_updatesIndicatorOffsetLandscape {
    NSValue *value = [self associatedValueForKey:_cmd];
    return value ? value.CGPointValue : CGPointZero;
}

- (void)setKai_updatesIndicatorView:(_ZKUpdatesIndicatorView *)kai_updatesIndicatorView {
    [self setAssociateValue:kai_updatesIndicatorView withKey:@selector(kai_updatesIndicatorView)];
}

- (_ZKUpdatesIndicatorView *)kai_updatesIndicatorView {
    return [self associatedValueForKey:_cmd];
}

- (void)kaibdg_setNeedsUpdateIndicatorLayout {
    if (self.kai_shouldShowUpdatesIndicator) {
        [self setNeedsLayout];
    }
}

#pragma mark - Common

- (void)kaibdg_updateLayoutSubviewsBlockIfNeeded {
    if (!self.kaibdg_layoutSubviewsBlock) {
        self.kaibdg_layoutSubviewsBlock = ^(UIView *view) {
            [view kaibdg_layoutSubviews];
        };
    }
    if (!self.didSubviewLayoutBlock) {
        self.didSubviewLayoutBlock = self.kaibdg_layoutSubviewsBlock;
    } else if (self.didSubviewLayoutBlock != self.kaibdg_layoutSubviewsBlock) {
        void (^originalLayoutSubviewsBlock)(__kindof UIView *) = self.didSubviewLayoutBlock;
        self.kaibdg_layoutSubviewsBlock = ^(__kindof UIView *view) {
            originalLayoutSubviewsBlock(view);
            [view kaibdg_layoutSubviews];
        };
        self.didSubviewLayoutBlock = self.kaibdg_layoutSubviewsBlock;
    }
}

- (void)kaibdg_layoutSubviews {
    void (^layoutBlock)(UIView *view, UIView<_ZKBadgeLayoutProtocol> *badgeView) = ^(UIView *view, UIView<_ZKBadgeLayoutProtocol> *badgeView) {
        CGPoint offset = ZKBadgeIsLandscape() ? badgeView.offsetLandscape : badgeView.offset;
        badgeView.frame = CGRectSetXY(badgeView.frame,
                                      CGRectGetWidth(view.bounds) + offset.x,
                                      -CGRectGetHeight(badgeView.frame) + offset.y);
        [view bringSubviewToFront:badgeView];
    };

    if (self.kai_updatesIndicatorView && !self.kai_updatesIndicatorView.hidden) {
        layoutBlock(self, self.kai_updatesIndicatorView);
    }
    if (self.kai_badgeLabel && !self.kai_badgeLabel.hidden) {
        [self.kai_badgeLabel sizeToFit];
        if (self.kai_badgeCornerRadius >= 0) {
            self.kai_badgeLabel.layer.cornerRadius = self.kai_badgeCornerRadius;
        } else {
            self.kai_badgeLabel.layer.cornerRadius = MIN(self.kai_badgeLabel.height / 2.0, self.kai_badgeLabel.width / 2.0);
        }
        layoutBlock(self, self.kai_badgeLabel);
    }
}

@end

@implementation _ZKUpdatesIndicatorView

@synthesize offset = _offset, offsetLandscape = _offsetLandscape;

- (void)setOffset:(CGPoint)offset {
    _offset = offset;
    if (!ZKBadgeIsLandscape()) {
        [self.superview setNeedsLayout];
    }
}

- (void)setOffsetLandscape:(CGPoint)offsetLandscape {
    _offsetLandscape = offsetLandscape;
    if (ZKBadgeIsLandscape()) {
        [self.superview setNeedsLayout];
    }
}

@end

@implementation _ZKBadgeLabel

@synthesize offset = _offset, offsetLandscape = _offsetLandscape;

- (void)setOffset:(CGPoint)offset {
    _offset = offset;
    if (!ZKBadgeIsLandscape()) {
        [self.superview setNeedsLayout];
    }
}

- (void)setOffsetLandscape:(CGPoint)offsetLandscape {
    _offsetLandscape = offsetLandscape;
    if (ZKBadgeIsLandscape()) {
        [self.superview setNeedsLayout];
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize result = [super sizeThatFits:size];
    result = CGSizeMake(MAX(result.width, result.height), result.height);
    return result;
}

@end
