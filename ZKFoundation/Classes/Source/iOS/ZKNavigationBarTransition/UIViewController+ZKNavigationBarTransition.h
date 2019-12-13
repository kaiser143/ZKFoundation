//
//  UIViewController+ZKNavigationBarTransition.h
//  ZKFoundation
//
//  Created by zhangkai on 2019/11/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 *  @code
     - (void)scrollViewDidScroll:(UIScrollView *)scrollView {
         CGFloat headerHeight = CGRectGetHeight(self.headerView.frame);
         if (@available(iOS 11, *)) {
             headerHeight -= self.view.safeAreaInsets.top;
         } else {
             headerHeight -= [self.topLayoutGuide length];
         }

         CGFloat progress         = scrollView.contentOffset.y + scrollView.contentInset.top;
         CGFloat gradientProgress = MIN(1, MAX(0, progress / headerHeight));
         gradientProgress         = gradientProgress * gradientProgress * gradientProgress * gradientProgress;
         if (gradientProgress != _gradientProgress) {
             _gradientProgress         = gradientProgress;
             [self kai_refreshNavigationBarStyle];
         }
     }
 *  @endcode
 */
@interface UIViewController (ZKNavigationBarTransition)


- (BOOL)kai_customNavigationBarStyleEnabled;

- (void)kai_refreshNavigationBarStyle;

- (CGRect)kai_fakeBarFrameForNavigationBar:(UINavigationBar *)navigationBar;

@end

NS_ASSUME_NONNULL_END
