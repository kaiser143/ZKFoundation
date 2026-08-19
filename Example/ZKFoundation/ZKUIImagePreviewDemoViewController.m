//
//  ZKUIImagePreviewDemoViewController.m
//  ZKFoundation
//
//  Created by zhangkai on 2026/3/19.
//

#import "ZKUIImagePreviewDemoViewController.h"
#import <Masonry/Masonry.h>
#import <ZKCategories/ZKCategories.h>
#import <ZKFoundation/ZKFoundation.h>

@interface ZKUIImagePreviewDemoViewController () <ZKUIImagePreviewViewDelegate, ZKNavigationBarConfigureStyle>

@property (nonatomic, strong) ZKUIImagePreviewViewController *imagePreviewViewController;
@property (nonatomic, strong) NSArray<UIImage *> *images;
@property (nonatomic, strong) ZKFloatLayoutView *floatLayoutView;
@property (nonatomic, strong) UILabel *tipsLabel;

@end

@implementation ZKUIImagePreviewDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"ImagePreview";
    self.view.backgroundColor = UIColor.whiteColor;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    NSMutableArray<UIImage *> *images = [NSMutableArray array];
    NSArray<NSString *> *names = @[@"image2", @"image4", @"image3", @"green", @"purple", @"yellow", @"red"];
    for (NSString *name in names) {
        UIImage *image = [UIImage imageNamed:name];
        if (image) {
            [images addObject:image];
        }
    }
    // 兜底：资源不足时用纯色图补齐
    while (images.count < 6) {
        [images addObject:[UIImage imageWithColor:[UIColor randomColor] size:CGSizeMake(400, 400)]];
    }
    self.images = images.copy;
    
    self.floatLayoutView = [[ZKFloatLayoutView alloc] init];
    self.floatLayoutView.itemMargins = UIEdgeInsetsMake(1, 1, 0, 0);
    for (UIImage *image in self.images) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.imageView.contentMode = UIViewContentModeScaleAspectFill;
        button.clipsToBounds = YES;
        button.layer.cornerRadius = 4;
        [button setImage:image forState:UIControlStateNormal];
        [button addTarget:self action:@selector(handleImageButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
        [self.floatLayoutView addSubview:button];
    }
    [self.view addSubview:self.floatLayoutView];
    
    self.tipsLabel = [[UILabel alloc] init];
    self.tipsLabel.font = [UIFont systemFontOfSize:13];
    self.tipsLabel.textColor = [UIColor colorWithWhite:0.4 alpha:1];
    self.tipsLabel.textAlignment = NSTextAlignmentCenter;
    self.tipsLabel.numberOfLines = 0;
    self.tipsLabel.text = @"点击图片进入预览：可左右滑动、双击缩放、单击/下拉退出";
    [self.view addSubview:self.tipsLabel];
    
    [self.floatLayoutView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(24);
        make.left.equalTo(self.view).offset(24);
        make.right.equalTo(self.view).offset(-24);
    }];
    [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.floatLayoutView.mas_bottom).offset(16);
        make.left.right.equalTo(self.floatLayoutView);
    }];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat contentWidth = CGRectGetWidth(self.view.bounds) - 48;
    NSInteger column = 3;
    CGFloat spacing = UIEdgeInsetsGetHorizontalValue(self.floatLayoutView.itemMargins);
    CGFloat imageWidth = (contentWidth - (column - 1) * spacing) / column;
    self.floatLayoutView.minimumItemSize = CGSizeMake(imageWidth, imageWidth);
    self.floatLayoutView.maximumItemSize = self.floatLayoutView.minimumItemSize;
    
    CGSize fitting = [self.floatLayoutView sizeThatFits:CGSizeMake(contentWidth, CGFLOAT_MAX)];
    [self.floatLayoutView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(fitting.height);
    }];
}

- (void)handleImageButtonEvent:(UIButton *)button {
    if (!self.imagePreviewViewController) {
        self.imagePreviewViewController = [[ZKUIImagePreviewViewController alloc] init];
        self.imagePreviewViewController.presentingStyle = ZKUIImagePreviewViewControllerTransitioningStyleZoom;
        self.imagePreviewViewController.imagePreviewView.delegate = self;
    }
    
    NSInteger buttonIndex = [self.floatLayoutView.subviews indexOfObject:button];
    self.imagePreviewViewController.imagePreviewView.currentImageIndex = (NSUInteger)buttonIndex;
    self.imagePreviewViewController.sourceImageView = ^UIView * {
        return button;
    };
    
    [self presentViewController:self.imagePreviewViewController animated:YES completion:nil];
}

#pragma mark - ZKUIImagePreviewViewDelegate

- (NSUInteger)numberOfImagesInImagePreviewView:(ZKUIImagePreviewView *)imagePreviewView {
    return self.images.count;
}

- (void)imagePreviewView:(ZKUIImagePreviewView *)imagePreviewView renderZoomImageView:(ZKZoomImageView *)zoomImageView atIndex:(NSUInteger)index {
    zoomImageView.reusedIdentifier = @(index);
    
    // 模拟异步加载
    if (index == 2) {
        [zoomImageView showLoading];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if ([zoomImageView.reusedIdentifier isEqual:@(index)]) {
                [zoomImageView hideEmptyView];
                zoomImageView.image = self.images[index];
            }
        });
    } else {
        zoomImageView.image = self.images[index];
    }
}

- (ZKUIImagePreviewMediaType)imagePreviewView:(ZKUIImagePreviewView *)imagePreviewView assetTypeAtIndex:(NSUInteger)index {
    return ZKUIImagePreviewMediaTypeImage;
}

- (void)imagePreviewView:(ZKUIImagePreviewView *)imagePreviewView didScrollToIndex:(NSUInteger)index {
    __weak typeof(self) weakSelf = self;
    self.imagePreviewViewController.sourceImageView = ^UIView * {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (index < strongSelf.floatLayoutView.subviews.count) {
            return strongSelf.floatLayoutView.subviews[index];
        }
        return nil;
    };
    self.tipsLabel.text = [NSString stringWithFormat:@"当前浏览第 %@ / %@ 张", @(index + 1), @(self.images.count)];
}

- (void)singleTouchInZoomingImageView:(ZKZoomImageView *)zoomImageView location:(CGPoint)location {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - ZKNavigationBarConfigureStyle

- (ZKNavigationBarConfigurations)kai_navigtionBarConfiguration {
    return ZKNavigationBarConfigurationsDefault | ZKNavigationBarBackgroundStyleOpaque | ZKNavigationBarBackgroundStyleColor;
}

- (UIColor *)kai_navigationBarTintColor {
    return UIColor.whiteColor;
}

- (UIColor *)kai_navigationItemTintColor {
    return UIColor.blackColor;
}

@end
