//
//  ZKInitialsPlaceholderView.h
//  ZKFoundation
//
//  Created by Kaiser on 2019/4/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 A view that will facilitate the drawing of a placeholder
 image which contains the specified initials drawn over top
 of a circle.
 
 This behavior can be seen in iMessage (iOS7 7.0+ and greater)
 when you are in a group chat.
 */
@interface ZKInitialsPlaceholderView : UIView

/**
 Font to use for drawing
 
 @note The size doesn't matter as it is dynamically determined based on
 the frame of this view. The default is [UIFont boldSystemFontOfSize:16]
 */
@property (strong) UIFont *font;

/**
 Color to use when drawing initial text.
 
 @note This defaults to [UIColor whiteColor]
 */
@property (strong) UIColor *textColor;

/**
 Color to use when drawing the background circle.
 
 @note THis defaults to [UIColor lightGrayColor]
 */
@property (strong) UIColor *circleColor;

/**
 String of initials to draw over top of the circle.
 
 @note If there are more than 2 character supplied in this string
 it will be truncated to 2 characters
 */
@property (strong) NSString *initials;

/**
 The designated initializer (using another initializer will produce
 undefined results)
 */
- (instancetype)initWithDiameter:(CGFloat)diameter NS_DESIGNATED_INITIALIZER;

/**
 Performant ways to set all of your options without redrawing the view on
 EACH property set.  (i.e. this will save upto 3 draw calls if you set all 4 options)
 Safe to pass nil to the circleColor, textColor and font args.
 */
-(void)batchUpdateViewWithInitials:(NSString *)initials circleColor:(UIColor *)circleColor textColor:(UIColor *)textColor font:(UIFont *)font;

@end

NS_ASSUME_NONNULL_END
