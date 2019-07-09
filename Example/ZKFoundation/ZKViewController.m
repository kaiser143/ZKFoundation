//
//  ZKViewController.m
//  ZKFoundation
//
//  Created by zhangkai on 03/08/2019.
//  Copyright (c) 2019 zhangkai. All rights reserved.
//

#import "ZKViewController.h"
#import <Masonry/Masonry.h>
#import <ZKButton.h>
#import <ZKTintedActionButton.h>
#import <ZKPermission.h>

@interface ZKViewController ()

@end

@implementation ZKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    UIView *view = UIView.new;
    [self.view addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
    }];
    
    UIButton *normal = [UIButton buttonWithType:UIButtonTypeCustom];
    [normal setImage:[UIImage imageNamed:@"arrow_l"] forState:UIControlStateNormal];
    [normal setTitle:@"去开启" forState:UIControlStateNormal];
    [normal setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    normal.titleLabel.font = [UIFont systemFontOfSize:12];
    normal.layer.cornerRadius = 3.f;
    normal.layer.masksToBounds = YES;
    normal.layer.borderColor = UIColor.redColor.CGColor;
    normal.layer.borderWidth = 1.f;
    [view addSubview:normal];
    [normal mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.lessThanOrEqualTo(view);
        make.left.centerY.equalTo(view);
        make.size.mas_equalTo(CGSizeMake(100, 200));
    }];
    
    ZKButton *button = [ZKButton buttonWithType:UIButtonTypeCustom];
    button.style = ZKButtonStyleImageAtLeft;
    [button setImage:[UIImage imageNamed:@"arrow_l"] forState:UIControlStateNormal];
    [button setTitle:@"去开启" forState:UIControlStateNormal];
    [button setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:12];
    button.layer.cornerRadius = 3.f;
    button.layer.masksToBounds = YES;
    button.layer.borderColor = UIColor.redColor.CGColor;
    button.layer.borderWidth = 1.f;
    [view addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(normal.mas_right).offset(20);
        make.right.centerY.equalTo(view);
        make.height.lessThanOrEqualTo(view);
        make.size.mas_equalTo(CGSizeMake(100, 200));
    }];
    
    ZKTintedActionButton *action = [ZKTintedActionButton buttonWithType:UIButtonTypeCustom];
    action.tintColor = UIColor.redColor;
    action.layer.cornerRadius = 8;
    action.clipsToBounds = YES;
    [action setTitle:@"Continue" forState:UIControlStateNormal];
    [action addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:action];
    [action mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(220);
        make.height.mas_equalTo(48);
        make.centerX.equalTo(self.view);
        make.top.equalTo(view.mas_bottom).offset(30);
    }];
}

- (void)buttonTapped:(UIButton *)sender {
    [ZKPermission.manager requestWithType:ZKPermissionTypeContact
                                 callback:^(BOOL response, ZKPermissionAuthorizationStatus status) {
                                     if (response) {
                                         UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                                                        message:@"获取权限成功"
                                                                                                 preferredStyle:UIAlertControllerStyleAlert];
                                         UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK"
                                                                                          style:UIAlertActionStyleDefault
                                                                                        handler:^(UIAlertAction * _Nonnull action) {
                                                                                            
                                                                                        }];
                                         [alert addAction:action];
                                         [self presentViewController:alert animated:YES completion:nil];
                                     }
                                 }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
