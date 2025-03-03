//
//  ZKAlertAction.m
//  AXIndicatorView
//
//  Created by zhangkai on 2025/2/27.
//

#import "ZKAlertAction.h"

@implementation ZKAlertAction

// 便利构造器，只传入标题
- (instancetype)initWithTitle:(NSString *)title {
    return [self initWithTitle:title handler:nil style:ZKAlertActionStyleDefault];
}

// 便利构造器，传入标题和处理闭包
- (instancetype)initWithTitle:(NSString *)title handler:(ZKAlertActionHandler)handler {
    return [self initWithTitle:title handler:handler style:ZKAlertActionStyleDefault];
}

// 初始化方法，传入标题、处理闭包和样式
- (instancetype)initWithTitle:(NSString *)title handler:(ZKAlertActionHandler _Nullable)handler style:(ZKAlertActionStyle)style {
    self = [super init];
    if (self) {
        self.title = title;
        self.handler = handler;
        self.style = style;
        self.font = [UIFont systemFontOfSize:17];
        self.titleEdgeInsets = UIEdgeInsetsZero;
        self.imageEdgeInsets = UIEdgeInsetsZero;
    }
    return self;
}

// 初始化方法，传入标题、描述、处理闭包和样式
- (instancetype)initWithTitle:(NSString *)title subtitle:(NSString *)subtitle handler:(ZKAlertActionHandler _Nullable)handler style:(ZKAlertActionStyle)style {
    self = [self initWithTitle:title handler:handler style:style];
    if (self) {
        self.subtitle = subtitle;
    }
    return self;
}

@end
