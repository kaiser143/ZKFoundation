//
//  ZKTintedActionButton.m
//  Masonry
//
//  Created by Kaiser on 2019/4/3.
//

#import "ZKTintedActionButton.h"

@interface UIColor (Desaturated)
/**
 Returns a desaturated version of the current color.
 
 Source: https://stackoverflow.com/a/23120676/3905655
 */
@property (nonatomic, readonly) UIColor *kai_desaturatedColor;
@end


@interface ZKTintedActionButton () @end


@implementation ZKTintedActionButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        [self updateColors];
        [self configureAppearance];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];

    [self updateColors];
    [self configureAppearance];
}

//- (CGSize)intrinsicContentSize {
//    if (self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact && self.traitCollection.userInterfaceIdiom != UIUserInterfaceIdiomPad) {
//        return super.intrinsicContentSize;
//    }
//    return CGSizeMake(UIViewNoIntrinsicMetric, kHeight);
//}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    [self invalidateIntrinsicContentSize];
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    [self updateColors];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];

    if (highlighted) {
        self.backgroundColor = self.tintColor.kai_desaturatedColor;
    } else if ([self isEnabled]) {
        self.backgroundColor = self.tintColor;
    }
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];

    if (enabled == NO) {
        self.backgroundColor = self.tintColor.kai_desaturatedColor;
        return;
    }

    [self setHighlighted:[self isHighlighted]];
}

#pragma mark - Appearance

- (void)configureAppearance {
//    self.clipsToBounds      = YES;
//    self.layer.cornerRadius = kRadius;

    if (@available(iOS 9.0, *)) {
        self.titleLabel.font = [UIFont monospacedDigitSystemFontOfSize:self.titleLabel.font.pointSize
                                                                weight:UIFontWeightMedium];
    }
}

#pragma mark - Colors

- (void)updateColors {
    self.backgroundColor = self.tintColor;

    [self setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
}

@end


@implementation UIColor (Desaturated)

#define kSaturation 0.5f

- (UIColor *)kai_desaturatedColor {
    CGFloat hue, saturation, brightness, alpha = 0.0f;
    if (![self getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha]) {
        return [self colorWithAlphaComponent:kSaturation];
    }
    if (saturation == 0.0f) {
        // if the saturation is already low, increase
        // brightness instead to get a visible effect
        brightness = MIN(brightness + 0.1f, 1.0f);
    } else {
        saturation = MAX(saturation - kSaturation, 0.0f);
    }
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:alpha];
}

@end
