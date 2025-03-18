//
//  ZKAlert.m
//  AXIndicatorView
//
//  Created by zhangkai on 2025/2/27.
//

#import "ZKAlert.h"
#import <ZKCategories/ZKCategories.h>

@interface ZKAlert () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) NSMutableArray<ZKAlertAction *> *actions;
@property (nonatomic, copy) NSString * _Nullable cancelButtonTitle;

@end

@implementation ZKAlert

// 初始化方法，可传入取消按钮的标题
- (instancetype)initWithCancelButtonTitle:(NSString *)cancelButtonTitle {
    CGRect frame = [UIScreen mainScreen].bounds;
    self = [super initWithFrame:frame];
    if (self) {
        self.cancelButtonTitle = cancelButtonTitle;
        [self commonInit];
    }
    return self;
}

// 从 NSCoder 解码初始化
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

// 公共初始化方法，设置背景视图、内容视图和手势识别器
- (void)commonInit {
    self.roundTopCorners = YES;
    self.backgroundView = [[UIView alloc] initWithFrame:self.bounds];
    self.backgroundView.alpha = 0.0;
    [self addSubview:self.backgroundView];
    
    self.contentView = [[UIView alloc] init];
    [self addSubview:self.contentView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tapGesture.delegate = self;
    [self.backgroundView addGestureRecognizer:tapGesture];
    
    self.actions = [NSMutableArray array];
    
    // 根据 iOS 版本设置默认样式
    if (@available(iOS 13, *)) {
        self.style = [ZKAlertStyle styleWithType:ZKAlertStyleTypeSystem];
    } else {
        self.style = [ZKAlertStyle styleWithType:ZKAlertStyleTypeLight];
    }
}

// 显示弹窗
- (void)present {
    // 过滤出非键盘窗口并反转数组
    NSArray<UIWindow *> *windows = [UIApplication sharedApplication].windows;
    NSMutableArray<UIWindow *> *filteredWindows = [NSMutableArray array];
    for (UIWindow *window in windows) {
        if (![[NSString stringWithFormat:@"%@", [window classForCoder]] isEqualToString:@"UIRemoteKeyboardWindow"]) {
            [filteredWindows addObject:window];
        }
    }
    NSArray<UIWindow *> *reversedWindows = [[filteredWindows reverseObjectEnumerator] allObjects];
    
    // 找到主窗口
    UIWindow *keyWindow = nil;
    for (UIWindow *window in reversedWindows) {
        if (window.isKeyWindow) {
            keyWindow = window;
            break;
        }
    }
    if (!keyWindow) {
        return;
    }
    
    // 构建 UI 并执行动画
    [self buildUI];
    
    [UIView animateWithDuration:0.1 animations:^{
        [keyWindow addSubview:self];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            self.backgroundView.alpha = 1.0;
            CGFloat y = self.bounds.size.height - self.contentView.frame.size.height;
            self.contentView.frame = CGRectMake(0, y, self.contentView.frame.size.width, self.contentView.frame.size.height);
        }];
    }];
}

// 隐藏弹窗
- (void)dismiss {
    [UIView animateWithDuration:0.3 animations:^{
        self.backgroundView.alpha = 0.0;
        CGFloat y = [UIScreen mainScreen].bounds.size.height;
        self.contentView.frame = CGRectMake(0, y, self.contentView.frame.size.width, self.contentView.frame.size.height);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

// 添加动作
- (void)addAction:(ZKAlertAction *)action {
    [self.actions addObject:action];
}

// 处理背景视图的点击手势
- (void)handleTapGesture:(UITapGestureRecognizer *)gesture {
    CGPoint point = [gesture locationInView:self.backgroundView];
    if (!CGRectContainsPoint(self.contentView.frame, point)) {
        [self dismiss];
    }
}

// 构建弹窗的 UI
- (void)buildUI {
    CGFloat y = 0.0;
    CGFloat lineHeight = 1 / ZKScreenScale();
    
    // 设置标题视图
    if (self.titleView) {
        self.titleView.backgroundColor = [(ZKAlertStyleAppearance *)self.style.appearance buttonNormalBackgroundColor];
        self.titleView.frame = CGRectMake(0, 0, self.bounds.size.width, self.titleView.frame.size.height);
        [self.contentView addSubview:self.titleView];
        y = self.titleView.frame.size.height + lineHeight;
    }
    
    // 处理取消按钮
    if (self.cancelButtonTitle && ![self.actions objectPassingTest:^BOOL(ZKAlertAction * _Nonnull obj) { return obj.style == ZKAlertActionStyleCancel; }]) {
        ZKAlertAction *cancelAction = [[ZKAlertAction alloc] initWithTitle:self.cancelButtonTitle handler:nil style:ZKAlertActionStyleCancel];
        [self.actions addObject:cancelAction];
    }
    
    // 获取按钮的背景颜色和图像
    UIColor *highlightBGColor = [(ZKAlertStyleAppearance *)self.style.appearance buttonHighlightBackgroundColor];
    UIColor *normalBGColor = [(ZKAlertStyleAppearance *)self.style.appearance buttonNormalBackgroundColor];
    UIImage *highlightBGImage = [UIImage imageWithColor:highlightBGColor];
    UIImage *normalBGImage = [UIImage imageWithColor:normalBGColor];
    
    CGFloat x = self.bounds.origin.x;
    CGFloat width = self.bounds.size.width;
    CGFloat height = [(ZKAlertStyleAppearance *)self.style.appearance buttonHeight];
    
    // 遍历动作数组，创建并添加动作视图
    for (NSInteger index = 0; index < self.actions.count; index++) {
        ZKAlertAction *item = self.actions[index];
        BOOL isLastItem = (index == self.actions.count - 1);
        
        if (item.subtitle) {
            height = 62.0;
        } else {
            height = [(ZKAlertStyleAppearance *)self.style.appearance buttonHeight];
        }
        
        UIView *itemView = [self actionItemView:item atIndex:index isLastItem:isLastItem backgroundImage:normalBGImage highlightBackgroundImage:highlightBGImage];
        
        if (isLastItem) {
            if (item.style == ZKAlertActionStyleCancel) {
                UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, y, width, 7.0)];
                separator.backgroundColor = [(ZKAlertStyleAppearance *)self.style.appearance separatorColor];
                [self.contentView addSubview:separator];
                y += separator.frame.size.height;
            }
            height = [(ZKAlertStyleAppearance *)self.style.appearance buttonHeight] + [self safeInsets].bottom;
        }
        
        itemView.frame = CGRectMake(x, y, width, height);
        [self.contentView addSubview:itemView];
        y += height;
        
        if (!isLastItem) {
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(x, y, width, lineHeight)];
            line.backgroundColor = [(ZKAlertStyleAppearance *)self.style.appearance separatorLineColor];
            [self.contentView addSubview:line];
            y += lineHeight;
        }
    }
    
    // 设置背景视图和内容视图的颜色和框架
    self.backgroundView.backgroundColor = [(ZKAlertStyleAppearance *)self.style.appearance dimmingBackgroundColor];
    self.contentView.backgroundColor = [(ZKAlertStyleAppearance *)self.style.appearance containerBackgroundColor];
    self.contentView.frame = CGRectMake(x, self.bounds.size.height, width, y);
    
    // 设置内容视图的圆角
    if (self.roundTopCorners) {
        self.contentView.layer.cornerRadius = 15;
        self.contentView.layer.masksToBounds = YES;
        self.contentView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    }
    
    // 添加模糊效果视图
    if ([(ZKAlertStyleAppearance *)self.style.appearance enableBlurEffect]) {
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:[(ZKAlertStyleAppearance *)self.style.appearance effect]];
        effectView.frame = self.contentView.bounds;
        [self.contentView addSubview:effectView];
        [self.contentView sendSubviewToBack:effectView];
    }
}

// 创建动作项视图
- (UIView *)actionItemView:(ZKAlertAction *)item atIndex:(NSInteger)index isLastItem:(BOOL)isLastItem backgroundImage:(UIImage *)backgroundImage highlightBackgroundImage:(UIImage *)highlightBackgroundImage {
    if (!item.subtitle) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = index;
        button.backgroundColor = [UIColor clearColor];
        [button setBackgroundImage:backgroundImage forState:UIControlStateNormal];
        [button setBackgroundImage:highlightBackgroundImage forState:UIControlStateHighlighted];
        [button setTitle:item.title forState:UIControlStateNormal];
        [button setImage:item.image forState:UIControlStateNormal];
        button.imageEdgeInsets = item.imageEdgeInsets;
        
        if (isLastItem) {
            button.titleEdgeInsets = UIEdgeInsetsMake(-[self safeInsets].bottom / 2, 0, [self safeInsets].bottom / 2, 0);
        } else {
            button.titleEdgeInsets = item.titleEdgeInsets;
        }
        
        button.titleLabel.font = item.font;
        
        UIColor *titleColor;
        if (item.style == ZKAlertActionStyleDestructive) {
            titleColor = [(ZKAlertStyleAppearance *)self.style.appearance destructiveButtonTitleColor];
        } else {
            titleColor = item.titleColor ? item.titleColor : [(ZKAlertStyleAppearance *)self.style.appearance buttonTitleColor];
        }
        [button setTitleColor:titleColor forState:UIControlStateNormal];
        
        [button addTarget:self action:@selector(handleButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        return button;
    } else {
        UIView *view = [[UIView alloc] init];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, self.bounds.size.width, 62);
        button.tag = index;
        [button addTarget:self action:@selector(handleButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [button setBackgroundImage:backgroundImage forState:UIControlStateNormal];
        [button setBackgroundImage:highlightBackgroundImage forState:UIControlStateHighlighted];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.text = item.title;
        titleLabel.textColor = item.titleColor;
        titleLabel.font = [UIFont systemFontOfSize:18];
        titleLabel.frame = CGRectMake(0, 12, self.bounds.size.width, 22);
        
        UILabel *descLabel = [[UILabel alloc] init];
        descLabel.textAlignment = NSTextAlignmentCenter;
        descLabel.text = item.subtitle;
        descLabel.textColor = item.subtitleColor ? item.subtitleColor : [(ZKAlertStyleAppearance *)self.style.appearance titleColor];
        descLabel.font = [UIFont systemFontOfSize:12];
        descLabel.frame = CGRectMake(0, 36, self.bounds.size.width, 15);
        
        [view addSubview:button];
        [view addSubview:titleLabel];
        [view addSubview:descLabel];
        
        return view;
    }
}

// 获取安全区域边距
- (UIEdgeInsets)safeInsets {
    return [UIApplication sharedApplication].keyWindow.safeAreaInsets;
}

// 处理按钮点击事件
- (void)handleButtonTapped:(UIButton *)sender {
    NSInteger index = sender.tag;
    ZKAlertAction *item = self.actions[index];
    
    [self dismiss];
    
    !item.handler ?: item.handler(self);
}

// 手势识别器代理方法，判断是否接收触摸事件
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (touch.view == self.contentView) {
        return NO;
    }
    return YES;
}

@end
