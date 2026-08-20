//
//  ZKBackBarButton.h
//  ZKFoundation
//
//  Created by Kaiser on 2026/8/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 系统提供了 UINavigationItem.backBarButtonItem 用于指定当前界面的所有下一级界面的返回按钮文字，但只有文字会生效，customView、target-action 事件都会被忽略。
 ZKBackBarButton 支持设置一个自定义 view 作为所有下一级界面的返回按钮（常见场景例如聊天界面返回按钮显示圆形未读数）。

 使用方式与系统 backBarButtonItem 一致：设置在前一个界面的 navigationItem 上，在下一级界面生效。
 将 kai_backBarButton 置为 nil 即可恢复系统返回按钮。

 @note 自定义返回按钮本质上是 leftBarButtonItem（customView），业务需自行处理点击 pop；
 组件会尽量保证侧滑返回手势在显示自定义返回按钮时仍可用。
 */
@interface UINavigationItem (ZKBackBarButton)

/**
 设置一个自定义的 view，令当前界面的所有下一级界面都使用这个 view 作为它们的返回按钮。
 */
@property (nullable, nonatomic, strong) __kindof UIView *kai_backBarButton;

@end

@protocol ZKBackBarButtonViewControllerSupport <NSObject>

@optional
/**
 默认情况下当界面 A 设置了 kai_backBarButton，A push 到的所有子界面都会显示自定义的返回按钮。
 若子界面实现本协议并在 shouldShowBackBarButton: 里返回 NO，则可控制自己不显示该自定义返回按钮。
 默认不实现则视为要显示按钮。
 */
- (BOOL)shouldShowBackBarButton:(__kindof UIView *)button;

@end

NS_ASSUME_NONNULL_END
