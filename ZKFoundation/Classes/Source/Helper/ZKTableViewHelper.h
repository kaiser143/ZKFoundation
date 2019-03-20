//
//  ZKTableViewHelper.h
//  FBSnapshotTestCase
//
//  Created by Kaiser on 2019/3/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString *__nonnull (^ZKTableHelperCellIdentifierBlock)(NSIndexPath *indexPath, id dataSource);
typedef void (^ZKTableHelperDidSelectBlock)(UITableView *tableView, NSIndexPath *indexPath, id dataSource);
typedef void (^ZKTableHelperDidDeSelectBlock)(UITableView *tableView, NSIndexPath *indexPath, id dataSource);
typedef CGFloat (^ZKTableHelperCellAutoHeightForRowBlock)(UITableView *tableView, NSString *cellIdentifier, id dataSource);

typedef void (^ZKTableHelperDidMoveToRowBlock)(UITableView *tableView, NSIndexPath *sourceIndexPath, id sourceModel, NSIndexPath *destinationIndexPath, id destinationModel);

typedef void (^ZKTableHelperDidWillDisplayBlock)(UITableViewCell *cell, NSIndexPath *indexPath, id dataSource, BOOL IsCelldisplay);

typedef void (^ZKTableHelperDidEditingBlock)(UITableView *tableView, UITableViewCellEditingStyle editingStyle, NSIndexPath *indexPath, id dataSource);
typedef NSString *__nonnull (^ZKTableHelperDidEditTitleBlock)(UITableView *tableView, NSIndexPath *indexPath, id dataSource);

typedef UITableViewCellEditingStyle (^ZKTableHelperEditingStyle)(UITableView *tableView, NSIndexPath *indexPath, id dataSource);
typedef NSArray<UITableViewRowAction *> *__nonnull (^ZKTableHelperDidEditActionsBlock)(UITableView *tableView, NSIndexPath *indexPath, id dataSource);

typedef void (^ZKScrollViewWillBeginDragging)(UIScrollView *scrollView);
typedef void (^ZKScrollViewDidScroll)(UIScrollView *scrollView);
typedef void (^ZKScrollViewDidEndDragging)(UIScrollView *scrollView);
typedef void (^ZKTableHelperCellBlock)(NSString *info, id event);

typedef UIView *__nonnull (^ZKTableHelperHeaderBlock)(UITableView *tableView, NSInteger section, id dataSource);
typedef UIView *__nonnull (^ZKTableHelperFooterBlock)(UITableView *tableView, NSInteger section, id dataSource);

typedef NSString *__nonnull (^ZKTableHelperTitleHeaderBlock)(UITableView *tableView, NSInteger section);
typedef NSString *__nonnull (^ZKTableHelperTitleFooterBlock)(UITableView *tableView, NSInteger section);

typedef NSInteger (^ZKTableHelperNumberOfSections)(UITableView *tableView, NSInteger count);
typedef NSInteger (^ZKTableHelperNumberRows)(UITableView *tableView, NSInteger section, NSArray *cModels);
typedef id __nonnull (^ZKTableHelperCurrentModelAtIndexPath)(id dataAry, NSIndexPath *indexPath);

typedef void (^ZKTableHelperScrollViewDidEndScrolling)(UIScrollView *scrollView);

@interface ZKTableViewHelper : NSObject <UITableViewDataSource, UITableViewDelegate>

/**
 *  @brief 获取当前数据源
 */
@property (nonatomic, weak, readonly) NSMutableArray *dataSource;
@property (nonatomic, copy) NSArray *sectionIndexTitle;

/**
 *  @brief 分组顶部高度 默认：0.001
 */
@property (nonatomic, assign) CGFloat titleHeaderHeight;
@property (nonatomic, assign) CGFloat titleHeaderSpacingHeight;

/**
 *  @brief 分组底部高度 默认：0.001
 */
@property (nonatomic, assign) CGFloat titleFooterHeight;
@property (nonatomic, assign) CGFloat titleFooterSpacingHeight;

/**
 *  @brief 是否补齐线(默认不补齐)
 */
@property (nonatomic, assign) BOOL paddedSeparator;

/**
 *  @brief 是否显示侧边字母
 */
@property (nonatomic, assign) BOOL isSection;

/**
 是否移动行
 */
@property (nonatomic, assign) BOOL isCanMoveRow;

/**
 是否防快速点击 (默认：NO 不防止)
 */
@property (nonatomic, assign) BOOL isAntiHurry;

/**  **/

/**
 * @brief section HeaderView 是否悬停 (默认悬停) YES: 不悬停
 *  UITableViewStylePlain 模式下
 */
@property (nonatomic, assign) BOOL isHover;

/**
 *  When using the storyboard and a single cell, set the property inspector same identifier
 */
@property (nullable, nonatomic, copy) NSString *cellIdentifier;

@property (nonatomic, strong) NSArray *kai_cellXIB;

@property (nonatomic, weak) UITableView *kai_tableView;
@property (nonatomic, strong) NSIndexPath *kai_indexPath;

/**
 *  When using xib, all incoming nib names
 */
- (void)registerNibs:(NSArray<NSString *> *)cellNibNames;

- (UITableViewHeaderFooterView *)tableViewSectionViewWithIdentifier:(NSString *)identifier
                                                            section:(NSInteger)section;

#pragma mark -
#pragma mark :. Block事件

/*!
 *  @brief    计算高度
 */
- (void)cellAutoSizeCell:(ZKTableHelperCellAutoHeightForRowBlock)cb;


/**
 *  When there are multiple cell, returned identifier in block
 */
- (void)cellMultipleIdentifier:(ZKTableHelperCellIdentifierBlock)cb;

/**
 *  If you override tableView:didSelectRowAtIndexPath: method, it will be invalid
 */
- (void)didSelect:(ZKTableHelperDidSelectBlock)cb;

/**
 *  If you override tableView:didDeselectRowAtIndexPath: method, it will be invalid
 */
- (void)didDeSelect:(ZKTableHelperDidDeSelectBlock)cb;

/**
 *  @brief 编辑样式
 */
- (void)didEditingStyle:(ZKTableHelperEditingStyle)cb;

/**
 *  @brief  cell侧滑编辑事件
 */
- (void)didEnditing:(ZKTableHelperDidEditingBlock)cb;
/**
 *  @brief  cell侧滑标题
 */
- (void)didEnditTitle:(ZKTableHelperDidEditTitleBlock)cb;

/**
 *  @brief  cell侧滑菜单
 */
- (void)didEditActions:(ZKTableHelperDidEditActionsBlock)cb;

/**
 移动Cell
 */
- (void)didMoveToRowBlock:(ZKTableHelperDidMoveToRowBlock)cb;

/**
 *  @brief 设置Cell显示
 */
- (void)cellWillDisplay:(ZKTableHelperDidWillDisplayBlock)cb;

- (void)didScrollViewWillBeginDragging:(ZKScrollViewWillBeginDragging)block;
- (void)didScrollViewDidScroll:(ZKScrollViewDidScroll)block;
- (void)didScrollViewEndDragging:(ZKScrollViewDidEndDragging)block;

/**
 *  @brief  Header视图
 */
- (void)headerView:(ZKTableHelperHeaderBlock)cb;
- (void)headerTitle:(ZKTableHelperTitleHeaderBlock)cb;

/**
 *  @brief  Footer视图
 */
- (void)footerView:(ZKTableHelperFooterBlock)cb;
- (void)footerTitle:(ZKTableHelperTitleFooterBlock)cb;

- (void)numberOfSections:(ZKTableHelperNumberOfSections)cb;
/**
 *  @brief  NumberOfRowsInSection
 */
- (void)numberOfRowsInSection:(ZKTableHelperNumberRows)cb;

/**
 *  @brief 设置Cell回调Block
 */
- (void)cellViewEventBlock:(ZKTableHelperCellBlock)cb;

/**
 *  @brief  处理获取当前模型
 */
- (void)currentModelIndexPath:(ZKTableHelperCurrentModelAtIndexPath)cb;

/**
 滚动结束回调
 */
- (void)didScrollViewDidEndScrolling:(ZKTableHelperScrollViewDidEndScrolling)cb;

#pragma mark -
#pragma mark :. Handler

/**
 *  @brief 显示分组数据
 *
 *  @param newDataAry 数据源
 */
- (void)kai_reloadGroupDataAry:(NSArray *)newDataAry;

/**
 重新加载该分组数据
 
 @param newDataAry 分组数据
 @param cSection 分组下标
 */
- (void)kai_reloadGroupDataAry:(NSArray *)newDataAry
                    forSection:(NSInteger)cSection;

/**
 *  @brief  添加分组数据
 *
 *  @param newDataAry 数据源
 */
- (void)kai_addGroupDataAry:(NSArray *)newDataAry;

/**
 *  @brief  插入分组数据
 *
 *  @param newDataAry 数据源
 *  @param cSection   下标
 *                    如下标为-1 是往前插入
 */
- (void)kai_insertGroupDataAry:(NSArray *)newDataAry
                    forSection:(NSInteger)cSection;

/**
 *  @brief  插入多条分组数据
 *
 *  @param newDataAry 数据源
 *  @param cSection   下标
 *                    如下标为-1 是往前插入
 */
- (void)kai_insertMultiplGroupDataAry:(NSArray *)newDataAry
                           forSection:(NSInteger)cSection;

/**
 删除分组数据
 
 @param cSection 分组下标
 */
- (void)kai_deleteGroupData:(NSInteger)cSection;

#pragma mark -
#pragma mark :. Plain
/**
 *  @brief  显示数据
 *
 *  @param newDataAry 数据源
 */
- (void)kai_resetDataAry:(NSArray *)newDataAry;

/**
 *  @brief  显示数据
 *
 *  @param newDataAry 数据源
 *  @param cSection   分组数
 */
- (void)kai_resetDataAry:(NSArray *)newDataAry forSection:(NSInteger)cSection;

/**
 *  @brief  刷新并加入新数据
 *
 *  @param newDataAry 数据源
 */
- (void)kai_reloadDataAry:(NSArray *)newDataAry;

/**
 *  @brief  刷新并加入新数据
 *
 *  @param newDataAry 数据源
 *  @param cSection   分组数
 */
- (void)kai_reloadDataAry:(NSArray *)newDataAry forSection:(NSInteger)cSection;

/**
 *  @brief  批量添加数据
 *
 *  @param newDataAry 数据源
 */
- (void)kai_addDataAry:(NSArray *)newDataAry;
/**
 *  @brief  批量添加
 *
 *  @param newDataAry 数据源
 *  @param cSection   分组数
 */
- (void)kai_addDataAry:(NSArray *)newDataAry forSection:(NSInteger)cSection;

/**
 *  @brief  单个添加
 *
 *  @param cModel     数据模型
 *  @param cIndexPath 下标位置
 */
- (void)kai_insertData:(id)cModel atIndex:(NSIndexPath *)cIndexPath;

/**
 *  @brief 替换数据对象
 *
 *  @param model      对象
 *  @param cIndexPath 下标位置
 */
- (void)kai_replaceDataAtIndex:(id)model
                  forIndexPath:(NSIndexPath *)cIndexPath;

- (void)kai_replaceDataAtIndex:(id)model
                  forIndexPath:(NSIndexPath *)cIndexPath
              withRowAnimation:(UITableViewRowAnimation)animated;

/**
 *  @brief  根据下标删除数据
 *
 *  @param cIndexPath 下标位置
 */
- (void)kai_deleteDataAtIndex:(NSIndexPath *)cIndexPath;
- (void)kai_deleteDataAtIndexs:(NSArray<NSIndexPath *> *)indexPaths;


- (id)currentModel;
- (id)currentModelAtIndexPath:(NSIndexPath *)cIndexPath;
- (void)configureCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath withObjet:(id)obj;

@end


NS_ASSUME_NONNULL_END
