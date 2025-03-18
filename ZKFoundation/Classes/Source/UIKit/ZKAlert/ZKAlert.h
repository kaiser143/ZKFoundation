//
//  ZKAlert.h
//  AXIndicatorView
//
//  Created by zhangkai on 2025/2/27.
//

#import <UIKit/UIKit.h>
#import "ZKAlertStyle.h"
#import "ZKAlertAction.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZKAlert : UIView

// 弹窗样式
@property (nonatomic, strong) ZKAlertStyle *style;
// 标题视图
@property (nonatomic, strong) UIView * _Nullable titleView;
// 是否圆角顶部，默认 YES
@property (nonatomic, assign) BOOL roundTopCorners;

// 初始化方法，传入取消按钮标题
- (instancetype)initWithCancelButtonTitle:(NSString * _Nullable)cancelButtonTitle;

// 显示弹窗
- (void)present;
// 隐藏弹窗
- (void)dismiss;
// 添加动作
- (void)addAction:(ZKAlertAction *)action;

@end

NS_ASSUME_NONNULL_END
