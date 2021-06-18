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

// ZKPopupStyle: Controls how the popup looks once presented
typedef NS_ENUM(NSUInteger, ZKPopupStyle) {
    ZKPopupStyleActionSheet = 0, // Displays the popup similar to an action sheet from the bottom.
    ZKPopupStyleCentered, // Displays the popup in the center of the screen.
    ZKPopupStyleFullscreen // Displays the popup similar to a fullscreen viewcontroller.
};

// ZKPopupPresentationStyle: Controls how the popup is presented
typedef NS_ENUM(NSInteger, ZKPopupPresentationStyle) {
    ZKPopupPresentationStyleFadeIn = 0,
    ZKPopupPresentationStyleSlideInFromTop,
    ZKPopupPresentationStyleSlideInFromBottom,
    ZKPopupPresentationStyleSlideInFromLeft,
    ZKPopupPresentationStyleSlideInFromRight
};

// ZKPopupMaskType
typedef NS_ENUM(NSInteger, ZKPopupMaskType) {
    ZKPopupMaskTypeClear,
    ZKPopupMaskTypeDimmed,
    ZKPopupMaskTypeCustom
};

@interface ZKPopupTheme : NSObject

@property (nonatomic, strong) UIColor *backgroundColor; // Background color of the popup content view (Default white)
@property (nonatomic, strong) UIColor *customMaskColor; // Custom color for ZKPopupMaskTypeCustom
@property (nonatomic, assign) CGFloat cornerRadius; // Corner radius of the popup content view (Default 4.0)
@property (nonatomic, assign) UIEdgeInsets popupContentInsets; // Inset of labels, images and buttons on the popup content view (Default 16.0 on all sides)
@property (nonatomic, assign) ZKPopupStyle popupStyle; // How the popup looks once presented (Default centered)
@property (nonatomic, assign) ZKPopupPresentationStyle presentationStyle; // How the popup is presented (Defauly slide in from bottom. NOTE: Only applicable to ZKPopupStyleCentered)
@property (nonatomic, assign) ZKPopupMaskType maskType; // Backgound mask of the popup (Default dimmed)
@property (nonatomic, assign) BOOL dismissesOppositeDirection; // If presented from a direction, should it dismiss in the opposite? (Defaults to NO. i.e. Goes back the way it came in)
@property (nonatomic, assign) BOOL shouldDismissOnBackgroundTouch; // Popup should dismiss on tapping on background mask (Default yes)
@property (nonatomic, assign) BOOL movesAboveKeyboard; // Popup should move up when the keyboard appears (Default yes)
@property (nonatomic, assign) CGFloat blurEffectAlpha; // Alpha of the background blur effect (Default 0.0)
@property (nonatomic, assign) CGFloat contentVerticalPadding; // Spacing between each vertical element (Default 12.0)
@property (nonatomic, assign) CGFloat maxPopupWidth; // Maxiumum width that the popup should be (Default 300)
@property (nonatomic, assign) CGFloat animationDuration; // Duration of presentation animations (Default 0.3s)

// Factory method to help build a default theme
+ (ZKPopupTheme *)defaultTheme;

@end

NS_ASSUME_NONNULL_END
