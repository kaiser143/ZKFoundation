//
//  ZKButton.h
//  ZKFoundation
//
//  Created by Kaiser on 2019/3/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ZKButtonStyle) {
    ZKButtonStyleImageAtTop,
    ZKButtonStyleImageAtLeft,
    ZKButtonStyleImageAtRight,
    ZKButtonStyleImageAtBottom
};

@interface ZKButton : UIButton

@property (nonatomic, assign) ZKButtonStyle style;

/// 图片和文字的间距
@property (nonatomic, assign) CGFloat spacingBetweenImageAndTitle;

@end

NS_ASSUME_NONNULL_END
