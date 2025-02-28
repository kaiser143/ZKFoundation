//
//  ZKAlertStyle.m
//  AXIndicatorView
//
//  Created by zhangkai on 2025/2/27.
//

#import "ZKAlertStyle.h"

@interface ZKAlertStyle ()

@property (nonatomic, strong, readwrite) ZKAlertStyleAppearance *appearance;

@end

@implementation ZKAlertStyle

// 根据 ZKAlertStyleType 初始化 ZKAlertStyle 实例的类方法
+ (instancetype)styleWithType:(ZKAlertStyleType)type {
    ZKAlertStyle *style = [[ZKAlertStyle alloc] init];
    switch (type) {
        case ZKAlertStyleTypeSystem:
            if (@available(iOS 12, *)) {
                UITraitCollection *traitCollection = [UIScreen mainScreen].traitCollection;
                if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
                    style.appearance = [ZKAlertStyle lightAppearance];
                } else {
                    style.appearance = [ZKAlertStyle darkAppearance];
                }
            } else {
                style.appearance = [ZKAlertStyle lightAppearance];
            }
            break;
        case ZKAlertStyleTypeLight:
            style.appearance = [ZKAlertStyle lightAppearance];
            break;
        case ZKAlertStyleTypeDark:
            style.appearance = [ZKAlertStyle darkAppearance];
            break;
        case ZKAlertStyleTypeCustom:
            // 自定义样式，这里可以根据需要进行初始化
            style.appearance = [[ZKAlertStyleAppearance alloc] init];
            break;
    }
    return style;
}

// 获取当前样式的外观属性
- (ZKAlertStyleAppearance *)appearance {
    return _appearance;
}

// 系统样式的外观
+ (ZKAlertStyleAppearance *)lightAppearance {
    ZKAlertStyleAppearance *appearance = [[ZKAlertStyleAppearance alloc] init];
    appearance.dimmingBackgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    appearance.containerBackgroundColor = [UIColor whiteColor];
    appearance.titleColor = [UIColor colorWithWhite:0 alpha:0.5];
    appearance.buttonHeight = 56.0;
    appearance.buttonNormalBackgroundColor = [UIColor colorWithWhite:1 alpha:1];
    appearance.buttonHighlightBackgroundColor = [UIColor colorWithWhite:248.0/255 alpha:1];
    appearance.buttonTitleColor = [UIColor blackColor];
    appearance.destructiveButtonTitleColor = [UIColor redColor];
    appearance.separatorLineColor = [UIColor colorWithWhite:0 alpha:0.1];
    appearance.separatorColor = [UIColor colorWithWhite:247.0/255 alpha:1.0];
    appearance.enableBlurEffect = NO;
    return appearance;
}

// 暗色样式的外观
+ (ZKAlertStyleAppearance *)darkAppearance {
    ZKAlertStyleAppearance *appearance = [[ZKAlertStyleAppearance alloc] init];
    appearance.dimmingBackgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    appearance.containerBackgroundColor = [UIColor colorWithWhite:44.0/255.0 alpha:1.0];
    appearance.titleColor = [UIColor colorWithWhite:1 alpha:0.5];
    appearance.buttonHeight = 56.0;
    appearance.buttonNormalBackgroundColor = [UIColor colorWithWhite:44.0/255 alpha:1.0];
    appearance.buttonHighlightBackgroundColor = [UIColor colorWithWhite:54.0/255 alpha:1.0];
    appearance.buttonTitleColor = [UIColor whiteColor];
    appearance.destructiveButtonTitleColor = [UIColor redColor];
    appearance.separatorLineColor = [UIColor colorWithWhite:1 alpha:0.05];
    appearance.separatorColor = [UIColor colorWithWhite:30.0/255 alpha:1.0];
    appearance.enableBlurEffect = NO;
    appearance.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    return appearance;
}

@end


@implementation ZKAlertStyleAppearance

- (instancetype)init {
    self = [super init];
    if (self) {
        self.dimmingBackgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        self.containerBackgroundColor = [UIColor whiteColor];
        self.titleColor = [UIColor colorWithWhite:0 alpha:0.5];
        self.buttonHeight = 56.0;
        self.buttonNormalBackgroundColor = [UIColor colorWithWhite:1 alpha:1];
        self.buttonHighlightBackgroundColor = [UIColor colorWithWhite:248.0/255 alpha:1];
        self.buttonTitleColor = [UIColor blackColor];
        self.destructiveButtonTitleColor = [UIColor redColor];
        self.separatorLineColor = [UIColor colorWithWhite:0 alpha:0.05];
        self.separatorColor = [UIColor colorWithWhite:242.0/255 alpha:1.0];
        self.enableBlurEffect = NO;
        self.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    }
    return self;
}

@end
