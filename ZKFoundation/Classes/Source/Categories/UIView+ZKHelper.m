//
//  UIView+Foundation.m
//  FBSnapshotTestCase
//
//  Created by Kaiser on 2019/3/12.
//

#import "UIView+ZKHelper.h"
#import <objc/runtime.h>

@implementation UIView (Helper)

- (CGSize)systemFittingSize {
    CGFloat contentViewWidth = CGRectGetWidth(self.frame);
    
    CGSize viewSize = CGSizeMake(contentViewWidth, 0);
    
    if (contentViewWidth > 0) {
        if (viewSize.height <= 0) {
            // Add a hard width constraint to make dynamic content views (like labels) expand vertically instead
            // of growing horizontally, in a flow-layout manner.
            NSLayoutConstraint *widthFenceConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:contentViewWidth];
            [self addConstraint:widthFenceConstraint];
            
            // Auto layout engine does its math
            viewSize = [self systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
            [self removeConstraint:widthFenceConstraint];
        }
    }else{
#if DEBUG
        // Warn if using AutoLayout but get zero height.
        if (self.constraints.count > 0) {
            if (!objc_getAssociatedObject(self, _cmd)) {
                NSLog(@"[ViewMethod] Warning once only: Cannot get a proper View Size (now 0) from '- systemFittingSize:'(AutoLayout). You should check how constraints are built in View, making it into 'self-sizing' view.");
                objc_setAssociatedObject(self, _cmd, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }
        }
#endif
        // Try '- sizeThatFits:' for frame layout.
        // Note: fitting height should not include separator view.
        viewSize = [self sizeThatFits:CGSizeMake(contentViewWidth, 0)];
    }
    
    if (viewSize.height < CGRectGetHeight(self.frame))
        viewSize.height = CGRectGetHeight(self.frame);
    
    return viewSize;
}

@end
