//
//  ZKButton.m
//  ZKFoundation
//
//  Created by Kaiser on 2019/3/8.
//

#import "ZKButton.h"
#import <ZKCategories/ZKCategories.h>

@implementation ZKButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self == nil) return nil;
    
    _spacingBetweenImageAndTitle = 0.f;
    
    [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
    
    return self;
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    if (CGRectIsEmpty(contentRect)) return contentRect;
    
    CGFloat imageX;
    CGFloat imageY;
    
    // fix iOS 12.4.8 crash
//    CGFloat imageW = self.imageView.image.size.width;
//    CGFloat imageH = self.imageView.image.size.height;
    
    CGFloat imageW = [self imageForState:self.state].size.width;
    CGFloat imageH = [self imageForState:self.state].size.height;
    
    switch (_style) {
        case ZKButtonStyleImageAtTop: {
            /*
             图片在上 文字在下
             */
            imageX = (CGRectGetWidth(contentRect) - imageW) / 2.f + self.contentEdgeInsets.left;
            imageY = self.contentEdgeInsets.top;
        }
            break;
        case ZKButtonStyleImageAtLeft: {
            /*
             图片在左，文字在右
             */
            imageX = self.contentEdgeInsets.left;
            imageY = (CGRectGetHeight(contentRect) - imageH)/2.f + self.contentEdgeInsets.top;
        }
            break;
        case ZKButtonStyleImageAtRight: {
            /*
             图片在右，文字在左
             */
            CGRect frame = [self titleRectForContentRect:contentRect];
            imageX = CGRectGetMaxX(frame) + self.spacingBetweenImageAndTitle;
            imageY = (CGRectGetHeight(contentRect) - imageH)/2.f + self.contentEdgeInsets.top;
        }
            break;
        case ZKButtonStyleImageAtBottom: {
            /*
             图片在下 文字在上
             */
            CGRect frame = [self titleRectForContentRect:contentRect];
            imageX = (CGRectGetWidth(contentRect) - imageW) / 2 + self.contentEdgeInsets.left;
            imageY = CGRectGetMaxY(frame) + self.spacingBetweenImageAndTitle;
        }
            break;
        default:
            break;
    }
    
    return CGRectMake(imageX, imageY, imageW, imageH);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    if (CGRectIsEmpty(contentRect)) return contentRect;
    
    CGFloat titleX;
    CGFloat titleY;
    
    CGSize size = [self.currentTitle sizeForFont:self.titleLabel.font size:contentRect.size mode:NSLineBreakByWordWrapping];
    CGFloat titleW = size.width;
    CGFloat titleH = size.height;
    
    switch (_style) {
        case ZKButtonStyleImageAtTop: {
            CGRect frame = [self imageRectForContentRect:contentRect];
            titleY = CGRectGetMaxY(frame) + self.spacingBetweenImageAndTitle;
            titleX = (CGRectGetWidth(contentRect) - titleW)/2.f + self.contentEdgeInsets.left;
        }
            break;
        case ZKButtonStyleImageAtLeft: {
            CGRect frame = [self imageRectForContentRect:contentRect];
            titleX = CGRectGetMaxX(frame) + self.spacingBetweenImageAndTitle;
            titleY = (CGRectGetHeight(contentRect) - titleH)/2.f + self.contentEdgeInsets.top;
        }
            break;
        case ZKButtonStyleImageAtRight: {
            titleX = self.contentEdgeInsets.left;
            titleY = (CGRectGetHeight(contentRect) - titleH)/2.f + self.contentEdgeInsets.top;
        }
            break;
            
        case ZKButtonStyleImageAtBottom: {
            titleX = self.contentEdgeInsets.left;
            titleY = self.contentEdgeInsets.top;
        }
            break;
        default:
            break;
    }
    
    return CGRectMake(titleX, titleY, titleW, titleH);
}

- (CGSize)intrinsicContentSize {
    CGRect imageRect = [super imageRectForContentRect:CGRectInfinite];
    CGRect titleRect = [super titleRectForContentRect:CGRectInfinite];
    CGSize intrinsicContentSize = [super intrinsicContentSize];
    
    switch (self.style) {
        case ZKButtonStyleImageAtTop:
        case ZKButtonStyleImageAtBottom: {
            intrinsicContentSize.height = self.contentEdgeInsets.top + self.contentEdgeInsets.bottom + CGRectGetHeight(imageRect) + self.spacingBetweenImageAndTitle + CGRectGetHeight(titleRect);
            intrinsicContentSize.width = MAX(CGRectGetWidth(titleRect), CGRectGetWidth(imageRect)) + self.contentEdgeInsets.left + self.contentEdgeInsets.right;
        }
            break;
        case ZKButtonStyleImageAtLeft:
        case ZKButtonStyleImageAtRight: {
            intrinsicContentSize.height = MAX(CGRectGetHeight(titleRect), CGRectGetHeight(imageRect)) + self.contentEdgeInsets.top + self.contentEdgeInsets.bottom;
            intrinsicContentSize.width = self.contentEdgeInsets.left + self.contentEdgeInsets.right + CGRectGetWidth(imageRect) + self.spacingBetweenImageAndTitle + CGRectGetWidth(titleRect);
        }
            break;
        default:
            break;
    }
    
    return intrinsicContentSize;
}

- (void)setTitle:(NSString *)title forState:(UIControlState)state {
    [super setTitle:title forState:state];
    [self layoutIfNeeded];
    [self invalidateIntrinsicContentSize];
}

- (void)setImage:(nullable UIImage *)image forState:(UIControlState)state {
    [super setImage:image forState:state];
    [self layoutIfNeeded];
    [self invalidateIntrinsicContentSize];
}

- (void)setBackgroundImage:(nullable UIImage *)image forState:(UIControlState)state {
    [super setBackgroundImage:image forState:state];
    [self layoutIfNeeded];
}

- (void)setSpacingBetweenImageAndTitle:(CGFloat)spacingBetweenImageAndTitle {
    _spacingBetweenImageAndTitle = spacingBetweenImageAndTitle;
    
    [self setNeedsLayout];
    [self invalidateIntrinsicContentSize];
}

- (void)setStyle:(ZKButtonStyle)style {
    _style = style;
    
    [self setNeedsLayout];
    [self invalidateIntrinsicContentSize];
}

@end
