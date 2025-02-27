//
//  ZKBlurEffectViewController.m
//  ZKFoundation_Example
//
//  Created by Kaiser on 2025/2/27.
//  Copyright © 2025 zhangkai. All rights reserved.
//

#import "ZKBlurEffectViewController.h"
#import <ZKCategories/ZKCategories.h>
#import <Masonry/Masonry.h>

@interface ZKBlurEffectViewController ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIVisualEffectView *effectView;

@property(nonatomic, strong) UILabel *label1;
@property(nonatomic, strong) UISlider *slider1;

@end

@implementation ZKBlurEffectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = UIColor.whiteColor;
    
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.effectView];
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ZKScreenSize().width - 2*24, 120));
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(140);
    }];
    [self.effectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.imageView);
    }];
    
    [self.view addSubview:self.label1];
    [self.view addSubview:self.slider1];
    
    [self.label1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imageView.mas_bottom).offset(100);
        make.left.equalTo(self.imageView);
        make.height.mas_equalTo(20);
    }];
    
    [self.slider1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.label1.mas_bottom).offset(30);
        make.left.width.equalTo(self.imageView);
    }];
    
    @weakify(self);
    [self.slider1 addBlockForControlEvents:UIControlEventValueChanged block:^(__kindof UISlider * _Nonnull slider) {
        @strongify(self);
        CGFloat radius = slider.value;
        self.effectView.effect = [UIBlurEffect kai_effectWithBlurRadius:radius];
        self.label1.text = [NSString stringWithFormat:@"1. 支持精确指定模糊半径(当前%.2f)", radius];
    }];
    
    [self.slider1 sendActionsForControlEvents:UIControlEventValueChanged];
}

#pragma mark - :. getters and setters

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"image4"]];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}

- (UIVisualEffectView *)effectView {
    if (!_effectView) {
        _effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect kai_effectWithBlurRadius:5]];
    }
    return _effectView;
}

- (UILabel *)label1 {
    if (!_label1) {
        _label1 = [[UILabel alloc] init];
        _label1.font = [UIFont systemFontOfSize:14];
        _label1.textColor = [UIColor darkGrayColor];
        _label1.numberOfLines = 0;
        _label1.kai_lineHeight = 20;
    }
    return _label1;
}

- (UISlider *)slider1 {
    if (!_slider1) {
        _slider1 = [[UISlider alloc] init];
        _slider1.maximumTrackTintColor = UIColor.blueColor;
        _slider1.minimumTrackTintColor = UIColor.blueColor;
        _slider1.minimumValue = 0;
        _slider1.maximumValue = 40;
        _slider1.value = 5;
    }
    return _slider1;
}

@end
