//
//  UITableView+Helper.h
//  FBSnapshotTestCase
//
//  Created by Kaiser on 2019/3/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ZKTableViewHelper;

@interface UITableView (Helper)

@property (nonatomic, strong, readonly) ZKTableViewHelper *tableHelper;

- (void)extraCellLineHidden;

@end

NS_ASSUME_NONNULL_END
