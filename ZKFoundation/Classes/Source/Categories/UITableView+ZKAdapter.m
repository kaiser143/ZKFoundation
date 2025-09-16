//
//  UITableView+Helper.m
//  ZKFoundation
//
//  Created by Kaiser on 2019/3/12.
//

#import "UITableView+ZKAdapter.h"
#import "ZKTableViewAdapter.h"
#import <ZKCategories/ZKCategories.h>

@implementation UITableView (ZKAdapter)

- (ZKTableViewAdapter *)adapter {
    ZKTableViewAdapter<UITableViewDataSource, UITableViewDelegate> *tableHelper = [self associatedValueForKey:_cmd];
    if (tableHelper) return tableHelper;
    
    tableHelper = ZKTableViewAdapter.new;
    tableHelper.kai_tableView = self;
    self.dataSource = tableHelper;
    self.delegate = tableHelper;
    [self setAssociateValue:tableHelper withKey:_cmd];
    return tableHelper;
}

@end
