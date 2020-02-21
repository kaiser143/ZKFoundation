//
//  ZKTableViewHelper.h
//  ZKFoundation
//
//  Created by Kaiser on 2019/3/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern CGFloat ZKAutoHeightForHeaderFooterView;

typedef NSString *_Nullable (^ZKTableAdapterCellIdentifierForRowBlock)(NSIndexPath *indexPath, id dataSource);
typedef void (^ZKTableAdapterDidSelectBlock)(UITableView *tableView, NSIndexPath *indexPath, id dataSource);
typedef void (^ZKTableAdapterDidDeSelectBlock)(UITableView *tableView, NSIndexPath *indexPath, id dataSource);
typedef CGFloat (^ZKTableAdapterCellAutoHeightForRowBlock)(UITableView *tableView, NSIndexPath *indexPath, NSString *identifier, id dataSource);

typedef void (^ZKTableAdapterDidMoveToRowBlock)(UITableView *tableView, NSIndexPath *sourceIndexPath, id sourceModel, NSIndexPath *destinationIndexPath, id destinationModel);

typedef void (^ZKTableAdapterDidWillDisplayBlock)(__kindof UITableViewCell *cell, NSIndexPath *indexPath, id dataSource, BOOL IsCelldisplay);

typedef void (^ZKTableAdapterDidEditingBlock)(UITableView *tableView, UITableViewCellEditingStyle editingStyle, NSIndexPath *indexPath, id dataSource);
typedef NSString *_Nullable (^ZKTableAdapterDidEditTitleBlock)(UITableView *tableView, NSIndexPath *indexPath, id dataSource);

typedef BOOL (^ZKTableAdapterCanEditRowAtIndexPathBlock)(NSIndexPath *indexPath, id dataSource);
typedef UITableViewCellEditingStyle (^ZKTableAdapterEditingStyleBlock)(UITableView *tableView, NSIndexPath *indexPath, id dataSource);
typedef NSArray<UITableViewRowAction *> *_Nullable (^ZKTableAdapterDidEditActionsBlock)(UITableView *tableView, NSIndexPath *indexPath, id dataSource);

typedef void (^ZKScrollViewWillBeginDraggingBlock)(UIScrollView *scrollView);
typedef void (^ZKScrollViewDidScrollBlock)(UIScrollView *scrollView);
typedef void (^ZKScrollViewDidEndDraggingBlock)(UIScrollView *scrollView);

typedef __kindof UITableViewHeaderFooterView *_Nullable (^ZKTableAdapterHeaderBlock)(UITableView *tableView, NSInteger section, id dataSource);
typedef __kindof UITableViewHeaderFooterView *_Nullable (^ZKTableAdapterFooterBlock)(UITableView *tableView, NSInteger section, id dataSource);

typedef UITableViewCellAccessoryType(^ZKTableAdapterAccessoryTypeBlock)(UITableView *tableView, NSIndexPath *indexPath, id dataSource);
typedef void(^ZKTableAdapterAccessoryButtonTappedForRowAtIndexPathBlock)(NSIndexPath *indexPath, id dataSource);

typedef CGFloat (^ZKTableAdapterHeightForHeaderBlock)(UITableView *tableView, NSInteger section, id dataSource);
typedef CGFloat (^ZKTableAdapterHeightForFooterBlock)(UITableView *tableView, NSInteger section, id dataSource);

typedef NSString *_Nullable (^ZKTableAdapterTitleHeaderBlock)(UITableView *tableView, NSInteger section);
typedef NSString *_Nullable (^ZKTableAdapterTitleFooterBlock)(UITableView *tableView, NSInteger section);

typedef NSInteger (^ZKTableAdapterNumberOfSectionsBlock)(UITableView *tableView, NSInteger count);
typedef NSInteger (^ZKTableAdapterNumberRowsBlock)(UITableView *tableView, NSInteger section, NSArray *dataSource);
typedef id _Nullable (^ZKTableAdapterFlattenMapBlock)(id dataSource, NSIndexPath *indexPath);

typedef void (^ZKTableAdapterScrollViewDidEndScrollingBlock)(UIScrollView *scrollView);

@interface ZKTableViewAdapter : NSObject <UITableViewDataSource, UITableViewDelegate>

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

/**
 * @brief section HeaderView 是否悬停 (默认悬停) YES: 不悬停
 *  UITableViewStylePlain 模式下
 */
@property (nonatomic, assign) BOOL isHover;

// default is NO. Controls whether multiple rows can be selected simultaneously in editing
@property (nonatomic) BOOL allowsMultipleSelectionDuringEditing NS_AVAILABLE_IOS(5_0);

/**
 *  When using the storyboard and a single cell, set the property inspector same identifier
 */
@property (nullable, nonatomic, copy, readonly) NSString *cellIdentifier;
@property (nullable, nonatomic, copy, readonly) NSString *headerFooterIdentifier;

@property (nonatomic, strong) NSArray *kai_cellXIB;

@property (nonatomic, weak) UITableView *kai_tableView;
@property (nonatomic, strong) NSIndexPath *kai_indexPath;

/**
 *  When using xib, all incoming nib names
 */
- (void)registerNibs:(NSArray<NSString *> *)nibs;
- (void)registerHeaderFooterViewNibs:(NSArray<NSString *> *)nibs;

- (UITableViewHeaderFooterView *)tableViewSectionViewWithIdentifier:(NSString *)identifier
                                                            section:(NSInteger)section;

#pragma mark - :. Block事件

/*!
 *  @brief    动态计算高度cell的高度并返回
 */
- (void)autoHeightCell:(ZKTableAdapterCellAutoHeightForRowBlock)block;

/**
 *  When there are multiple cell, returned identifier in block
 */
- (void)cellIdentifierForRowAtIndexPath:(ZKTableAdapterCellIdentifierForRowBlock)block;

/**
 *  If you override tableView:didSelectRowAtIndexPath: method, it will be invalid
 */
- (void)didSelect:(ZKTableAdapterDidSelectBlock)block;

/**
 *  If you override tableView:didDeselectRowAtIndexPath: method, it will be invalid
 */
- (void)didDeSelect:(ZKTableAdapterDidDeSelectBlock)block;

/*!
 *  @brief    是否可编辑
 */
- (void)canEditRow:(ZKTableAdapterCanEditRowAtIndexPathBlock)block;

/**
 *  @brief 编辑样式
 */
- (void)didEditingStyle:(ZKTableAdapterEditingStyleBlock)block;

/**
 *  @brief  cell侧滑编辑事件
 */
- (void)didEditing:(ZKTableAdapterDidEditingBlock)block;
/**
 *  @brief  cell侧滑标题
 */
- (void)didEditTitle:(ZKTableAdapterDidEditTitleBlock)block;

/**
 *  @brief  cell侧滑菜单
 */
- (void)didEditActions:(ZKTableAdapterDidEditActionsBlock)block;

/**
 移动Cell
 */
- (void)didMoveToRowBlock:(ZKTableAdapterDidMoveToRowBlock)block;

/**
 *  @brief 设置Cell显示
 */
- (void)cellWillDisplay:(ZKTableAdapterDidWillDisplayBlock)block;

- (void)didScrollViewWillBeginDragging:(ZKScrollViewWillBeginDraggingBlock)block;
- (void)didScrollViewDidScroll:(ZKScrollViewDidScrollBlock)block;
- (void)didScrollViewEndDragging:(ZKScrollViewDidEndDraggingBlock)block;

/**
 *  @brief  Header视图
 */
- (void)headerView:(ZKTableAdapterHeaderBlock)block;
- (void)headerTitle:(ZKTableAdapterTitleHeaderBlock)block;
- (void)heightForHeaderView:(ZKTableAdapterHeightForHeaderBlock)block;

/*!
 *  @brief accessory
 */
- (void)accessoryType:(ZKTableAdapterAccessoryTypeBlock)block;
- (void)accessoryButtonTappedForRow:(ZKTableAdapterAccessoryButtonTappedForRowAtIndexPathBlock)block;

/**
 *  @brief  Footer视图
 */
- (void)footerView:(ZKTableAdapterFooterBlock)block;
- (void)footerTitle:(ZKTableAdapterTitleFooterBlock)block;
- (void)heightForFooterView:(ZKTableAdapterHeightForFooterBlock)block;

- (void)numberOfSections:(ZKTableAdapterNumberOfSectionsBlock)block;
/**
 *  @brief  NumberOfRowsInSection
 */
- (void)numberOfRowsInSection:(ZKTableAdapterNumberRowsBlock)block;

/**
 *  @brief  根据业务需求，返回一个自定义数据
 */
- (void)flattenMap:(ZKTableAdapterFlattenMapBlock)block;

/**
 滚动结束回调
 */
- (void)didScrollViewDidEndScrolling:(ZKTableAdapterScrollViewDidEndScrollingBlock)block;

#pragma mark - :. Handler

/**
 *  @brief 显示分组数据
 *
 *  @param data 数据源
 */
- (void)kai_reloadGroupDataAry:(NSArray *)data;

/**
 重新加载该分组数据
 
 @param data 分组数据
 @param section 分组下标
 */
- (void)kai_reloadGroupDataAry:(NSArray *)data
                    forSection:(NSInteger)section;

/**
 *  @brief  添加分组数据
 *
 *  @param data 数据源
 */
- (void)appendSection:(NSArray *)data;

/**
 *  @brief  插入分组数据
 *
 *  @param data 数据源
 *  @param section   下标
 *                    如下标为-1 是往前插入
 */
- (void)insertSection:(nonnull NSArray *)data
           forSection:(NSInteger)section;

/**
 *  @brief  插入多条分组数据
 *
 *  @param data 数据源
 *  @param section   下标
 *                    如下标为-1 是往前插入
 */
- (void)insertSections:(NSArray *)data
            forSection:(NSInteger)section;

/**
 删除分组数据
 
 @param section 分组下标
 */
- (void)deleteSection:(NSInteger)section;

#pragma mark - :. Plain
/**
 *  @brief  显示数据
 *
 *  @param data 数据源
 */
- (void)stripAdapterData:(NSArray *)data;

/**
 *  @brief  显示数据
 *
 *  @param data 数据源
 *  @param section   分组数
 */
- (void)stripAdapterData:(NSArray *)data forSection:(NSInteger)section;

/**
 *  @brief  刷新并加入新数据
 *
 *  @param data 数据源
 */
- (void)reloadData:(NSArray *)data;

/**
 *  @brief  刷新并加入新数据
 *
 *  @param data 数据源
 *  @param section   分组数
 */
- (void)reloadData:(NSArray *)data forSection:(NSInteger)section;

/**
 *  @brief  批量添加数据  insertRows:data forSection:0
 *  @param data 数据源
 */
- (void)insertRows:(NSArray *)data;
/**
 *  @brief  批量添加
 *
 *  @param data 数据源
 *  @param section   分组数
 */
- (void)insertRows:(NSArray *)data forSection:(NSInteger)section;

/**
 *  @brief  单个添加
 *
 *  @param obj     数据模型
 *  @param indexPath 下标位置
 */
- (void)insertData:(id)obj forIndexPath:(NSIndexPath *)indexPath;

/**
 *  @brief 替换数据对象
 *
 *  @param model      对象
 *  @param indexPath 下标位置
 */
- (void)reloadData:(id)model
      forIndexPath:(NSIndexPath *)indexPath;

- (void)reloadData:(id)model
      forIndexPath:(NSIndexPath *)indexPath
         animation:(UITableViewRowAnimation)animated;

/**
 *  @brief  根据下标删除数据
 *
 *  @param indexPath 下标位置
 */
- (void)deleteRowsAtIndexPath:(NSIndexPath *)indexPath;
- (void)deleteRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;

- (nullable NSArray *)modelsForSelectedRows;    // 通过 allowsMultipleSelectionDuringEditing 选中的对象
- (id)currentModel;                             // [self currentModelAtIndexPath:self.kai_indexPath];
- (id)currentModelAtIndexPath:(NSIndexPath *)indexPath;
- (void)configureCell:(__kindof UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath withObject:(id)obj;

@end


NS_ASSUME_NONNULL_END
