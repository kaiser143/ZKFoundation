//
//  ZKTableViewController.m
//  ZKFoundation_Example
//
//  Created by zhangkai on 2020/2/19.
//  Copyright © 2020 zhangkai. All rights reserved.
//

#import "ZKTableViewController.h"
#import <Masonry/Masonry.h>
#import <ZKFoundation/ZKFoundation.h>
#import <ZKCategories/ZKCategories.h>

@interface ZKTableViewController () <ZKNavigationBarConfigureStyle>

@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) UIBarButtonItem *rightButton;

@end

@implementation ZKTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = YES;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    @weakify(self);
    self.title = @"文件管理";
    self.dataSource = @[@"图片", @"视频",@"文档",@"音频",@"压缩文件",@"其他",@"TableViewDemo.zip"].mutableCopy;
    [self.dataSource addObjectsFromArray:self.dataSource];
    self.rightButton = [[UIBarButtonItem alloc] initWithTitle:@"选择" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.rightButton.actionBlock = ^(UIBarButtonItem *sender) {
        @strongify(self);
        NSString *strings = sender.title;
        if ([strings isEqualToString:@"选择"]) {
            self.tableView.adapter.allowsMultipleSelectionDuringEditing = YES;
            sender.title = @"完成";
        } else {
            self.tableView.adapter.allowsMultipleSelectionDuringEditing = NO;
            sender.title = @"选择";
            NSLog(@"%@", self.tableView.adapter.modelsForSelectedRows);
        }
    };
    self.navigationItem.rightBarButtonItem = self.rightButton;
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.tableView.adapter registerNibs:@[@"ZKTableViewCell"]];
    [self.tableView.adapter cellWillDisplay:^(__kindof UITableViewCell * _Nonnull cell, NSIndexPath * _Nonnull indexPath, NSString *dataSource, BOOL IsCelldisplay) {
        @strongify(self);
        cell.textLabel.text = dataSource;
        if (indexPath.row == self.dataSource.count - 1) {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%u MB",arc4random()%20];
            cell.accessoryType = UITableViewCellAccessoryDetailButton;
            cell.imageView.image = [UIImage imageNamed:@"file_zipped"];
        } else {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%u项",arc4random()%20];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.imageView.image = [UIImage imageNamed:@"file_folder"];
        }
    }];
    [self.tableView.adapter didSelectRow:^(UITableView * _Nonnull tableView, NSIndexPath * _Nonnull indexPath, id  _Nonnull dataSource) {
        @strongify(self);
        if ([self.rightButton.title isEqualToString:@"完成"]) {
//               [self.selectedArr addObject:self.dataArr[indexPath.row]];
           } else if ([self.rightButton.title isEqualToString:@"选择"]){
               [tableView deselectRowAtIndexPath:indexPath animated:YES];
           }
    }];
    [self.tableView.adapter accessoryButtonTappedForRow:^(NSIndexPath * _Nonnull indexPath, id  _Nonnull dataSource) {
        NSLog(@"accessoryButtonTapped %@", indexPath);
    }];
    [self.tableView.adapter didDeselect:^(UITableView * _Nonnull tableView, NSIndexPath * _Nonnull indexPath, id  _Nonnull dataSource) {
        
    }];
    [self.tableView.adapter editActionsForRow:^NSArray<UITableViewRowAction *> * _Nullable(UITableView * _Nonnull tableView, NSIndexPath * _Nonnull indexPath, id  _Nonnull dataSource) {
        UITableViewRowAction *delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal
                                                                              title:@"备注"
                                                                            handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
                                                                                NSLog(@"点击了备注按钮");
                                                                            }];
            return @[delete];
    }];
    [self.tableView.adapter canEditRow:^BOOL(id  _Nonnull dataSource, NSIndexPath * _Nonnull indexPath) {
        return YES;
    }];
    [self.tableView.adapter stripAdapterData:self.dataSource];
    
}

#pragma mark - :. ZKNavigationBarConfigureStyle

- (ZKNavigationBarConfigurations)kai_navigtionBarConfiguration {
    return  ZKNavigationBarBackgroundStyleColor | ZKNavigationBarBackgroundStyleOpaque | ZKNavigationBarShowShadowImage;
}

- (UIColor *)kai_tintColor {
    return UIBarButtonItem.appearance.tintColor;
}

- (UIColor *)kai_barTintColor {
    return UIColor.whiteColor;
}

- (BOOL)kai_prefersNavigationBarHidden {
    return NO;
}

#pragma mark - :. getters and setters

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.rowHeight = 60;
    }
    
    return _tableView;
}

@end
