//
//  ZKPopupController.h
//  ZKFoundation
//
//  Created by Kaiser on 2019/4/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ZKPopupControllerDelegate;
@class ZKPopupTheme;

@interface ZKPopupController : NSObject

@property (nonatomic, strong) ZKPopupTheme *_Nonnull theme;
@property (nonatomic, weak) id <ZKPopupControllerDelegate> _Nullable delegate;

- (nonnull instancetype) init __attribute__((unavailable("You cannot initialize through init - please use initWithContents:")));
- (nonnull instancetype)initWithContents:(nonnull NSArray<UIView *> *)contents NS_DESIGNATED_INITIALIZER;

- (void)presentPopupControllerAnimated:(BOOL)flag;
- (void)dismissPopupControllerAnimated:(BOOL)flag;

@end

@protocol ZKPopupControllerDelegate <NSObject>

@optional
- (void)popupControllerWillPresent:(nonnull ZKPopupController *)controller;
- (void)popupControllerDidPresent:(nonnull ZKPopupController *)controller;
- (void)popupControllerWillDismiss:(nonnull ZKPopupController *)controller;
- (void)popupControllerDidDismiss:(nonnull ZKPopupController *)controller;

@end

// ZKPopupStyle：控制弹窗展示后的外观样式
typedef NS_ENUM(NSUInteger, ZKPopupStyle) {
    ZKPopupStyleActionSheet = 0, // 从底部展示，类似系统 Action Sheet
    ZKPopupStyleCentered, // 在屏幕中央展示
    ZKPopupStyleFullscreen // 全屏展示，类似全屏视图控制器
};

// ZKPopupPresentationStyle：控制弹窗的出场动画方式
typedef NS_ENUM(NSInteger, ZKPopupPresentationStyle) {
    ZKPopupPresentationStyleFadeIn = 0,
    ZKPopupPresentationStyleSlideInFromTop,
    ZKPopupPresentationStyleSlideInFromBottom,
    ZKPopupPresentationStyleSlideInFromLeft,
    ZKPopupPresentationStyleSlideInFromRight
};

// ZKPopupMaskType：弹窗背景遮罩类型
typedef NS_ENUM(NSInteger, ZKPopupMaskType) {
    ZKPopupMaskTypeClear,
    ZKPopupMaskTypeDimmed,
    ZKPopupMaskTypeCustom
};

@interface ZKPopupTheme : NSObject

@property (nonatomic, strong) UIColor *backgroundColor; // 弹窗内容视图背景色（默认白色）
@property (nonatomic, strong) UIColor *customMaskColor; // ZKPopupMaskTypeCustom 时的自定义遮罩颜色
@property (nonatomic, assign) CGFloat cornerRadius; // 弹窗内容视图圆角（默认 4.0）
@property (nonatomic, assign) UIEdgeInsets popupContentInsets; // 弹窗内容内边距（默认四边 16.0）
@property (nonatomic, assign) ZKPopupStyle popupStyle; // 弹窗展示样式（默认居中）
@property (nonatomic, assign) ZKPopupPresentationStyle presentationStyle; // 出场动画方式（默认从底部滑入。仅对 ZKPopupStyleCentered 生效）
@property (nonatomic, assign) ZKPopupMaskType maskType; // 背景遮罩类型（默认半透明暗色）
@property (nonatomic, assign) BOOL dismissesOppositeDirection; // 是否沿出场反方向消失（默认 NO，即原路返回）
@property (nonatomic, assign) BOOL shouldDismissOnBackgroundTouch; // 点击背景遮罩是否关闭弹窗（默认 YES）
@property (nonatomic, assign) BOOL movesAboveKeyboard; // 键盘弹出时弹窗是否上移（默认 YES）
@property (nonatomic, assign) CGFloat blurEffectAlpha; // 背景模糊效果透明度（默认 0.0）
@property (nonatomic, assign) CGFloat contentVerticalPadding; // 垂直方向元素间距（默认 12.0）
@property (nonatomic, assign) CGFloat maxPopupWidth; // 弹窗最大宽度（默认 300）
@property (nonatomic, assign) CGFloat animationDuration; // 出场/退场动画时长（默认 0.3 秒）

// Factory method to help build a default theme
+ (ZKPopupTheme *)defaultTheme;

@end

NS_ASSUME_NONNULL_END
