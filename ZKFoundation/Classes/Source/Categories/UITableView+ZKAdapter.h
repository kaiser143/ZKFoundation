//
//  UITableView+Helper.h
//  ZKFoundation
//
//  Created by Kaiser on 2019/3/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ZKTableViewAdapter;

@interface UITableView (ZKAdapter)

@property (nonatomic, strong, readonly) ZKTableViewAdapter *adapter;

@end

NS_ASSUME_NONNULL_END
