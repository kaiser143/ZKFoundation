//
//  UIView+ZKBadge.h
//  ZKFoundation
//
//  Created by Kaiser on 2026/6/16.
//

#import <UIKit/UIKit.h>
#import "ZKBadgeProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/**
 在任意 UIView 上显示未读红点或未读数。
 
 @note 使用该组件会强制设置 view.clipsToBounds = NO，以避免布局到 view 外部的红点/未读数被裁剪。
 @note 未主动设置样式时，会在首次展示时应用一组合理默认值（红底白字、bold 11、红点 7pt 等）。
 */
@interface UIView (ZKBadge) <ZKBadgeProtocol>

@end

NS_ASSUME_NONNULL_END
