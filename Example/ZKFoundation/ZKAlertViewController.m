//
//  ZKAlertViewController.m
//  ZKFoundation_Example
//
//  Created by zhangkai on 2025/2/28.
//  Copyright © 2025 zhangkai. All rights reserved.
//

#import "ZKAlertViewController.h"
#import <ZKCategories/ZKCategories.h>
#import <ZKFoundation/ZKFoundation.h>

@interface ZKAlertViewController ()

@end

@implementation ZKAlertViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:UITableViewCell.className];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0: {
            ZKAlert *actionSheet = [[ZKAlert alloc] initWithCancelButtonTitle:@"取消"];
            
            // 创建“发送给朋友”动作
            ZKAlertAction *sendToFriendAction = [[ZKAlertAction alloc] initWithTitle:@"发送给朋友" handler:^(ZKAlert * _Nonnull alert) {
                // 处理“发送给朋友”动作的代码
            } style:ZKAlertActionStyleDefault];
            [actionSheet addAction:sendToFriendAction];
            
            // 创建“收藏”动作
            ZKAlertAction *collectAction = [[ZKAlertAction alloc] initWithTitle:@"收藏" handler:^(ZKAlert * _Nonnull alert) {
                // 处理“收藏”动作的代码
            } style:ZKAlertActionStyleDefault];
            [actionSheet addAction:collectAction];
            
            // 创建“保存图片”动作
            ZKAlertAction *saveImageAction = [[ZKAlertAction alloc] initWithTitle:@"保存图片" handler:^(ZKAlert * _Nonnull alert) {
                // 处理“保存图片”动作的代码
            } style:ZKAlertActionStyleDefault];
            [actionSheet addAction:saveImageAction];
            
            // 创建“删除”动作，样式为破坏性动作
            ZKAlertAction *deleteAction = [[ZKAlertAction alloc] initWithTitle:@"删除" handler:^(ZKAlert * _Nonnull alert) {
                // 处理“删除”动作的代码
            } style:ZKAlertActionStyleDestructive];
            [actionSheet addAction:deleteAction];
            
            // 展示动作表
            [actionSheet present];
        }
            break;
        case 1: {
            // 创建 ZKAlert 实例并设置取消按钮标题
            ZKAlert *actionSheet = [[ZKAlert alloc] initWithCancelButtonTitle:@"取消"];
            
            // 设置动作表的样式为暗色样式
            actionSheet.style = [ZKAlertStyle styleWithType:ZKAlertStyleTypeDark];
            
            // 创建“发送给朋友”动作
            ZKAlertAction *sendToFriendAction = [[ZKAlertAction alloc] initWithTitle:@"发送给朋友" handler:^(ZKAlert * _Nonnull alert) {
                // 这里可以添加点击“发送给朋友”后的处理逻辑
            } style:ZKAlertActionStyleDefault];
            [actionSheet addAction:sendToFriendAction];
            
            // 创建“收藏”动作
            ZKAlertAction *collectAction = [[ZKAlertAction alloc] initWithTitle:@"收藏" handler:^(ZKAlert * _Nonnull alert) {
                // 这里可以添加点击“收藏”后的处理逻辑
            } style:ZKAlertActionStyleDefault];
            [actionSheet addAction:collectAction];
            
            // 创建“保存图片”动作
            ZKAlertAction *saveImageAction = [[ZKAlertAction alloc] initWithTitle:@"保存图片" handler:^(ZKAlert * _Nonnull alert) {
                // 这里可以添加点击“保存图片”后的处理逻辑
            } style:ZKAlertActionStyleDefault];
            [actionSheet addAction:saveImageAction];
            
            // 创建“删除”动作，样式为破坏性动作
            ZKAlertAction *deleteAction = [[ZKAlertAction alloc] initWithTitle:@"删除" handler:^(ZKAlert * _Nonnull alert) {
                // 这里可以添加点击“删除”后的处理逻辑
            } style:ZKAlertActionStyleDestructive];
            [actionSheet addAction:deleteAction];
            
            // 展示动作表
            [actionSheet present];
        }
            break;
        case 2: {
            // 创建 ZKAlert 实例并设置取消按钮标题
            ZKAlert *actionSheet = [[ZKAlert alloc] initWithCancelButtonTitle:nil];
            
            // 创建“只看女生”动作
            ZKAlertAction *onlyGirlsAction = [[ZKAlertAction alloc] initWithTitle:@"只看女生" handler:^(ZKAlert * _Nonnull alert) {
                // 这里可以添加点击“只看女生”后的处理逻辑
            } style:ZKAlertActionStyleDefault];
            [actionSheet addAction:onlyGirlsAction];
            
            // 创建“只看男生”动作
            ZKAlertAction *onlyBoysAction = [[ZKAlertAction alloc] initWithTitle:@"只看男生" handler:^(ZKAlert * _Nonnull alert) {
                // 这里可以添加点击“只看男生”后的处理逻辑
            } style:ZKAlertActionStyleDefault];
            [actionSheet addAction:onlyBoysAction];
            
            // 创建“查看全部”动作
            ZKAlertAction *viewAllAction = [[ZKAlertAction alloc] initWithTitle:@"查看全部" handler:^(ZKAlert * _Nonnull alert) {
                // 这里可以添加点击“查看全部”后的处理逻辑
            } style:ZKAlertActionStyleDefault];
            [actionSheet addAction:viewAllAction];
            
            // 展示动作表
            [actionSheet present];
        }
            break;
        case 3: {
            // 创建标题视图
            UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 50)];
            
            // 创建标题标签
            UILabel *titleLabel = [[UILabel alloc] init];
            titleLabel.font = [UIFont systemFontOfSize:13];
            titleLabel.textColor = [UIColor grayColor];
            titleLabel.text = @"清除位置信息后，别人将不能查看到你";
            
            // 将标题标签添加到标题视图
            [titleView addSubview:titleLabel];
            
            // 禁用自动布局约束转换
            titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
            
            // 添加约束使标题标签居中
            [titleLabel.centerXAnchor constraintEqualToAnchor:titleView.centerXAnchor].active = YES;
            [titleLabel.centerYAnchor constraintEqualToAnchor:titleView.centerYAnchor].active = YES;
            
            // 创建 ZKAlert 实例并设置取消按钮标题
            ZKAlert *actionSheet = [[ZKAlert alloc] initWithCancelButtonTitle:@"取消"];
            
            // 设置标题视图
            actionSheet.titleView = titleView;
            
            // 创建“清除位置并退出”动作，样式为破坏性动作
            ZKAlertAction *clearLocationAction = [[ZKAlertAction alloc] initWithTitle:@"清除位置并退出" handler:^(ZKAlert * _Nonnull alert) {
                // 这里可以添加点击“清除位置并退出”后的处理逻辑
            } style:ZKAlertActionStyleDestructive];
            [actionSheet addAction:clearLocationAction];
            
            // 展示动作表
            [actionSheet present];
        }
            break;
            
        default:
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:UITableViewCell.className forIndexPath:indexPath];
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"默认样式";
            cell.detailTextLabel.text = @"Default Style";
            break;
        case 1:
            cell.textLabel.text = @"暗黑样式";
            cell.detailTextLabel.text = @"Dark Style";
            break;
        case 2:
            cell.textLabel.text = @"不显示取消按钮";
            cell.detailTextLabel.text = @"Without cancel button";
            break;
        case 3:
            cell.textLabel.text = @"自定义标题";
            cell.detailTextLabel.text = @"Custom titleView";
            break;
            
        default:
            break;
    }
    return cell;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
