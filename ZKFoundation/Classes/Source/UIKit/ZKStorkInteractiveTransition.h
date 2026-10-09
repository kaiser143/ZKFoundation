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

@property (nonatomic, assign, getter=isDragable) BOOL dragable; // 是否支持下滑手势关闭弹层（默认 NO，设置 contentScrollView 后自动置 YES）
/// 弹层上的下滑识别器；scrollview 滚动到顶部后继续下滑时触发关闭，其余滚动仍由 scrollview 自身处理
@property (nonatomic, readonly) ZFDetectScrollViewEndGestureRecognizer *gesture;
/// 需要让位给弹层下滑手势的外部手势（如 scrollview 自带的 pan），命中时弹层手势优先
@property (nonatomic, assign) UIGestureRecognizer *gestureRecognizerToFailPan;
/// 是否允许上滑回弹；默认 NO，上滑直接夹零，设 YES 则允许顶部露出 Pastor 空隙
@property BOOL bounces;
@property CGFloat behindViewScale;      // 弹出后底下页面的缩放（默认 0.9，取值 0~1）
@property CGFloat behindViewAlpha;      // 弹出后底下页面的透明度（默认 1.0，即不变暗）
@property CGFloat transitionDuration;   // 弹出/关闭动画时长（默认 0.8 秒，弹簧无过冲）
@property CGFloat cornerRadius;         // 弹层顶部左右圆角（默认 10，两端页面同步切角）
@property CGFloat translateForDismiss;  // 下滑关闭的手势速度阈值（默认 200，velocity.y 超过即关闭，否则回弹）

- (id)initWithModalViewController:(UIViewController *)modalViewController;
- (void)setContentScrollView:(UIScrollView *)scrollView;

@end
