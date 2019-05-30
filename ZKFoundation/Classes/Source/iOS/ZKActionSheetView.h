//
//  ZKActionSheetView.h
//  Masonry
//
//  Created by Kaiser on 2019/5/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZKActionItem : NSObject

@property (nonatomic, strong, readonly) NSString *icon;
@property (nonatomic, strong, readonly) NSString *title;

+ (instancetype)actionWithTitle:(nullable NSString *)title icon:(NSString *)icon handler:(void (^ __nullable)(ZKActionItem *action))handler;

@end

@interface ZKActionSheetView : UIView

/** 顶部标题Label, 默认内容为"分享" */
@property (nonatomic, readonly) UILabel *titleLabel;

/** 底部取消Button, 默认标题为"取消" */
@property (nonatomic, readonly) UIButton *cancelButton;

/**
 *  创建常规shareView
 *
 *  @param shareArray    分享item数组 (元素须为`ZKActionItem`)
 *  @param functionArray 功能item数组 (元素须为`ZKActionItem`)
 */
+ (instancetype)actionSheetViewWithShareItems:(NSArray<ZKActionItem *> *)shareArray
                                functionItems:(NSArray<ZKActionItem *> *)functionArray;
- (instancetype)initWithShareItems:(NSArray<ZKActionItem *> *)shareArray
                     functionItems:(NSArray<ZKActionItem *> *)functionArray;

/**
 *  创建具有n行的shareView
 *
 *  @param array 二维数组 (eg: @[shareArray, functionArray, otherItemsArray, ...])
 */
- (instancetype)initWithItemsArray:(NSArray *)array;

/**
 *  显示\隐藏
 */
- (void)show;
- (void)hide;

@end

NS_ASSUME_NONNULL_END
