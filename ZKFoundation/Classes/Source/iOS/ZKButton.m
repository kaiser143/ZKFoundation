//
//  ZKButton.m
//  FBSnapshotTestCase
//
//  Created by Kaiser on 2019/3/8.
//

#import "ZKButton.h"

@implementation ZKButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self == nil) return nil;
    
    _space = 0.f;
    _delta = 8.f;
    
    [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
    
    return self;
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    if (CGRectIsEmpty(contentRect)) return contentRect;
    
    CGFloat imageX;
    CGFloat imageY;
    
    CGFloat imageW;
    CGFloat imageH;
    
    switch (_style) {
        case ZKButtonStyleImageAtTop: {
            
            /*
             图片在上 文字在下
             */
            imageH = self.imageView.image.size.height;
            imageW = self.imageView.image.size.width;
            
            imageX = (CGRectGetWidth(contentRect) - imageW) / 2.f;
            imageY = _delta;
            
        }
            break;
        case ZKButtonStyleImageAtLeft: {
            
            /*
             图片在左，文字在右
             */
            imageH = self.imageView.image.size.height;
            imageW = self.imageView.image.size.width;
            
            imageX = _delta;
            imageY = (CGRectGetHeight(contentRect) - imageH)/2.f;
        }
            break;
        case ZKButtonStyleImageAtRight: {
            
            /*
             图片在右，文字在左
             */
            imageH = self.imageView.image.size.height;
            imageW = self.imageView.image.size.width;
            
            imageX = CGRectGetWidth(contentRect) - imageW - _delta;
            imageY = (CGRectGetHeight(contentRect) - imageH)/2.f;
            
        }
            break;
        case ZKButtonStyleImageAtBottom: {
            
            /*
             图片在下 文字在上
             */
            imageH = self.imageView.image.size.height;
            imageW = self.imageView.image.size.width;
            
            imageX = (CGRectGetWidth(contentRect) - imageW) / 2;
            imageY = (CGRectGetHeight(contentRect) - _delta * 2) - imageH + _delta  + _space;
            
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
    
    CGFloat titleW;
    CGFloat titleH;
    
    switch (_style) {
        case ZKButtonStyleImageAtTop: {
            CGRect frame = [self imageRectForContentRect:contentRect];
            titleY = CGRectGetMaxY(frame) + self.space;
            
            titleW = CGRectGetWidth(contentRect) - _delta * 2;
            titleH = CGRectGetHeight(contentRect) - titleY - _delta;
            
            titleX = (CGRectGetWidth(contentRect) - titleW)/2.f;
        }
            break;
        case ZKButtonStyleImageAtLeft: {
            CGRect frame = [self imageRectForContentRect:contentRect];
            titleX = CGRectGetMaxX(frame) + self.space;
            titleY = _delta;
            
            titleW = CGRectGetWidth(contentRect) - CGRectGetWidth(frame) - 2*self.delta - self.space;
            titleH = CGRectGetHeight(contentRect) - _delta * 2;
            
        }
            break;
        case ZKButtonStyleImageAtRight: {
            
            titleX = _delta;
            titleY = _delta;
            
            titleW = CGRectGetWidth(contentRect) - self.imageView.image.size.width - 2*self.delta - self.space;
            titleH = CGRectGetHeight(contentRect) - _delta * 2;
        }
            break;
            
        case ZKButtonStyleImageAtBottom: {
            
            titleX = _delta;
            titleY = _delta;
            
            titleW = CGRectGetWidth(contentRect) - _delta * 2;
            titleH = CGRectGetHeight(contentRect) - (CGRectGetHeight(contentRect) - _delta * 2) * 0.65 - _delta * 2 - _space;
            
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
            intrinsicContentSize.height = 2*self.delta + CGRectGetHeight(imageRect) + self.space + CGRectGetHeight(titleRect);
            intrinsicContentSize.width = MAX(CGRectGetWidth(titleRect), CGRectGetWidth(imageRect)) + 2*self.delta;
        }
            break;
        case ZKButtonStyleImageAtLeft:
        case ZKButtonStyleImageAtRight: {
            intrinsicContentSize.height = MAX(CGRectGetHeight(titleRect), CGRectGetHeight(imageRect)) + 2*self.delta;
            intrinsicContentSize.width = 2*self.delta + CGRectGetWidth(imageRect) + self.space + CGRectGetWidth(titleRect);
        }
            break;
        default:
            break;
    }
    
    return intrinsicContentSize;
}

@end
