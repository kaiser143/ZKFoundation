//
//  ZKActionSheetView.m
//  Masonry
//
//  Created by Kaiser on 2019/5/30.
//

#import "ZKActionSheetView.h"
#import <ZKCategories/ZKCategories.h>

#define ZY_HideNotification @"ZY_HideNotification"

#define ZY_CancelButtonHeight 49.f // 取消按钮的高度

#define ZY_ItemCellHeight 123.f // 每个item的高度
#define ZY_ItemCellWidth 72.f   // 每个item的宽度
#define ZY_ItemCellPadding 14.f // item之间的距离

#define ZY_AnimateDuration 0.3    // 动画时间
#define ZY_DimBackgroundAlpha 0.3 // 半透明背景的alpha值

#define ZY_TitleHeight 30.f
#define ZY_TitlePadding 20.f

@interface ZKActionItem ()

@property (nonatomic, strong) NSString *icon;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, copy) void (^handler)(ZKActionItem *);

@end

@implementation ZKActionItem

+ (instancetype)actionWithTitle:(nullable NSString *)title icon:(NSString *)icon handler:(void (^__nullable)(ZKActionItem *action))handler {
    ZKActionItem *item = self.new;
    item.icon          = icon;
    item.title         = title;
    item.handler       = handler;
    return item;
}

@end

@interface ZKActionItemCell : UICollectionViewCell
@property (nonatomic, strong) ZKActionItem *item;
@property (nonatomic, strong) UIButton *avatar;
@property (nonatomic, strong) UITextView *titleView;
@end

@implementation ZKActionItemCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self == nil) return nil;

    [self commonInit];

    return self;
}

- (void)commonInit {
    [self addSubview:self.avatar];
    [self addSubview:self.titleView];
}

#pragma mark - :. events Handler

- (void)iconClick {
    if (self.item.handler) {
        [[NSNotificationCenter defaultCenter] postNotificationName:ZY_HideNotification object:nil];
        self.item.handler(self.item);
    }
}

#pragma mark - :. private methods

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat topPadding      = 15.f;
    CGFloat iconView2titleH = 10.f;
    CGFloat cellWidth       = self.frame.size.width;
    CGFloat titleInset      = 4;

    // 图标
    CGFloat iconViewX = ZY_ItemCellPadding / 2;
    CGFloat iconViewY = topPadding;
    CGFloat iconViewW = cellWidth - ZY_ItemCellPadding;
    CGFloat iconViewH = cellWidth - ZY_ItemCellPadding;
    self.avatar.frame = CGRectMake(iconViewX, iconViewY, iconViewW, iconViewH);

    // 标题
    CGFloat titleViewX   = -titleInset;
    CGFloat titleViewY   = topPadding + iconViewH + iconView2titleH;
    CGFloat titleViewW   = cellWidth + 2 * titleInset;
    CGFloat titleViewH   = 30.f;
    self.titleView.frame = CGRectMake(titleViewX, titleViewY, titleViewW, titleViewH);
}

#pragma mark - :. getters and setters

- (UIButton *)avatar {
    if (!_avatar) {
        _avatar = [[UIButton alloc] init];
        _avatar.userInteractionEnabled = NO;
//        [_avatar addTarget:self
//                      action:@selector(iconClick)
//            forControlEvents:UIControlEventTouchUpInside];
    }
    return _avatar;
}

- (UITextView *)titleView {
    if (!_titleView) {
        _titleView                        = [[UITextView alloc] init];
        _titleView.textColor              = [UIColor darkGrayColor];
        _titleView.font                   = [UIFont systemFontOfSize:11];
        _titleView.contentInset           = UIEdgeInsetsMake(-10, 0, 0, 0);
        _titleView.backgroundColor        = nil;
        _titleView.textAlignment          = NSTextAlignmentCenter;
        _titleView.userInteractionEnabled = NO;
    }
    return _titleView;
}

- (void)setItem:(ZKActionItem *)item {
    _item = item;

    [self.avatar setImage:[UIImage imageNamed:item.icon] forState:UIControlStateNormal];
    self.titleView.text = item.title;
}

@end

@interface _KAIActionSheetCell : UITableViewCell <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end

@implementation _KAIActionSheetCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *identifier = @"_KAIActionSheetCell";
    _KAIActionSheetCell *cell   = [tableView dequeueReusableCellWithIdentifier:identifier];

    if (!cell) {
        cell = [[_KAIActionSheetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }

    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.backgroundColor = nil;

    [self addSubview:self.collectionView];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.collectionView.frame = self.bounds;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZKActionItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(ZKActionItemCell.class) forIndexPath:indexPath];
    ZKActionItem *item     = self.dataSource[indexPath.item];
    NSAssert([item isKindOfClass:[ZKActionItem class]], @"数组`shareArray`或者`functionArray`的元素必须为ZYShareItem对象");
    cell.item = item;

    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    ZKActionItemCell *cell = (ZKActionItemCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.avatar.highlighted = YES;
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    ZKActionItemCell *cell = (ZKActionItemCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.avatar.highlighted = NO;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ZKActionItem *item = self.dataSource[indexPath.item];

    [[NSNotificationCenter defaultCenter] postNotificationName:ZY_HideNotification object:nil];
    !item.handler ?: item.handler(item);
}

#pragma mark - setter

- (void)setDataSource:(NSArray *)dataSource {
    _dataSource = dataSource;
}

#pragma mark - getter

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView                                = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:self.flowLayout];
        _collectionView.alwaysBounceHorizontal         = YES; // 小于等于一页时, 允许bounce
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.delegate                       = self;
        _collectionView.dataSource                     = self;
        _collectionView.backgroundColor                = nil;

        [_collectionView registerClass:ZKActionItemCell.class forCellWithReuseIdentifier:NSStringFromClass(ZKActionItemCell.class)];
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout                         = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.minimumInteritemSpacing = 0;
        _flowLayout.minimumLineSpacing      = 0;
        _flowLayout.sectionInset            = UIEdgeInsetsMake(0, 10, 0, 10);
        _flowLayout.scrollDirection         = UICollectionViewScrollDirectionHorizontal;
        _flowLayout.itemSize                = CGSizeMake(ZY_ItemCellWidth, ZY_ItemCellHeight);
    }
    return _flowLayout;
}

@end

@interface _KAIActionSheetView : UIToolbar <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UILabel *cancelLabel;

@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, copy) void (^cancelBlock)(void);

- (CGFloat)shareSheetHeight;
- (CGFloat)initialHeight;

@end

@implementation _KAIActionSheetView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.backgroundColor = [UIColor.whiteColor colorWithAlphaComponent:0.7];
    
    [self addSubview:self.titleLabel];
    [self addSubview:self.tableView];
    [self addSubview:self.cancelButton];
    [self.cancelButton addSubview:self.cancelLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGRect frame      = self.frame;
    frame.size.height = [self shareSheetHeight];
    self.frame        = frame;

    // 标题
    self.titleLabel.frame = CGRectMake(ZY_TitlePadding, 0, ZKScreenSize().width - 2 * ZY_TitlePadding, self.titleHeight);

    CGFloat safeArea = [self safeAreaBottom];
    
    //适配iOS11中UIToolbar无法点击问题
    if (@available(iOS 11.0, *)) {
        safeArea = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom;
        NSArray *subViewArray = [self subviews];
        
        for (id view in subViewArray) {
            if ([view isKindOfClass:(NSClassFromString(@"_UIToolbarContentView"))]) {
                UIView *testView                = view;
                testView.userInteractionEnabled = NO;
            }
        }
    }
    
    // 取消按钮
    self.cancelButton.frame = CGRectMake(0, self.frame.size.height - ZY_CancelButtonHeight - safeArea, ZKScreenSize().width, ZY_CancelButtonHeight + safeArea);
    self.cancelLabel.frame = CGRectMake(0, 0, ZKScreenSize().width, ZY_CancelButtonHeight);

    // TableView
    self.tableView.frame = CGRectMake(0, self.titleHeight, ZKScreenSize().width, self.dataSource.count * ZY_ItemCellHeight);
}

#pragma mark - Action

- (void)cancelButtonClick {
    if (self.cancelBlock) {
        self.cancelBlock();
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *array = self.dataSource[indexPath.row];

    _KAIActionSheetCell *cell = [_KAIActionSheetCell cellWithTableView:tableView];
    cell.dataSource           = array;

    return cell;
}

#pragma mark - :. getters and setters

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel               = [[UILabel alloc] init];
        _titleLabel.textColor     = [UIColor darkGrayColor];
        _titleLabel.text          = @"分享";
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font          = [UIFont systemFontOfSize:13];
    }
    return _titleLabel;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView                 = [[UITableView alloc] init];
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.rowHeight       = ZY_ItemCellHeight;
        _tableView.bounces         = NO;
        _tableView.backgroundColor = nil;
        _tableView.dataSource      = self;
        _tableView.delegate        = self;
    }
    return _tableView;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton                 = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelButton.backgroundColor = [UIColor clearColor];
        [_cancelButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:1.f green:1.f blue:1.f alpha:0.6]] forState:UIControlStateNormal];
        [_cancelButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:1.f green:1.f blue:1.f alpha:0.1]] forState:UIControlStateHighlighted];
        [_cancelButton addTarget:self action:@selector(cancelButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (UILabel *)cancelLabel {
    if (!_cancelLabel) {
        _cancelLabel = UILabel.new;
        _cancelLabel.text = @"取消";
        _cancelLabel.textColor = [UIColor colorWithRed:51.f/255 green:51.f/255 blue:51.f/255 alpha:1.f];
        _cancelLabel.font = [UIFont systemFontOfSize:18];
        _cancelLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _cancelLabel;
}

- (CGFloat)safeAreaBottom {
    CGFloat safeArea = 0;
    if (@available(iOS 11.0, *)) safeArea = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom;
    return safeArea;
}

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (CGFloat)shareSheetHeight {
    return self.initialHeight + self.dataSource.count * ZY_ItemCellHeight - 1; // 这个-1用来让取消button挡住下面cell的seperator
}

- (CGFloat)initialHeight {
    CGFloat safeArea = [self safeAreaBottom];
    return (ZY_CancelButtonHeight + safeArea) + self.titleHeight;
}

- (CGFloat)titleHeight {
    return self.titleLabel.text.length ? ZY_TitleHeight : 0;
}

@end

@interface ZKActionSheetView ()

@property (nonatomic, strong) _KAIActionSheetView *shareSheetView; /**< 分享面板 */
@property (nonatomic, strong) UIView *dimBackgroundView;           /**< 半透明黑色背景 */

@property (nonatomic, strong) UIWindow *window;

@end

@implementation ZKActionSheetView

+ (instancetype)actionSheetViewWithShareItems:(NSArray *)shareArray
                          functionItems:(NSArray *)functionArray {
    ZKActionSheetView *shareView = [[self alloc] initWithShareItems:shareArray functionItems:functionArray];
    return shareView;
}

- (instancetype)initWithShareItems:(NSArray *)shareArray
                     functionItems:(NSArray *)functionArray {
    NSMutableArray *itemsArrayM = [NSMutableArray array];

    if (shareArray.count) [itemsArrayM addObject:shareArray];
    if (functionArray.count) [itemsArrayM addObject:functionArray];

    return [self initWithItemsArray:[itemsArrayM copy]];
}

- (instancetype)initWithItemsArray:(NSArray *)array {
    if (self = [super init]) {
        [self.shareSheetView.dataSource addObjectsFromArray:array];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.frame = CGRectMake(0, 0, ZKScreenSize().width, ZKScreenSize().height);

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hide) name:ZY_HideNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - public method

- (void)show {
    [self addToKeyWindow];
    [self showAnimationWithCompletion:nil];
}

- (void)hide {
    [self hideAnimationWithCompletion:^(BOOL finished) {
        [self removeFromKeyWindow];
    }];
}

#pragma mark - private method

- (void)addToKeyWindow {
    if (!self.superview) {
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        [keyWindow addSubview:self];

        [self addSubview:self.dimBackgroundView];
        [self addSubview:self.shareSheetView];
    }
}

- (void)removeFromKeyWindow {
    if (self.superview) {
        [self removeFromSuperview];
    }
}

- (void)showAnimationWithCompletion:(void (^)(BOOL finished))completion {
    [UIView animateWithDuration:ZY_AnimateDuration
                     animations:^{
                         self.dimBackgroundView.alpha = ZY_DimBackgroundAlpha;

                         CGRect frame              = self.shareSheetView.frame;
                         frame.origin.y            = ZKScreenSize().height - self.shareSheetView.shareSheetHeight;
                         self.shareSheetView.frame = frame;
                     }
                     completion:completion];
}

- (void)hideAnimationWithCompletion:(void (^)(BOOL finished))completion {
    [UIView animateWithDuration:ZY_AnimateDuration
                     animations:^{
                         self.dimBackgroundView.alpha = 0;

                         CGRect frame              = self.shareSheetView.frame;
                         frame.origin.y            = ZKScreenSize().height;
                         self.shareSheetView.frame = frame;
                     }
                     completion:completion];
}

#pragma mark - getter

- (_KAIActionSheetView *)shareSheetView {
    if (!_shareSheetView) {
        _shareSheetView              = _KAIActionSheetView.new;
        _shareSheetView.frame        = CGRectMake(0, ZKScreenSize().height, ZKScreenSize().width, _shareSheetView.initialHeight);
        @weakify(self);
        _shareSheetView.cancelBlock  = ^{
            @strongify(self);
            [self hide];
        };
    }
    return _shareSheetView;
}

- (UIView *)dimBackgroundView {
    if (!_dimBackgroundView) {
        _dimBackgroundView                 = [[UIView alloc] init];
        _dimBackgroundView.frame           = CGRectMake(0, 0, ZKScreenSize().width, ZKScreenSize().height);
        _dimBackgroundView.backgroundColor = [UIColor blackColor];
        _dimBackgroundView.alpha           = 0;

        // 添加手势监听
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
        [_dimBackgroundView addGestureRecognizer:tap];
    }
    return _dimBackgroundView;
}

- (UILabel *)titleLabel {
    return self.shareSheetView.titleLabel;
}

- (UIButton *)cancelButton {
    return self.shareSheetView.cancelButton;
}

@end
