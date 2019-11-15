//
//  ZKPageControl.m
//  ZKFoundation
//
//  Created by Kaiser on 2019/3/19.
//

#import "ZKPageControl.h"

#define pointWidth 5
#define pointInterval 8

@interface ZKPageControl ()

@property (nonatomic, strong) NSArray *pageArr;

@property (nonatomic, assign) BOOL shouldSetColor;
@property (nonatomic, assign) BOOL isInit;
@property (nonatomic, assign) BOOL inAni;

@end

@implementation ZKPageControl

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _tintColor = [UIColor whiteColor];
        _currentTintColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setNumberOfPages:(NSInteger)numberOfPages {
    _numberOfPages = numberOfPages;
    self.pageArr = nil;
    
    _isInit = YES;
    _shouldSetColor = YES;
    
    while (self.subviews.count) [self.subviews.lastObject removeFromSuperview];
    
    NSMutableArray *pageArray = [NSMutableArray array];
    for (NSInteger i = 0; i < numberOfPages; i++) {
        UIView *pointView = [[UIView alloc] init];
        pointView.layer.cornerRadius = pointWidth * 0.5f;
        [self addSubview:pointView];
        [pageArray addObject:pointView];
    }
    self.pageArr = pageArray;
    
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!self.pageArr.count) return;
    
    if (_shouldSetColor) {
        for (NSInteger i = 0; i < self.pageArr.count; i++) {
            UIView *pointView = [self.pageArr objectAtIndex:i];
            pointView.backgroundColor = self.tintColor;
            if (i == self.currentPage)
                pointView.backgroundColor = self.currentTintColor;
        }
        _shouldSetColor = NO;
    }
    
    if (_isInit) {
        CGFloat totalWidth = _numberOfPages * pointWidth + (_numberOfPages - 1) * pointInterval;
        for (int i = 0; i < self.pageArr.count; i++) {
            UIView *pointView = [self.pageArr objectAtIndex:i];
            CGFloat x = (self.frame.size.width - totalWidth) * 0.5f + (pointWidth + pointInterval) * i;
            CGFloat y = (self.frame.size.height - pointWidth) * 0.5f;
            CGFloat width = (i == _currentPage ? (pointWidth + pointInterval) : pointWidth);
            CGFloat height = pointWidth;
            if (i == _currentPage) {
                x = x - pointInterval * 0.5f;
            }
            pointView.frame = CGRectMake(x, y, width, height);
            _isInit = NO;
        }
    }
}

- (void)setCurrentPage:(NSInteger)currentPage {
    if (currentPage < 0 || currentPage > self.pageArr.count - 1)
        return;
    
    if (self.pageArr.count == 0) {
        _currentPage = currentPage;
        return;
    }
    if (_currentPage == currentPage) return;
    if (_inAni) return;
    
    
    if (currentPage > _currentPage) {
        UIView *currentView = self.pageArr[ _currentPage ];
        UIView *nextView = self.pageArr[ currentPage ];
        [self bringSubviewToFront:currentView];
        _inAni = YES;
        [UIView animateWithDuration:0.25
                         animations:^{
                             CGRect newFrame = currentView.frame;
                             newFrame.size = CGSizeMake((pointInterval + pointWidth) * (currentPage - self->_currentPage + 1), newFrame.size.height);
                             currentView.frame = newFrame;
                         }
                         completion:^(BOOL finished) {
                             [self bringSubviewToFront:nextView];
                             currentView.backgroundColor = self.tintColor;
                             nextView.backgroundColor = self.currentTintColor;
                             CGRect cFrame = currentView.frame;
                             nextView.frame = cFrame;
                             cFrame.origin = CGPointMake(cFrame.origin.x + pointInterval * 0.5f, cFrame.origin.y);
                             cFrame.size = CGSizeMake(pointWidth, pointWidth);
                             currentView.frame = cFrame;
                             
                             [UIView animateWithDuration:0.25
                                              animations:^{
                                                  CGRect newFrame = nextView.frame;
                                                  newFrame.size = CGSizeMake(pointInterval + pointWidth, newFrame.size.height);
                                                  newFrame.origin = CGPointMake(newFrame.origin.x + (pointInterval + pointWidth) * (currentPage - self->_currentPage), newFrame.origin.y);
                                                  nextView.frame = newFrame;
                                              }
                                              completion:^(BOOL finished) {
                                                  self->_currentPage = currentPage;
                                                  self->_inAni = NO;
                                              }];
                         }];
    } else {
        UIView *currentView;
        if (_currentPage < self.pageArr.count)
            currentView = self.pageArr[ _currentPage ];
        
        UIView *nextView;
        if (currentPage < self.pageArr.count)
            nextView = self.pageArr[ currentPage ];
        [self bringSubviewToFront:currentView];
        _inAni = YES;
        [UIView animateWithDuration:0.25
                         animations:^{
                             CGRect newFrame = currentView.frame;
                             newFrame.size = CGSizeMake((pointInterval + pointWidth) * (self->_currentPage - currentPage + 1), newFrame.size.height);
                             newFrame.origin = CGPointMake(newFrame.origin.x - (pointInterval + pointWidth) * (self->_currentPage - currentPage), newFrame.origin.y);
                             currentView.frame = newFrame;
                         }
                         completion:^(BOOL finished) {
                             [self bringSubviewToFront:nextView];
                             currentView.backgroundColor = self.tintColor;
                             nextView.backgroundColor = self.currentTintColor;
                             CGRect cFrame = currentView.frame;
                             nextView.frame = cFrame;
                             cFrame.origin = CGPointMake(cFrame.origin.x + pointInterval * 0.5f + (pointInterval + pointWidth) * (self->_currentPage - currentPage), cFrame.origin.y);
                             cFrame.size = CGSizeMake(pointWidth, pointWidth);
                             currentView.frame = cFrame;
                             
                             [UIView animateWithDuration:0.25
                                              animations:^{
                                                  CGRect newFrame = nextView.frame;
                                                  newFrame.size = CGSizeMake(pointInterval + pointWidth, newFrame.size.height);
                                                  nextView.frame = newFrame;
                                              }
                                              completion:^(BOOL finished) {
                                                  self->_currentPage = currentPage;
                                                  self->_inAni = NO;
                                              }];
                         }];
    }
}


@end
