//
//  UITableView+Helper.m
//  ZKFoundation
//
//  Created by Kaiser on 2019/3/12.
//

#import "UITableView+ZKAdapter.h"
#import "ZKTableViewAdapter.h"
#import <objc/runtime.h>

@implementation UITableView (ZKAdapter)

- (ZKTableViewAdapter *)tableHelper {
    ZKTableViewAdapter *tableHelper = objc_getAssociatedObject(self, _cmd);
    if (tableHelper) return tableHelper;
    
    tableHelper = ZKTableViewAdapter.new;
    tableHelper.kai_tableView = self;
    self.dataSource = tableHelper;
    self.delegate = tableHelper;
    objc_setAssociatedObject(self, _cmd, tableHelper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return tableHelper;
}

@end
