//
//  UITableView+Helper.h
//  ZKFoundation
//
//  Created by Kaiser on 2019/3/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ZKTableViewHelper;

@interface UITableView (ZKHelper)

@property (nonatomic, strong, readonly) ZKTableViewHelper *tableHelper;

@end

NS_ASSUME_NONNULL_END
