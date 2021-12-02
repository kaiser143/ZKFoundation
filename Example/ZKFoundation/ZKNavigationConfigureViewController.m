//
//  ZKNavigationConfigureViewController.m
//  ZKFoundation_Example
//
//  Created by zhangkai on 2021/7/28.
//  Copyright © 2021 zhangkai. All rights reserved.
//

#import "ZKNavigationConfigureViewController.h"
#import <Masonry/Masonry.h>
#import <ZKFoundation/ZKFoundation.h>
#import <ZKCategories/ZKCategories.h>
#import "ZKTableViewSwitchCell.h"
#import "ZKSwitchItemViewModel.h"

@interface ZKNavigationConfigureViewController () <ZKNavigationBarConfigureStyle>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) BOOL barHidden;
@property (nonatomic, assign) BOOL transparent;
@property (nonatomic, assign) BOOL translucent;
@property (nonatomic, assign) BOOL shadowImage;
@property (nonatomic, assign) UIBarStyle barStyle;
@property (nonatomic, strong) NSArray<ZKSwitchItemViewModel *> *styles;
@property (nonatomic, strong) NSArray<NSDictionary *> *colors;
@property (nonatomic, strong) NSArray<NSString *> *imageNames;

@property (nonatomic, strong) NSDictionary<NSString *, NSInvocation *> *eventStrategy;

@end

@implementation ZKNavigationConfigureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    self.translucent = NO;
    self.barStyle = UIBarStyleBlack;
    self.title = self.title.isNotBlank ? self.title : @"NavigationBarTransition";
        
    @weakify(self);
    [self.tableView.adapter registerNibs:@[ZKTableViewSwitchCell.className, UITableViewCell.className]];
    [self.tableView.adapter headerTitle:^NSString * _Nullable(UITableView * _Nonnull tableView, NSInteger section) {
        if (section == 0) return @"Next Controller Bar Style";
        else if (section == 1) return @"Colors";
        else if (section == 2) return @"Images";
        else return nil;
    }];
    [self.tableView.adapter heightForHeaderView:^CGFloat(UITableView * _Nonnull tableView, NSInteger section, id  _Nonnull dataSource) {
        return UITableViewAutomaticDimension;
    }];
    [self.tableView.adapter footerTitle:^NSString * _Nullable(UITableView * _Nonnull tableView, NSInteger section) {
        if (section == 0) {
            return
            @"bar style 会影响状态栏的样式\n"
            "bar style 是 UIBarStyleBlack 的时候状态栏为白色\n"
            "bar style 是 UIBarStyleDefault 的时候状态栏为黑色";
        } else if (section == 1) {
            return @"选择偏白的颜色的时候，关闭 Black Bar Style 展示效果更好";
        } else if (section == 2) {
            return @"选择图片为背景的时候建议关掉半透明效果";
        } else if (section == 3) {
            return @"style 根据页面滑动距离动态改变";
        }
        
        return nil;
    }];
    [self.tableView.adapter heightForFooterView:^CGFloat(UITableView * _Nonnull tableView, NSInteger section, id  _Nonnull dataSource) {
        return UITableViewAutomaticDimension;
    }];
    [self.tableView.adapter cellIdentifierForRowAtIndexPath:^NSString * _Nullable(NSIndexPath * _Nonnull indexPath, id  _Nonnull dataSource) {
        if (indexPath.section == 0) return ZKTableViewSwitchCell.className;
        
        return UITableViewCell.className;
    }];
    [self.tableView.adapter cellWillDisplay:^(__kindof UITableViewCell * _Nonnull cell, NSIndexPath * _Nonnull indexPath, id  _Nonnull dataSource, BOOL isCellDisplay) {
        @strongify(self);
        if (indexPath.section == 1) {
            NSDictionary *color = self.colors[indexPath.row];
            cell.textLabel.text = color.allKeys.firstObject;
            id value = color.allValues.firstObject;
            if (value == NSNull.null) value = UIColor.clearColor;
            
            cell.imageView.image = [UIImage imageWithColor:value size:CGSizeMake(32, 32)];
        } else if (indexPath.section == 2) {
            NSString *imageName = [self.imageNames objectOrNilAtIndex:indexPath.row];
            cell.textLabel.text = dataSource;
            cell.imageView.image = [UIImage imageNamed:imageName];
        }
        
        if (indexPath.section != 0) cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }];
    [self.tableView.adapter didSelectRow:^(UITableView * _Nonnull tableView, NSIndexPath * _Nonnull indexPath, id  _Nonnull dataSource) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        @strongify(self);
        if (indexPath.section == 1) {
            id color = self.colors[indexPath.row].allValues.firstObject;
            if (color == [NSNull null]) color = nil;
            
            ZKNavigationConfigureViewController *controller = ZKNavigationConfigureViewController.new;
            controller.title = @"Color";
            
            ZKSwitchItemViewModel *item = [self.styles objectOrNilAtIndex:0];
            controller.barHidden = item.on;
            
            ZKNavigationBarConfigurations conf = ZKNavigationBarConfigurationsDefault;
            BOOL transparent = [[self.styles objectOrNilAtIndex:1] on];
            BOOL translucent = [[self.styles objectOrNilAtIndex:2] on];
            if (transparent) {
                conf |= ZKNavigationBarBackgroundStyleTransparent;
            } else if (!translucent) {
                conf |= ZKNavigationBarBackgroundStyleOpaque;
            }
            
            if (self.barStyle == UIBarStyleBlack) {
                conf |= ZKNavigationBarStyleBlack;
            }
            
            if (self.shadowImage) {
                conf |= ZKNavigationBarShowShadowImage;
            }
            
            if (color) conf |= ZKNavigationBarBackgroundStyleColor;
            
            controller.configurations = conf;
            controller.backgroundColor = color;
            
            [self kai_pushViewController:controller];
        } else if (indexPath.section == 2) {
            NSString *imageName = [self.imageNames objectAtIndex:indexPath.row];
            ZKNavigationConfigureViewController *controller = ZKNavigationConfigureViewController.new;
            controller.title = imageName;
            
            ZKNavigationBarConfigurations conf = ZKNavigationBarConfigurationsDefault;
            BOOL transparent = [[self.styles objectOrNilAtIndex:1] on];
            BOOL translucent = [[self.styles objectOrNilAtIndex:2] on];
            if (transparent) {
                conf |= ZKNavigationBarBackgroundStyleTransparent;
            } else if (!translucent) {
                conf |= ZKNavigationBarBackgroundStyleOpaque;
            }
            
            if (self.barStyle == UIBarStyleBlack) {
                conf |= ZKNavigationBarStyleBlack;
            }
            
            if (self.shadowImage) {
                conf |= ZKNavigationBarShowShadowImage;
            }
            
            conf |= ZKNavigationBarBackgroundStyleImage;
            
            controller.configurations = conf;
            controller.backgroundImage = [[UIImage imageNamed:imageName] resizableImageWithCapInsets:UIEdgeInsetsZero
                                                                                        resizingMode:UIImageResizingModeStretch];
            controller.backgroundImageName = imageName;
            
            [self.navigationController pushViewController:controller animated:YES];
        }
    }];
    [self.tableView.adapter stripAdapterGroupData:@[self.styles, self.colors, self.imageNames]];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - :. ZKNavigationBarConfigureStyle

- (ZKNavigationBarConfigurations)kai_navigtionBarConfiguration {
    return self.configurations;
}

- (UIColor *)kai_tintColor {
    return self.tintColor;
}

- (UIImage *)kai_navigationBackgroundImageWithIdentifier:(NSString **)identifier {
    if (identifier) *identifier = _backgroundImageName;
    return _backgroundImage;
}

- (UIColor *)kai_barTintColor {
    return self.backgroundColor;
}

- (BOOL)kai_prefersNavigationBarHidden {
    return self.barHidden;
}

#pragma mark - :. private methods

- (void)valueChanged:(NSDictionary *)info {
    NSIndexPath *indexPath = [info valueForKey:@"index"];
    NSNumber *value = [info valueForKey:@"value"];
    
    ZKSwitchItemViewModel *item = [self.styles objectAtIndex:indexPath.row];
    item.on = value.boolValue;
    
    switch (indexPath.row) {
        case 0: {
            self.transparent = value.boolValue;
            if (value.boolValue && _barStyle != UIBarStyleDefault) {
                // 为了更好的 demo 展示效果
                // bar 全透明之后把 barStyle 设置成 UIBarStyleDefault
                self.barStyle = UIBarStyleDefault;
                item = [self.styles objectAtIndex:2];
                item.on = NO;
                [self.tableView reloadData];
            }
        }
            break;
        case 1:
            self.translucent = value.boolValue;
            break;
        case 2:
            self.barStyle = value.boolValue ? UIBarStyleBlack : UIBarStyleDefault;
            break;
        default:
            self.shadowImage = value.boolValue;
            break;
    }
}

- (BOOL)responderDidReceiveEvent:(nonnull NSString *)eventName userInfo:(nullable id)userInfo {
    NSInvocation *invocation = self.eventStrategy[eventName];
    [invocation setArgument:&userInfo atIndex:2];
    [invocation invokeWithTarget:self];
    return NO;
}

- (NSInvocation *)createInvocationWithSelector:(SEL)selector {
    NSMethodSignature *sig = [[self class] instanceMethodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
    [invocation setSelector:selector];
   
    return invocation;
}

#pragma mark - :. getters and setters

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.backgroundColor = UIColor.groupTableViewBackgroundColor;
    }
    
    return _tableView;
}

- (NSArray<ZKSwitchItemViewModel *> *)styles {
    if (!_styles) {
        _styles = @[
            [ZKSwitchItemViewModel itemWithTitle:@"Transparent" on:NO],
            [ZKSwitchItemViewModel itemWithTitle:@"Translucent" on:NO],
            [ZKSwitchItemViewModel itemWithTitle:@"Black Bar Style" on:_barStyle == UIBarStyleBlack],
            [ZKSwitchItemViewModel itemWithTitle:@"Shadow Image" on:NO],
        ];
    }
    return _styles;
}

- (NSArray<NSDictionary *> *)colors {
    if (!_colors) {
        _colors = @[
            @{@"None": [NSNull null]},
            @{@"Black": [UIColor blackColor]},
            @{@"White": [UIColor whiteColor]},
            @{@"TableView Background Color": _tableView.backgroundColor},
            @{@"Red": [UIColor redColor]}
        ];
    }
    return _colors;
}

- (NSArray<NSString *> *)imageNames {
    if (!_imageNames) {
        _imageNames = @[@"green",
                        @"blue",
                        @"purple",
                        @"red",
                        @"yellow"];
    }
    return _imageNames;
}

- (NSDictionary<NSString *, NSInvocation *> *)eventStrategy {
    if (_eventStrategy == nil) {
        _eventStrategy = @{
            @"valueChanged": [self createInvocationWithSelector:@selector(valueChanged:)],
        };
    }
    return _eventStrategy;
}

@end
