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

@interface ZKViewController ()

@end

@implementation ZKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    ZKButton *button = [ZKButton buttonWithType:UIButtonTypeCustom];
    button.style = ZKButtonStyleImageAtBottom;
    [button setImage:[UIImage imageNamed:@"arrow_l"] forState:UIControlStateNormal];
    [button setTitle:@"去开启" forState:UIControlStateNormal];
    [button setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:12];
    button.layer.cornerRadius = 3.f;
    button.layer.masksToBounds = YES;
    button.layer.borderColor = UIColor.redColor.CGColor;
    button.layer.borderWidth = 1.f;
    [self.view addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
