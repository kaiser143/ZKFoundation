//
//  UITableViewCell+Helper.h
//  FBSnapshotTestCase
//
//  Created by Kaiser on 2019/3/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ZKTableHelperProtocol <NSObject>
@optional

- (void)kai_cellWillDisplayWithModel:(id)cModel;

@end

@interface UITableViewCell (ZKHelper) <ZKTableHelperProtocol>

@end

NS_ASSUME_NONNULL_END
