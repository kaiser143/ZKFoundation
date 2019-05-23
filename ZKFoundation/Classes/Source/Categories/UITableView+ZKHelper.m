//
//  UITableView+Helper.m
//  FBSnapshotTestCase
//
//  Created by Kaiser on 2019/3/12.
//

#import "UITableView+ZKHelper.h"
#import "ZKTableViewHelper.h"
#import <objc/runtime.h>

@implementation UITableView (ZKHelper)

- (ZKTableViewHelper *)tableHelper {
    ZKTableViewHelper *tableHelper = objc_getAssociatedObject(self, _cmd);
    if (tableHelper) return tableHelper;
    
    tableHelper = ZKTableViewHelper.new;
    tableHelper.kai_tableView = self;
    self.dataSource = tableHelper;
    self.delegate = tableHelper;
    objc_setAssociatedObject(self, _cmd, tableHelper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return tableHelper;
}

@end
