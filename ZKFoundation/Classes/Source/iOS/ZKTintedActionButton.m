//
//  ZKTintedActionButton.m
//  ZKFoundation
//
//  Created by Kaiser on 2019/4/3.
//

#import "ZKTintedActionButton.h"

// Objective-C direct methods - https://nshipster.com/direct/
#define ZKTintedActionButton_OBJC_DIRECT __attribute__((objc_direct))

// --------------------------------------------------------------------

static inline BOOL TO_ROUNDED_BUTTON_FLOAT_IS_ZERO(CGFloat value) {
    return (value > -FLT_EPSILON) && (value < FLT_EPSILON);
}

static inline BOOL TO_ROUNDED_BUTTON_FLOATS_MATCH(CGFloat firstValue, CGFloat secondValue) {
    return fabs(firstValue - secondValue) > FLT_EPSILON;
}

// --------------------------------------------------------------------

@implementation ZKTintedActionButton {
    /** Hold on to a global state for whether we are tapped
     or not because the state can change before blocks complete. */
    BOOL _isTapped;
    
    /** A hosting container holding all of the view content that tap animations are applied to. */
    UIView *_containerView;
    
    /** If `text` is set, the internally managed title label to show it. */
    UILabel *_titleLabel;
    
    /** A background view that displays the rounded box behind the button text. */
    UIView *_backgroundView;
}

#pragma mark - View Creation -

- (instancetype)init {
    if (self = [self initWithFrame:(CGRect){0,0, 288.0f, 50.0f}]) { }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _contentView = [UIView new];
        [self _roundedButtonCommonInit];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _contentView = [UIView new];
        [self _roundedButtonCommonInit];
    }
    
    return self;
}

- (instancetype)initWithContentView:(__kindof UIView *)contentView {
    if (self = [super initWithFrame:contentView.bounds]) {
        _contentView = contentView;
        [self _roundedButtonCommonInit];
    }
    return self;
}

- (instancetype)initWithText:(NSString *)text {
    if (self = [super initWithFrame:(CGRect){0,0, 288.0f, 50.0f}]) {
        _contentView = [UIView new];
        [self _roundedButtonCommonInit];
        [self _makeTitleLabelIfNeeded];
        _titleLabel.text = text;
        [_titleLabel sizeToFit];
    }
    
    return self;
}

- (void)_roundedButtonCommonInit ZKTintedActionButton_OBJC_DIRECT {
    // Default properties (Make sure they're not overriding IB)
    _cornerRadius = (_cornerRadius > FLT_EPSILON) ?: 12.0f;
    _tappedTextAlpha = (_tappedTextAlpha > FLT_EPSILON) ?: 1.0f;
    _tapAnimationDuration = (_tapAnimationDuration > FLT_EPSILON) ?: 0.4f;
    _tappedButtonScale = (_tappedButtonScale > FLT_EPSILON) ?: 0.97f;
    _tappedTintColorBrightnessOffset = !TO_ROUNDED_BUTTON_FLOAT_IS_ZERO(_tappedTintColorBrightnessOffset) ?: -0.15f;
    _contentInset = (UIEdgeInsets){15.0, 15.0, 15.0, 15.0};
    _blurStyle = UIBlurEffectStyleDark;
#ifdef __IPHONE_13_0
    if (@available(iOS 13.0, *)) { _blurStyle = UIBlurEffectStyleSystemThinMaterialDark; }
#endif
    
    // Set the tapped tint color if we've set to dynamically calculate it
    [self _updateTappedTintColorForTintColor];
    
    // Create the container view that holds all of the views for animations.
    _containerView = [[UIView alloc] initWithFrame:self.bounds];
    _containerView.backgroundColor = [UIColor clearColor];
    _containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _containerView.userInteractionEnabled = NO;
    _containerView.clipsToBounds = YES;
    [self addSubview:_containerView];
    
    // Create the image view which will show the button background
    _backgroundView = [self _makeBackgroundViewWithBlur:_isTranslucent];
    [_containerView addSubview:_backgroundView];
    
    // The foreground content view
    [_containerView addSubview:_contentView];
    
    // Create action events for all possible interactions with this control
    [self addTarget:self action:@selector(_didTouchDownInside) forControlEvents:UIControlEventTouchDown|UIControlEventTouchDownRepeat];
    [self addTarget:self action:@selector(_didTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    [self addTarget:self action:@selector(_didDragOutside) forControlEvents:UIControlEventTouchDragExit|UIControlEventTouchCancel];
    [self addTarget:self action:@selector(_didDragInside) forControlEvents:UIControlEventTouchDragEnter];
}

- (void)_makeTitleLabelIfNeeded ZKTintedActionButton_OBJC_DIRECT {
    if (_titleLabel) { return; }
    
    // Make the font bold, and opt it into Dynamic Type sizing
    UIFontMetrics *const metrics = [[UIFontMetrics alloc] initForTextStyle:UIFontTextStyleBody];
    UIFont *const buttonFont = [metrics scaledFontForFont:[UIFont systemFontOfSize:17.0f weight:UIFontWeightBold]];
    
    // Configure the title label
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.font = buttonFont;
    _titleLabel.adjustsFontForContentSizeCategory = YES;
    _titleLabel.backgroundColor = [self _labelBackgroundColor];
    _titleLabel.text = @"Button";
    _titleLabel.numberOfLines = 0;
    [_contentView addSubview:_titleLabel];
}

- (UIView *)_makeBackgroundViewWithBlur:(BOOL)withBlur ZKTintedActionButton_OBJC_DIRECT {
    UIView *backgroundView = nil;
    if (withBlur) {
        UIBlurEffect *const blurEffect = [UIBlurEffect effectWithStyle:_blurStyle];
        backgroundView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        backgroundView.clipsToBounds = YES;
    } else {
        backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        backgroundView.backgroundColor = self.tintColor;
    }
    backgroundView.frame = self.bounds;
    backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    backgroundView.layer.cornerRadius = _cornerRadius;
#ifdef __IPHONE_13_0
    if (@available(iOS 13.0, *)) { backgroundView.layer.cornerCurve = kCACornerCurveContinuous; }
#endif
    return backgroundView;
}

#pragma mark - View Layout -

- (void)layoutSubviews {
    [super layoutSubviews];
    
    const CGSize boundsSize = self.bounds.size;
    _contentView.frame = (CGRect){
        .origin.x = _contentInset.left,
        .origin.y = _contentInset.top,
        .size.width = boundsSize.width - (_contentInset.left + _contentInset.right),
        .size.height = boundsSize.height - (_contentInset.top + _contentInset.bottom),
    };
    
    // Configure the button text
    if (_titleLabel) {
        [_titleLabel sizeToFit];
        _titleLabel.center = (CGPoint){
            .x = CGRectGetMidX(_contentView.bounds),
            .y = CGRectGetMidY(_contentView.bounds)
        };
        _titleLabel.frame = CGRectIntegral(_titleLabel.frame);
    }
}

- (void)sizeToFit { [super sizeToFit]; }

- (CGSize)sizeThatFits:(CGSize)size {
    const CGFloat horizontalPadding = (_contentInset.left + _contentInset.right);
    const CGFloat verticalPadding = (_contentInset.top + _contentInset.bottom);
    const CGSize contentSize = CGSizeMake(size.width - horizontalPadding, size.height - verticalPadding);
    CGSize newSize = CGSizeZero;
    
    // Check to see if the content view was overridden with custom class that implements its own sizing method.
    const BOOL isMethodOverridden = [_contentView methodForSelector:@selector(sizeThatFits:)] !=
    [UIView instanceMethodForSelector:@selector(sizeThatFits:)];
    if (isMethodOverridden) {
        newSize = [_contentView sizeThatFits:size];
    } else if (_contentView.subviews.count == 1) {
        // When there is 1 view, we can reliably scale the whole view around it.
        newSize = [_contentView.subviews.firstObject sizeThatFits:contentSize];
    } else if (_contentView.subviews.count > 1) {
        // For multiple subviews, work out the bounds of all of the views and scale the button to fit
        for (UIView *view in _contentView.subviews) {
            newSize.width = MAX(CGRectGetMaxX(view.frame), newSize.width);
            newSize.height = MAX(CGRectGetMaxY(view.frame), newSize.height);
        }
    }
    
    newSize.width += horizontalPadding;
    newSize.height += verticalPadding;
    return newSize;
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    if (_isTranslucent) { return; }
    _titleLabel.backgroundColor = [self _labelBackgroundColor];
    _backgroundView.backgroundColor = self.tintColor;
    [self setNeedsLayout];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    [self setNeedsLayout];
    [self _updateTappedTintColorForTintColor];
}

- (CGSize)intrinsicContentSize {
    CGSize contentSize = CGSizeZero;
    
    // Calculate the size of the contentView if it has subviews
    if (_contentView.subviews.count > 0) {
        for (UIView *subview in _contentView.subviews) {
            CGSize subviewSize = [subview systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
            contentSize.width = MAX(contentSize.width, subviewSize.width);
            contentSize.height = MAX(contentSize.height, subviewSize.height);
        }
    }
    
    // Add the insets to the content size
    contentSize.width += (_contentInset.left + _contentInset.right);
    contentSize.height += (_contentInset.top + _contentInset.bottom);
    
    // Ensure the button has a minimum size
    contentSize.width = MAX(contentSize.width, 44.0);
    contentSize.height = MAX(contentSize.height, 44.0);
    
    return contentSize;
}

- (void)_updateTappedTintColorForTintColor ZKTintedActionButton_OBJC_DIRECT {
    if (TO_ROUNDED_BUTTON_FLOAT_IS_ZERO(_tappedTintColorBrightnessOffset)) {
        return;
    }
    
    UIColor *tintColor = self.tintColor;
    if (@available(iOS 13.0, *)) {
        tintColor = [tintColor resolvedColorWithTraitCollection:self.traitCollection];
    }
    
    _tappedTintColor = [self _brightnessAdjustedColorWithColor:tintColor
                                                        amount:_tappedTintColorBrightnessOffset];
}

- (UIColor *)_labelBackgroundColor ZKTintedActionButton_OBJC_DIRECT {
    // Always return clear if tapped
    if (_isTapped || _isTranslucent) { return [UIColor clearColor]; }
    
    // Return clear if the tint color isn't opaque
    BOOL isClear = CGColorGetAlpha(self.tintColor.CGColor) < (1.0f - FLT_EPSILON);
    return isClear ? [UIColor clearColor] : self.tintColor;
}

#pragma mark - Interaction -

- (void)_didTouchDownInside {
    _isTapped = YES;
    
    // The user touched their finger down into the button bounds
    [self _setLabelAlphaTappedAnimated:NO];
    [self _setBackgroundColorTappedAnimated:YES];
    [self _setButtonScaledTappedAnimated:YES];
}

- (void)_didTouchUpInside {
    _isTapped = NO;
    
    // The user lifted their finger up from inside the button bounds
    [self _setLabelAlphaTappedAnimated:YES];
    [self _setBackgroundColorTappedAnimated:YES];
    [self _setButtonScaledTappedAnimated:YES];
    
    // Send the semantic button action for apps relying on this action
    [self sendActionsForControlEvents:UIControlEventPrimaryActionTriggered];
    
    // Broadcast the tap event to all subscribed objects.
    if (_tappedHandler) { _tappedHandler(); }
    [_delegate tintedActionButtonDidTap:self];
}

- (void)_didDragOutside {
    _isTapped = NO;
    
    // After tapping down, without releasing, the user dragged their finger outside the bounds
    [self _setLabelAlphaTappedAnimated:YES];
    [self _setBackgroundColorTappedAnimated:YES];
    [self _setButtonScaledTappedAnimated:YES];
}

- (void)_didDragInside {
    _isTapped = YES;
    
    // After dragging out, without releasing, they dragged back in
    [self _setLabelAlphaTappedAnimated:YES];
    [self _setBackgroundColorTappedAnimated:YES];
    [self _setButtonScaledTappedAnimated:YES];
}

#pragma mark - Animation -

- (void)_setBackgroundColorTappedAnimated:(BOOL)animated ZKTintedActionButton_OBJC_DIRECT {
    if (!_tappedTintColor || _isTranslucent) { return; }
    
    // Toggle the background color of the title label
    void (^updateTitleOpacity)(void) = ^{
        self->_titleLabel.backgroundColor = [self _labelBackgroundColor];
    };
    
    // -----------------------------------------------------
    
    void (^animationBlock)(void) = ^{
        self->_backgroundView.backgroundColor = self->_isTapped ? self->_tappedTintColor : self.tintColor;
    };
    
    void (^completionBlock)(BOOL) = ^(BOOL completed){
        if (completed == NO) { return; }
        updateTitleOpacity();
    };
    
    if (!animated) {
        animationBlock();
        completionBlock(YES);
    }
    else {
        _titleLabel.backgroundColor = [UIColor clearColor];
        [UIView animateWithDuration:_tapAnimationDuration
                              delay:0.0f
             usingSpringWithDamping:1.0f
              initialSpringVelocity:0.5f
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:animationBlock
                         completion:completionBlock];
    }
    
}

- (void)_setLabelAlphaTappedAnimated:(BOOL)animated ZKTintedActionButton_OBJC_DIRECT {
    if (_tappedTextAlpha > 1.0f - FLT_EPSILON) { return; }
    
    CGFloat alpha = _isTapped ? _tappedTextAlpha : 1.0f;
    
    // Animate the alpha value of the label
    void (^animationBlock)(void) = ^{
        self->_titleLabel.alpha = alpha;
    };
    
    // If we're not animating, just call the blocks manually
    if (!animated) {
        // Remove any animations in progress
        [_titleLabel.layer removeAnimationForKey:@"opacity"];
        animationBlock();
        return;
    }
    
    // Set the title label to clear beforehand
    _titleLabel.backgroundColor = [UIColor clearColor];
    
    // Animate the button alpha
    [UIView animateWithDuration:_tapAnimationDuration
                          delay:0.0f
         usingSpringWithDamping:1.0f
          initialSpringVelocity:0.5f
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:animationBlock
                     completion:nil];
}

- (void)_setButtonScaledTappedAnimated:(BOOL)animated ZKTintedActionButton_OBJC_DIRECT {
    if (_tappedButtonScale < FLT_EPSILON) { return; }
    
    CGFloat scale = _isTapped ? _tappedButtonScale : 1.0f;
    
    // Animate the alpha value of the label
    void (^animationBlock)(void) = ^{
        self->_containerView.transform = CGAffineTransformScale(CGAffineTransformIdentity,
                                                                scale,
                                                                scale);
    };
    
    // If we're not animating, just call the blocks manually
    if (!animated) {
        animationBlock();
        return;
    }
    
    // Animate the button alpha
    [UIView animateWithDuration:_tapAnimationDuration
                          delay:0.0f
         usingSpringWithDamping:1.0f
          initialSpringVelocity:0.5f
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:animationBlock
                     completion:nil];
}

#pragma mark - Public Accessors -

- (void)setContentView:(UIView *)contentView {
    if (_contentView == contentView) { return; }
    
    _titleLabel = nil;
    [_contentView removeFromSuperview];
    _contentView = contentView ?: [UIView new];
    [self addSubview:_contentView];
    [self setNeedsLayout];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    [self _makeTitleLabelIfNeeded];
    _titleLabel.attributedText = attributedText;
    [_titleLabel sizeToFit];
    [self setNeedsLayout];
}

- (NSAttributedString *)attributedText { return _titleLabel.attributedText; }

- (void)setText:(NSString *)text {
    [self _makeTitleLabelIfNeeded];
    _titleLabel.text = text;
    [_titleLabel sizeToFit];
    [self setNeedsLayout];
}

- (NSString *)text { return _titleLabel.text; }

- (void)setTextFont:(UIFont *)textFont {
    _titleLabel.font = textFont;
    self.textPointSize = 0.0f; // Reset the IB text point size back to disabled
}
- (UIFont *)textFont { return _titleLabel.font; }

- (void)setTextColor:(UIColor *)textColor {
    _titleLabel.textColor = textColor;
}
- (UIColor *)textColor { return _titleLabel.textColor; }

- (void)setTextPointSize:(CGFloat)textPointSize {
    if (_textPointSize == textPointSize) { return; }
    _textPointSize = textPointSize;
    _titleLabel.font = [UIFont boldSystemFontOfSize:textPointSize];
    [self setNeedsLayout];
}

- (void)setTintColor:(UIColor *)tintColor {
    [super setTintColor:tintColor];
    [self _updateTappedTintColorForTintColor];
    _backgroundView.backgroundColor = tintColor;
    _titleLabel.backgroundColor = [self _labelBackgroundColor];
    [self setNeedsLayout];
}

- (void)setTappedTintColor:(UIColor *)tappedTintColor {
    if (_tappedTintColor == tappedTintColor) { return; }
    _tappedTintColor = tappedTintColor;
    _tappedTintColorBrightnessOffset = 0.0f;
    [self setNeedsLayout];
}

- (void)setTappedTintColorBrightnessOffset:(CGFloat)tappedTintColorBrightnessOffset {
    if (TO_ROUNDED_BUTTON_FLOATS_MATCH(_tappedTintColorBrightnessOffset,
                                       tappedTintColorBrightnessOffset)) { return; }
    
    _tappedTintColorBrightnessOffset = tappedTintColorBrightnessOffset;
    [self _updateTappedTintColorForTintColor];
    [self setNeedsLayout];
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    // Make sure the corner radius doesn't match
    if (fabs(cornerRadius - _cornerRadius) < FLT_EPSILON) {
        return;
    }
    
    _cornerRadius = cornerRadius;
    _backgroundView.layer.cornerRadius = _cornerRadius;
    [self setNeedsLayout];
}

- (void)setIsTranslucent:(BOOL)isTranslucent {
    if (_isTranslucent == isTranslucent) {
        return;
    }
    
    _isTranslucent = isTranslucent;
    [_backgroundView removeFromSuperview];
    _backgroundView = [self _makeBackgroundViewWithBlur:_isTranslucent];
    [_containerView insertSubview:_backgroundView atIndex:0];
    _titleLabel.backgroundColor = [self _labelBackgroundColor];
    [self setNeedsLayout];
}

- (void)setBlurStyle:(UIBlurEffectStyle)blurStyle {
    if (_blurStyle == blurStyle) {
        return;
    }
    
    _blurStyle = blurStyle;
    if (!_isTranslucent || ![_backgroundView isKindOfClass:[UIVisualEffectView class]]) {
        return;
    }
    
    UIVisualEffectView *const blurView = (UIVisualEffectView *)_backgroundView;
    [blurView setEffect:[UIBlurEffect effectWithStyle:_blurStyle]];
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    _containerView.alpha = enabled ? 1 : 0.4;
}

#pragma mark - Graphics Handling -

- (UIColor *)_brightnessAdjustedColorWithColor:(UIColor *)color amount:(CGFloat)amount ZKTintedActionButton_OBJC_DIRECT {
    if (!color) { return nil; }
    
    CGFloat h, s, b, a;
    if (![color getHue:&h saturation:&s brightness:&b alpha:&a]) { return nil; }
    b += amount; // Add the adjust amount
    b = MAX(b, 0.0f); b = MIN(b, 1.0f);
    return [UIColor colorWithHue:h saturation:s brightness:b alpha:a];
}

@end
