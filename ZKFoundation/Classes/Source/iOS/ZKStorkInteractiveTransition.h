//
//  ZKStorkInteractiveTransition.h
//  ZKFoundation
//
//  Created by zhangkai on 2019/11/14.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>

/*!
 *  效果参考iOS13 controller.modalPresentationStyle = UIModalPresentationAutomatic
 *  @code
        ModalViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"ModalViewController"];
        controller.modalPresentationStyle = UIModalPresentationCustom;

        self.animator = [[ZKStorkInteractiveTransition alloc] initWithModalViewController:controller];
        self.animator.transitionDuration = 0.6f;

        [self.animator setContentScrollView:controller.scrollView];

        controller.transitioningDelegate = self.animator;
        [self presentViewController:controller animated:YES completion:nil];
 *  @endcode
 */
@interface ZFDetectScrollViewEndGestureRecognizer : UIPanGestureRecognizer
@property (nonatomic, weak) UIScrollView *scrollview;
@end

@interface ZKStorkInteractiveTransition : UIPercentDrivenInteractiveTransition <UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, assign, getter=isDragable) BOOL dragable; // 是否支持手势dismiss controller
@property (nonatomic, readonly) ZFDetectScrollViewEndGestureRecognizer *gesture;
@property (nonatomic, assign) UIGestureRecognizer *gestureRecognizerToFailPan;
@property BOOL bounces;
@property CGFloat behindViewScale;      // default 0.9
@property CGFloat behindViewAlpha;      // default 1.0
@property CGFloat transitionDuration;   // default 0.8
@property CGFloat cornerRadius;         // default 10
@property CGFloat translateForDismiss;  // default 200

- (id)initWithModalViewController:(UIViewController *)modalViewController;
- (void)setContentScrollView:(UIScrollView *)scrollView;

@end
