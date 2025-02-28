//
//  ZKAlertAction.h
//  AXIndicatorView
//
//  Created by zhangkai on 2025/2/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 定义一个类型别名，用于表示处理ZKAlert的闭包
typedef void (^ZKAlertActionHandler)(id _Nonnull alert);

// 定义枚举类型，表示ZKAlertAction的样式
typedef NS_ENUM(NSInteger, ZKAlertActionStyle) {
    ZKAlertActionStyleDefault,
    ZKAlertActionStyleDestructive,
    ZKAlertActionStyleCancel
};

@interface ZKAlertAction : NSObject

// 动作的标题
@property (nonatomic, copy) NSString * _Nullable title;
// 标题的内边距
@property (nonatomic, assign) UIEdgeInsets titleEdgeInsets;
// 标题的颜色
@property (nonatomic, strong) UIColor * _Nullable titleColor;
// 字体
@property (nonatomic, strong) UIFont *font;
// 副标题
@property (nonatomic, copy) NSString * _Nullable subtitle;
// 副标题的颜色
@property (nonatomic, strong) UIColor * _Nullable subtitleColor;
// 图像
@property (nonatomic, strong) UIImage * _Nullable image;
// 图像的内边距
@property (nonatomic, assign) UIEdgeInsets imageEdgeInsets;
// 动作的样式
@property (nonatomic, assign) ZKAlertActionStyle style;
// 处理动作的闭包
@property (nonatomic, copy) ZKAlertActionHandler _Nullable handler;

// 便利构造器，只传入标题
- (instancetype)initWithTitle:(NSString *)title;
// 便利构造器，传入标题和处理闭包
- (instancetype)initWithTitle:(NSString *)title handler:(ZKAlertActionHandler)handler;
// 初始化方法，传入标题、处理闭包和样式
- (instancetype)initWithTitle:(NSString *)title handler:(ZKAlertActionHandler _Nullable)handler style:(ZKAlertActionStyle)style;
// 初始化方法，传入标题、描述、处理闭包和样式
- (instancetype)initWithTitle:(NSString *)title desc:(NSString *)desc handler:(ZKAlertActionHandler _Nullable)handler style:(ZKAlertActionStyle)style;

@end

NS_ASSUME_NONNULL_END
