//
//  ZKTagsControl.h
//  ZKTagsControl
//
//  Created by zhangkai on 2019/5/24.
//  Copyright © 2019 zhangkai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ZKTagsControl;
@class ZKTagItem;

@protocol ZKTagsControllerDelegate <NSObject>
@required
- (CGFloat)tagsControl:(ZKTagsControl *)tagsControl widthForItemAtIndex:(NSInteger)index;
@optional
- (void)tagsControl:(ZKTagsControl *)tagsControl didRemoveWithItem:(ZKTagItem *)item;
- (void)tagsControl:(ZKTagsControl *)tagsControl inputValueChanged:(NSString *)value;
- (BOOL)tagsControlShouldReturn:(ZKTagsControl *)tagsControl;
@end

@interface ZKTagItem : NSObject
@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic, strong, readonly) id value;

+ (instancetype)itemWithTitle:(NSString *)title value:(nullable id)value;

@end

@interface ZKTagsControl : UIView

@property (nonatomic, strong) NSMutableArray<ZKTagItem *> *tags;
@property (nonatomic, assign) UIEdgeInsets safeArea;
@property (nonatomic, assign) CGFloat preferredMinFieldWidth; // default 100
@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic, assign, readonly) BOOL active;
@property (nonatomic, assign) BOOL prefersHighlightBeforeDelete; // default YES
@property (nonatomic, strong) UIImage *inputLeftImage;

@property (nonatomic, weak) id<ZKTagsControllerDelegate> delegate;

- (void)registerClass:(nullable Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier;
- (void)addTags:(NSArray<ZKTagItem *> *)tags;
- (void)addTag:(ZKTagItem *)tag;
- (void)removeTagAtIndexPath:(NSIndexPath *)indexPath;
- (void)removeAll;

@end

NS_ASSUME_NONNULL_END
