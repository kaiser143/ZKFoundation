//
//  ZKTableViewHelper.h
//  FBSnapshotTestCase
//
//  Created by Kaiser on 2019/3/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString *_Nullable (^ZKTableHelperCellIdentifierForRowBlock)(NSIndexPath *indexPath, id dataSource);
typedef void (^ZKTableHelperDidSelectBlock)(UITableView *tableView, NSIndexPath *indexPath, id dataSource);
typedef void (^ZKTableHelperDidDeSelectBlock)(UITableView *tableView, NSIndexPath *indexPath, id dataSource);
typedef CGFloat (^ZKTableHelperCellAutoHeightForRowBlock)(UITableView *tableView, NSIndexPath *indexPath, NSString *identifier, id dataSource);

typedef void (^ZKTableHelperDidMoveToRowBlock)(UITableView *tableView, NSIndexPath *sourceIndexPath, id sourceModel, NSIndexPath *destinationIndexPath, id destinationModel);

typedef void (^ZKTableHelperDidWillDisplayBlock)(UITableViewCell *cell, NSIndexPath *indexPath, id dataSource, BOOL IsCelldisplay);

typedef void (^ZKTableHelperDidEditingBlock)(UITableView *tableView, UITableViewCellEditingStyle editingStyle, NSIndexPath *indexPath, id dataSource);
typedef NSString *_Nullable (^ZKTableHelperDidEditTitleBlock)(UITableView *tableView, NSIndexPath *indexPath, id dataSource);

typedef BOOL(^ZKTableHelperCanEditRowAtIndexPathBlock)(id dataSource, NSIndexPath *indexPath);
typedef UITableViewCellEditingStyle (^ZKTableHelperEditingStyleBlock)(UITableView *tableView, NSIndexPath *indexPath, id dataSource);
typedef NSArray<UITableViewRowAction *> *_Nullable (^ZKTableHelperDidEditActionsBlock)(UITableView *tableView, NSIndexPath *indexPath, id dataSource);

typedef void (^ZKScrollViewWillBeginDraggingBlock)(UIScrollView *scrollView);
typedef void (^ZKScrollViewDidScrollBlock)(UIScrollView *scrollView);
typedef void (^ZKScrollViewDidEndDraggingBlock)(UIScrollView *scrollView);

typedef UIView *_Nullable (^ZKTableHelperHeaderBlock)(UITableView *tableView, NSInteger section, id dataSource);
typedef UIView *_Nullable (^ZKTableHelperFooterBlock)(UITableView *tableView, NSInteger section, id dataSource);

typedef NSString *_Nullable (^ZKTableHelperTitleHeaderBlock)(UITableView *tableView, NSInteger section);
typedef NSString *_Nullable (^ZKTableHelperTitleFooterBlock)(UITableView *tableView, NSInteger section);

typedef NSInteger (^ZKTableHelperNumberOfSectionsBlock)(UITableView *tableView, NSInteger count);
typedef NSInteger (^ZKTableHelperNumberRowsBlock)(UITableView *tableView, NSInteger section, NSArray *dataSource);
typedef id _Nullable (^ZKTableHelperCurrentModelAtIndexPathBlock)(id dataSource, NSIndexPath *indexPath);

typedef void (^ZKTableHelperScrollViewDidEndScrollingBlock)(UIScrollView *scrollView);

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
- (void)registerNibs:(NSArray<NSString *> *)nibs;

- (UITableViewHeaderFooterView *)tableViewSectionViewWithIdentifier:(NSString *)identifier
                                                            section:(NSInteger)section;

#pragma mark -
#pragma mark :. Block事件

/*!
 *  @brief    计算高度
 */
- (void)autoHeightCell:(ZKTableHelperCellAutoHeightForRowBlock)block;

/**
 *  When there are multiple cell, returned identifier in block
 */
- (void)cellIdentifierForRowAtIndexPath:(ZKTableHelperCellIdentifierForRowBlock)block;

/**
 *  If you override tableView:didSelectRowAtIndexPath: method, it will be invalid
 */
- (void)didSelect:(ZKTableHelperDidSelectBlock)block;

/**
 *  If you override tableView:didDeselectRowAtIndexPath: method, it will be invalid
 */
- (void)didDeSelect:(ZKTableHelperDidDeSelectBlock)block;

/*!
 *  @brief    是否可编辑
 */
- (void)canEditRow:(ZKTableHelperCanEditRowAtIndexPathBlock)block;

/**
 *  @brief 编辑样式
 */
- (void)didEditingStyle:(ZKTableHelperEditingStyleBlock)block;

/**
 *  @brief  cell侧滑编辑事件
 */
- (void)didEditing:(ZKTableHelperDidEditingBlock)block;
/**
 *  @brief  cell侧滑标题
 */
- (void)didEditTitle:(ZKTableHelperDidEditTitleBlock)block;

/**
 *  @brief  cell侧滑菜单
 */
- (void)didEditActions:(ZKTableHelperDidEditActionsBlock)block;

/**
 移动Cell
 */
- (void)didMoveToRowBlock:(ZKTableHelperDidMoveToRowBlock)block;

/**
 *  @brief 设置Cell显示
 */
- (void)cellWillDisplay:(ZKTableHelperDidWillDisplayBlock)block;

- (void)didScrollViewWillBeginDragging:(ZKScrollViewWillBeginDraggingBlock)block;
- (void)didScrollViewDidScroll:(ZKScrollViewDidScrollBlock)block;
- (void)didScrollViewEndDragging:(ZKScrollViewDidEndDraggingBlock)block;

/**
 *  @brief  Header视图
 */
- (void)headerView:(ZKTableHelperHeaderBlock)block;
- (void)headerTitle:(ZKTableHelperTitleHeaderBlock)block;

/**
 *  @brief  Footer视图
 */
- (void)footerView:(ZKTableHelperFooterBlock)block;
- (void)footerTitle:(ZKTableHelperTitleFooterBlock)block;

- (void)numberOfSections:(ZKTableHelperNumberOfSectionsBlock)block;
/**
 *  @brief  NumberOfRowsInSection
 */
- (void)numberOfRowsInSection:(ZKTableHelperNumberRowsBlock)block;

/**
 *  @brief  处理获取当前模型
 */
- (void)currentModelIndexPath:(ZKTableHelperCurrentModelAtIndexPathBlock)block;

/**
 滚动结束回调
 */
- (void)didScrollViewDidEndScrolling:(ZKTableHelperScrollViewDidEndScrollingBlock)block;

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
 @param section 分组下标
 */
- (void)kai_reloadGroupDataAry:(NSArray *)newDataAry
                    forSection:(NSInteger)section;

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
 *  @param section   下标
 *                    如下标为-1 是往前插入
 */
- (void)kai_insertGroupDataAry:(NSArray *)newDataAry
                    forSection:(NSInteger)section;

/**
 *  @brief  插入多条分组数据
 *
 *  @param newDataAry 数据源
 *  @param section   下标
 *                    如下标为-1 是往前插入
 */
- (void)kai_insertMultiplGroupDataAry:(NSArray *)newDataAry
                           forSection:(NSInteger)section;

/**
 删除分组数据
 
 @param section 分组下标
 */
- (void)kai_deleteGroupData:(NSInteger)section;

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
 *  @param section   分组数
 */
- (void)kai_resetDataAry:(NSArray *)newDataAry forSection:(NSInteger)section;

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
 *  @param section   分组数
 */
- (void)kai_reloadDataAry:(NSArray *)newDataAry forSection:(NSInteger)section;

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
 *  @param section   分组数
 */
- (void)kai_addDataAry:(NSArray *)newDataAry forSection:(NSInteger)section;

/**
 *  @brief  单个添加
 *
 *  @param obj     数据模型
 *  @param cIndexPath 下标位置
 */
- (void)kai_insertData:(id)obj atIndex:(NSIndexPath *)cIndexPath;

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


- (NSString *)identifierForRowAtIndexPath:(NSIndexPath *)indexPath;
- (id)currentModel;
- (id)currentModelAtIndexPath:(NSIndexPath *)cIndexPath;
- (void)configureCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath withObjet:(id)obj;

@end


NS_ASSUME_NONNULL_END
