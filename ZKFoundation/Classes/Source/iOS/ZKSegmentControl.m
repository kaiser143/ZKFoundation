//
//  ZKSegment.m
//  Masonry
//
//  Created by Kaiser on 2019/5/5.
//

#import "ZKSegmentControl.h"
#import <ZKCategories/ZKCategories.h>

@interface ZKSegmentControl () <UIScrollViewDelegate>

@property (nonatomic, weak) UIView *sliderView;
@property (nonatomic, weak) UIView *lineView;

@property (nonatomic, strong) UIButton *selectedBtn;

@property (nonatomic, strong) NSArray *titleArr;

@property (nonatomic, strong) NSMutableArray *titleButtons;

@property (nonatomic, assign) NSInteger titleFontSize;

@property (nonatomic, assign) BOOL isint;

@property (nonatomic, assign) CGPoint lastContentOffset;

/** 是否是点击按钮 **/
@property (nonatomic, assign) BOOL isForbidScroll;

@end

static NSInteger const kSiderWidth = 18;

static CGFloat const kSpacing = 15;

@implementation ZKSegmentControl

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.showsHorizontalScrollIndicator = NO;
        self.delegate                       = self;
        self.backgroundColor                = [UIColor whiteColor];

        _titleColor         = [UIColor colorWithHexString:@"303943"];
        _titleSelectedColor = [UIColor colorWithHexString:@"303943"];
        _titleFontSize      = 15;
        _lineHeight         = 2;
        _isLine             = NO;
        _isint              = YES;

        _shadow = NO;

        _titleButtons = [NSMutableArray array];

        self.layer.shadowOffset  = CGSizeMake(0, 5);
        self.layer.shadowOpacity = 0.5;
        self.layer.shadowRadius  = 4;
    }
    return self;
}

- (void)initialization {
    for (NSInteger i = 0; i < _titleArr.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:btn];
        btn.tag = i + 100;
        [btn setTitle:[self titleHandle:_titleArr[ i ]] forState:UIControlStateNormal];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:_titleFontSize]];

        [btn setTitleColor:_titleColor forState:UIControlStateNormal];
        [btn setTitleColor:_titleSelectedColor forState:UIControlStateSelected];
        [btn setTitleColor:_titleSelectedColor forState:UIControlStateSelected | UIControlStateHighlighted];
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];

        if (i == self.currentIndex) {
            btn.selected        = YES;
            btn.titleLabel.font = [UIFont boldSystemFontOfSize:_titleFontSize];
            self.selectedBtn    = btn;
        }

        [self.titleButtons addObject:btn];
    }

    UIView *lineView         = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - 0.5, self.width, 0.5)];
    lineView.backgroundColor = [UIColor colorWithHexString:@"EAEBEC"];
    [self addSubview:_lineView = lineView];

    if (self.isSlider) {
        //    滑块
        UIView *sliderView = [[UIView alloc] init];
        [self addSubview:sliderView];
        sliderView.backgroundColor = self.sliderColor;
        self.sliderView            = sliderView;

        self.sliderView.width = kSiderWidth;
        if (self.isFullof) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObject:[UIFont systemFontOfSize:_titleFontSize] forKey:NSFontAttributeName];
            CGSize textSize          = [_titleArr[ 0 ] boundingRectWithSize:CGSizeMake(MAXFLOAT, 0.0) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
            self.sliderView.width    = textSize.width;

            if (self.lineWidth > 0)
                self.sliderView.width = self.lineWidth;
        }
        self.sliderView.height = self.lineHeight;
        self.sliderView.top    = self.height - self.lineHeight - self.lineOffsetY;
        kai_view_radius(self.sliderView, self.sliderView.height / 2);
    }
}

- (NSString *)titleHandle:(NSString *)title {
    if (self.isTitleLength) {
        if (title.length > 5)
            title = [NSString stringWithFormat:@"%@...", [title substringToIndex:5]];
    }
    return title;
}

- (void)setItems:(NSArray *)arr {
    [self removeAllSubviews];
    [self.titleButtons removeAllObjects];
    if (!arr.count)
        return;

    _currentIndex = 0;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setContentOffset:CGPointMake(0, 0) animated:YES];
    });
    if (self.isSlider) {
        _titleFontSize = 12;
    }
    _titleArr = arr;
    [self initialization];
    _isint = YES;
}

- (void)setShadow:(BOOL)shadow {
    _shadow        = shadow;
    UIColor *color = [UIColor clearColor];
    if (_shadow)
        color              = [UIColor colorWithHexString:@"303943"];
    self.layer.shadowColor = color.CGColor;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (_isint) {
        self.lineView.top    = self.height - self.lineView.height;
        self.lineView.hidden = self.isLine;

        //    按钮
        CGFloat btnH           = self.height - 2;
        __block CGFloat totalX = self.isFullof ? 0 : kSpacing;

        __block UIButton *currentBtn;
        [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            if ([obj isKindOfClass:[UIButton class]]) {
                UIButton *btn = (UIButton *)obj;
                if (btn.selected)
                    currentBtn = btn;

                if (self.isFullof) {
                    btn.left   = totalX;
                    btn.top    = 1;
                    btn.width  = self.width / self.titleArr.count;
                    btn.height = self.height;

                    totalX = totalX + btn.width;
                } else {
                    CGRect btnRect = [btn.currentTitle boundingRectWithSize:CGSizeMake(MAXFLOAT, btnH) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:self.titleFontSize], NSFontAttributeName, nil] context:nil];
                    btn.left       = totalX;
                    btn.top        = 1;
                    btn.width      = btnRect.size.width + kSpacing;
                    btn.height     = btnH;

                    if (self.isSlider) {
                        btn.width  = btnRect.size.width + 30;
                        btn.height = btnRect.size.height + 8;
                        btn.top    = (btnH - btn.height) / 2;

                        if (self.isSlider)
                            kai_view_border_radius(btn, btn.height / 2, 0.5, btn.selected ? self.titleSelectedColor : self.titleColor);
                    }

                    totalX = totalX + btn.width + kSpacing;
                }
            }
        }];

        if (totalX - 10 < ZKScreenSize().width) {
            self.contentSize = CGSizeMake(ZKScreenSize().width, 0);
        } else {
            self.contentSize = CGSizeMake(totalX, 0);
        }

        if (!self.isSlider) {
            if (self.isFullof) {
                NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObject:[UIFont systemFontOfSize:_titleFontSize] forKey:NSFontAttributeName];
                CGSize textSize          = [currentBtn.currentTitle boundingRectWithSize:CGSizeMake(MAXFLOAT, 0.0) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
                self.sliderView.width    = textSize.width;
                if (self.lineWidth > 0)
                    self.sliderView.width = self.lineWidth;
            }
            self.sliderView.centerX = currentBtn.centerX;
        }

        self.lineView.width = self.contentSize.width;
        _isint              = NO;
    }
}

//按钮点击事件
- (void)btnClick:(UIButton *)sender {
    [self setCurrentIndex:sender.tag - 100];
}

- (void)setCurrentIndex:(NSInteger)currentIndex {
    if (currentIndex == self.currentIndex) return;

    UIButton *currentButton = self.titleButtons[ currentIndex ];
    UIButton *oldButton     = self.titleButtons[ self.currentIndex ];

    currentButton.titleLabel.font      = [UIFont boldSystemFontOfSize:self.titleFontSize];
    currentButton.titleLabel.textColor = self.titleSelectedColor;
    currentButton.selected             = YES;

    oldButton.titleLabel.textColor = self.titleColor;
    oldButton.titleLabel.font      = [UIFont systemFontOfSize:self.titleFontSize];
    oldButton.selected             = NO;

    self.isForbidScroll = YES;
    _currentIndex       = currentIndex;
    [self titleViewDidEndScroll];

    [UIView animateWithDuration:0.3
        animations:^{
            self.sliderView.centerX = currentButton.centerX;
        }
        completion:^(BOOL finished) {
            if ([self.kai_delegate respondsToSelector:@selector(didScrollSelectedIndex:)])
                [self.kai_delegate didScrollSelectedIndex:self->_currentIndex];
        }];
}

- (void)didBeginDraaWillBeginDragging:(CGPoint)offset {
    self.isForbidScroll = NO;
    _lastContentOffset  = offset;
}

- (void)didScrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.isForbidScroll) return;

    CGFloat progress      = 0.0;
    NSInteger sourceIndex = 0;
    NSInteger targetIndex = 0;

    CGFloat currentOffsetX = scrollView.contentOffset.x;
    CGFloat scrollViewW    = scrollView.bounds.size.width;
    if (currentOffsetX > self.lastContentOffset.x) { //左滑
        progress    = currentOffsetX / scrollViewW - floor(currentOffsetX / scrollViewW);
        sourceIndex = (NSInteger)(currentOffsetX / scrollViewW);
        targetIndex = sourceIndex + 1;
        if (targetIndex >= self.titleArr.count) {
            targetIndex = self.titleArr.count - 1;
            sourceIndex = self.titleArr.count - 1;
        }

        if (currentOffsetX - self.lastContentOffset.x == scrollViewW) {
            progress    = 1.0;
            targetIndex = sourceIndex;
        }
    } else { //右滑
        progress    = 1 - (currentOffsetX / scrollViewW - floor(currentOffsetX / scrollViewW));
        targetIndex = (NSInteger)(currentOffsetX / scrollViewW);

        sourceIndex = targetIndex + 1;
        if (sourceIndex >= self.titleArr.count)
            sourceIndex = self.titleArr.count - 1;
    }

    [self setTitleWithProgress:progress sourceIndex:sourceIndex targetIndex:targetIndex];
}

- (void)setTitleWithProgress:(CGFloat)progress sourceIndex:(NSInteger)sourceIndex targetIndex:(NSInteger)targetIndex {
    //取出sourceLabel和targetLabel
    UIButton *sourceLabel = self.titleButtons[ sourceIndex ];
    UIButton *targetLabel = self.titleButtons[ targetIndex ];
    //颜色渐变
    UIColor *delataColor             = [UIColor colorWithRed:self.selectedColorRGB[ 0 ] - self.normalColorRGB[ 0 ] green:self.selectedColorRGB[ 1 ] - self.normalColorRGB[ 1 ] blue:self.selectedColorRGB[ 2 ] - self.normalColorRGB[ 2 ] alpha:1.0];
    const CGFloat *colorDelta        = [self getRGBWithColor:delataColor];
    sourceLabel.titleLabel.font      = [UIFont systemFontOfSize:self.titleFontSize];
    sourceLabel.titleLabel.textColor = [UIColor colorWithRed:self.selectedColorRGB[ 0 ] - colorDelta[ 0 ] * progress green:self.selectedColorRGB[ 1 ] - colorDelta[ 1 ] * progress blue:self.selectedColorRGB[ 2 ] - colorDelta[ 2 ] * progress alpha:1.0];

    targetLabel.titleLabel.font      = [UIFont boldSystemFontOfSize:self.titleFontSize];
    targetLabel.titleLabel.textColor = [UIColor colorWithRed:self.normalColorRGB[ 0 ] + colorDelta[ 0 ] * progress green:self.normalColorRGB[ 1 ] + colorDelta[ 1 ] * progress blue:self.normalColorRGB[ 2 ] + colorDelta[ 2 ] * progress alpha:1.0];

    //记录最新的index
    _currentIndex      = targetIndex;
    CGFloat moveTotalX = targetLabel.centerX - sourceLabel.centerX;
    //    CGFloat moveTotalW = targetLabel.frame.size.width - sourceLabel.frame.size.width;

    //计算滚动的范围差值
    if (!self.isSlider) {
        CGFloat x = sourceLabel.frame.origin.x + ((sourceLabel.frame.size.width - (self.isFullof ? self.sliderView.width : self.lineWidth)) / 2.0) + moveTotalX * progress;
        //        CGFloat width = self.lineWidth + moveTotalW * progress;
        self.sliderView.left = x;
        //        self.sliderView.width = width;
    }
}

- (void)didScrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat currentOffsetX = scrollView.contentOffset.x;
    CGFloat scrollViewW    = scrollView.bounds.size.width;

    //快速滑动之后 可能会出现偏差 需要重置
    NSInteger targetIndex = (NSInteger)(currentOffsetX / scrollViewW);
    if (targetIndex >= self.titleArr.count - 1) {
        NSInteger sourceIndex = targetIndex;
        CGFloat progress      = 1.0;
        [self setTitleWithProgress:progress sourceIndex:sourceIndex targetIndex:targetIndex];
    }

    [self titleViewDidEndScroll];

    if ([self.kai_delegate respondsToSelector:@selector(didScrollSelectedIndex:)])
        [self.kai_delegate didScrollSelectedIndex:self->_currentIndex];
}

- (void)didScrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self titleViewDidEndScroll];
    }
}

#pragma mark -
#pragma mark :. handle

- (void)titleViewDidEndScroll {
    UIButton *targetLabel = self.titleButtons[ self.currentIndex ];

    targetLabel.selected        = YES;
    targetLabel.titleLabel.font = [UIFont boldSystemFontOfSize:self.titleFontSize];

    CGFloat offset = targetLabel.center.x - ZKScreenSize().width * 0.5;
    if (offset < 0)
        offset = 0;

    CGFloat maxOffset = self.contentSize.width - ZKScreenSize().width;
    if (offset > maxOffset) {
        offset = maxOffset;
        if (!self.isFullof && offset > 0)
            offset += targetLabel.width / 2;
    }

    [self setContentOffset:CGPointMake(offset, 0) animated:YES];
}

#pragma mark -
#pragma mark :. 颜色处理

- (const CGFloat *)normalColorRGB {
    return [self getRGBWithColor:self.titleColor];
}

- (const CGFloat *)selectedColorRGB {
    return [self getRGBWithColor:self.titleSelectedColor];
}

- (const CGFloat *)getRGBWithColor:(UIColor *)color {
    CGColorRef refColor       = [color CGColor];
    const CGFloat *components = nil;
    long numComponents        = CGColorGetNumberOfComponents(refColor);
    if (numComponents == 4) {
        components = CGColorGetComponents(refColor);
    }
    return components;
}

@end
