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
    ZKTableViewHelper *curTableHelper = objc_getAssociatedObject(self, _cmd);
    if (curTableHelper) return curTableHelper;
    
    curTableHelper = ZKTableViewHelper.new;
    curTableHelper.kai_tableView = self;
    self.dataSource = curTableHelper;
    self.delegate = curTableHelper;
    objc_setAssociatedObject(self, _cmd, curTableHelper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return curTableHelper;
}

@end
