//
//  ZKAlertStyle.h
//  AXIndicatorView
//
//  Created by zhangkai on 2025/2/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class ZKAlertStyleAppearance;

// 定义枚举类型 ZKAlertStyleType 表示不同的 ZKAlert 样式
typedef NS_ENUM(NSInteger, ZKAlertStyleType) {
    ZKAlertStyleTypeSystem NS_ENUM_AVAILABLE_IOS(13_0),  // 系统样式，iOS 13.0 及以上可用
    ZKAlertStyleTypeLight,  // 亮色样式
    ZKAlertStyleTypeDark,  // 暗色样式
    ZKAlertStyleTypeCustom  // 自定义样式
};

@interface ZKAlertStyle : NSObject

// 根据 ZKAlertStyleType 初始化 ZKAlertStyle 实例的类方法
+ (instancetype)styleWithType:(ZKAlertStyleType)type;

// 获取当前样式的外观属性
@property (nonatomic, strong, readonly) ZKAlertStyleAppearance *appearance;

// 系统样式的外观
+ (id)lightAppearance;
// 暗色样式的外观
+ (id)darkAppearance;

@end


// 外观配置类
@interface ZKAlertStyleAppearance : NSObject

// 遮罩背景颜色
@property (nonatomic, strong) UIColor *dimmingBackgroundColor;
// 容器背景颜色
@property (nonatomic, strong) UIColor *containerBackgroundColor;
// 标题颜色
@property (nonatomic, strong) UIColor *titleColor;
// 按钮高度
@property (nonatomic, assign) CGFloat buttonHeight;
// 按钮正常状态背景颜色
@property (nonatomic, strong) UIColor *buttonNormalBackgroundColor;
// 按钮高亮状态背景颜色
@property (nonatomic, strong) UIColor *buttonHighlightBackgroundColor;
// 按钮标题颜色
@property (nonatomic, strong) UIColor *buttonTitleColor;
// 危险按钮标题颜色
@property (nonatomic, strong) UIColor *destructiveButtonTitleColor;
// 分隔线颜色
@property (nonatomic, strong) UIColor *separatorLineColor;
// 取消按钮和其他按钮之间的分隔线颜色
@property (nonatomic, strong) UIColor *separatorColor;
// 是否启用模糊效果
@property (nonatomic, assign) BOOL enableBlurEffect;
// 模糊效果
@property (nonatomic, strong) UIVisualEffect *effect;

@end

NS_ASSUME_NONNULL_END
