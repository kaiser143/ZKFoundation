//
//  ZKTableViewAdapter.h
//  ZKFoundation
//
//  Created by Kaiser on 2019/3/12.
//

#import <Foundation/Foundation.h>
#import "ZKScrollViewAdapter.h"
#import <ZKCategories/ZKCategories.h>

NS_ASSUME_NONNULL_BEGIN

/** 用于表示 Header/Footer 自动计算高度的占位值，通常与自动布局配合使用 */
extern CGFloat ZKAutoHeightForHeaderFooterView;

typedef NSString *_Nullable (^ZKTableAdapterCellIdentifierForRowBlock)(NSIndexPath *indexPath, id dataSource);
typedef void (^ZKTableAdapterDidSelectRowBlock)(UITableView *tableView, NSIndexPath *indexPath, id dataSource);
typedef void (^ZKTableAdapterDidDeselectRowBlock)(UITableView *tableView, NSIndexPath *indexPath, id dataSource);
typedef CGFloat (^ZKTableAdapterCellAutoHeightForRowBlock)(UITableView *tableView, NSIndexPath *indexPath, NSString *identifier, id dataSource);

typedef void (^ZKTableAdapterMoveRowBlock)(UITableView *tableView, NSIndexPath *sourceIndexPath, id sourceModel, NSIndexPath *destinationIndexPath, id destinationModel);

typedef void (^ZKTableAdapterCellWillDisplayBlock)(__kindof UITableViewCell *cell, NSIndexPath *indexPath, id _Nullable dataSource, BOOL isCellDisplay);
typedef void(^ZKTableAdapterHeaderWillDisplayBlock)(__kindof UIView *view, NSInteger section, id dataSource);
typedef void(^ZKTableAdapterFooterWillDisplayBlock)(__kindof UIView *view, NSInteger section, id dataSource);

typedef void (^ZKTableAdapterCommitEditingStyleForRowBlock)(UITableView *tableView, UITableViewCellEditingStyle editingStyle, NSIndexPath *indexPath, id dataSource);
typedef NSString *_Nullable (^ZKTableAdapterTitleForDeleteConfirmationButtonForRowBlock)(UITableView *tableView, NSIndexPath *indexPath, id dataSource);

typedef BOOL (^ZKTableAdapterCanEditRowAtIndexPathBlock)(NSIndexPath *indexPath, id dataSource);
typedef UITableViewCellEditingStyle (^ZKTableAdapterEditingStyleForRowBlock)(UITableView *tableView, NSIndexPath *indexPath, id dataSource);
typedef NSArray<UITableViewRowAction *> *_Nullable (^ZKTableAdapterEditActionsForRowBlock)(UITableView *tableView, NSIndexPath *indexPath, id dataSource);

typedef __kindof UITableViewHeaderFooterView *_Nullable (^ZKTableAdapterHeaderBlock)(UITableView *tableView, NSInteger section, id _Nullable dataSource);
typedef __kindof UITableViewHeaderFooterView *_Nullable (^ZKTableAdapterFooterBlock)(UITableView *tableView, NSInteger section, id _Nullable dataSource);

typedef UITableViewCellAccessoryType(^ZKTableAdapterAccessoryTypeBlock)(UITableView *tableView, NSIndexPath *indexPath, id dataSource);
typedef void(^ZKTableAdapterAccessoryButtonTappedForRowAtIndexPathBlock)(NSIndexPath *indexPath, id dataSource);

typedef CGFloat (^ZKTableAdapterHeightForHeaderBlock)(UITableView *tableView, NSInteger section, id _Nullable dataSource);
typedef CGFloat (^ZKTableAdapterHeightForFooterBlock)(UITableView *tableView, NSInteger section, id _Nullable dataSource);

typedef NSString *_Nullable (^ZKTableAdapterTitleHeaderBlock)(UITableView *tableView, NSInteger section);
typedef NSString *_Nullable (^ZKTableAdapterTitleFooterBlock)(UITableView *tableView, NSInteger section);

typedef NSInteger (^ZKTableAdapterNumberOfSectionsBlock)(UITableView *tableView, NSInteger count);
typedef NSInteger (^ZKTableAdapterNumberRowsBlock)(UITableView *tableView, NSInteger section, NSArray *dataSource);
typedef id _Nullable (^ZKTableAdapterFlattenMapBlock)(id dataSource, NSIndexPath *indexPath);

@interface ZKTableViewAdapter : ZKScrollViewAdapter

/** 当前数据源（只读）。单 section 时返回该 section 的数组，多 section 时返回二维数组 */
@property (nonatomic, readonly) NSMutableArray *dataSource;
/** 侧边索引标题数组，用于 section index 显示（如 A、B、C…） */
@property (nonatomic, copy) NSArray *sectionIndexTitle;

/**
 *  分组头部区域高度，默认：0.001（iOS 15+ 为 0）
 */
@property (nonatomic, assign) CGFloat titleHeaderHeight;
/** 分组头部与上一组之间的间距高度 */
@property (nonatomic, assign) CGFloat titleHeaderSpacingHeight;

/**
 *  分组尾部区域高度，默认：0.001（iOS 15+ 为 0）
 */
@property (nonatomic, assign) CGFloat titleFooterHeight;
/** 分组尾部与下一组之间的间距高度 */
@property (nonatomic, assign) CGFloat titleFooterSpacingHeight;

/**
 *  是否将分割线延伸到整个 cell 宽度（默认 NO 不延伸）
 */
@property (nonatomic, assign) BOOL paddedSeparator;

/**
 *  是否在列表右侧显示字母索引（如通讯录 A-Z）
 */
@property (nonatomic, assign) BOOL allowsSideLetterPresentation;

/**
 *  是否允许通过拖拽移动行（需配合 moveRowBlock 使用）
 */
@property (nonatomic, assign) BOOL isCanMoveRow;

/**
 *  是否开启防重复点击（默认 NO）。开启后会在短时间间隔内忽略重复选中
 */
@property (nonatomic, assign) BOOL isAntiHurry;

/**
 *  section 的 Header 是否不悬停（仅 UITableViewStylePlain 有效）。默认 NO 表示悬停；YES 表示不悬停、随列表一起滚动
 */
@property (nonatomic, assign) BOOL isHover;

/** 编辑模式下是否允许多选行，默认 NO */
@property (nonatomic) BOOL allowsMultipleSelectionDuringEditing NS_AVAILABLE_IOS(5_0);

/**
 *  是否开启预估行高/区头区尾高度（estimatedRowHeight 等）。
 *  iOS 11+ 设为 UITableViewAutomaticDimension 即会启用预估，可能导致 contentSize 等计算不准确，可通过本属性统一关闭
 */
@property (nonatomic, assign) BOOL estimatedHeightEnable;

/** 当前使用的 cell 复用标识符（只读）。使用 Storyboard 且仅有一种 cell 时，需在属性检查器中设置相同 identifier */
@property (nullable, nonatomic, copy, readonly) NSString *cellIdentifier;
/** 当前使用的 Header/Footer 复用标识符（只读） */
@property (nullable, nonatomic, copy, readonly) NSString *headerFooterIdentifier;

/** 与 registerNibs 对应：每个元素表示该下标是否用 XIB 注册（NSNumber boolValue） */
@property (nonatomic, strong) NSArray *kai_cellXIB;

/** 绑定的 UITableView，由外部设置 */
@property (nonatomic, weak) UITableView *kai_tableView;
/** 当前选中的 indexPath，在 didSelect/didDeselect 时更新 */
@property (nonatomic, strong) NSIndexPath *kai_indexPath;

/** 批量注册 cell：传入 class 名或 nib 名，配合 kai_cellXIB 区分用 nib 还是 class 注册 */
- (void)registerNibs:(NSArray<NSString *> *)nibs;
/** 批量注册 Header/Footer 视图：传入 class 名或 nib 名，配合 kai_cellXIB 区分用 nib 还是 class 注册 */
- (void)registerHeaderFooterViewNibs:(NSArray<NSString *> *)nibs;

/** 根据 identifier 和 section 获取或创建可复用的 section 头部/尾部视图（用于侧边字母索引等场景） */
- (UITableViewHeaderFooterView *)tableViewSectionViewWithIdentifier:(NSString *)identifier
                                                            section:(NSInteger)section;

#pragma mark - :. Block事件

/** 设置动态计算行高的 block，常与 UITableView+FDTemplateLayoutCell 等方案配合；使用后建议将 estimatedRowHeight 设为 0，可通过 estimatedHeightEnable 统一控制 */
- (void)autoHeightCell:(ZKTableAdapterCellAutoHeightForRowBlock)block;

/** 多种 cell 时，通过 block 按 indexPath 与数据返回对应的 cell 复用标识符 */
- (void)cellIdentifierForRowAtIndexPath:(ZKTableAdapterCellIdentifierForRowBlock)block;

/** 设置行选中回调；若子类重写 tableView:didSelectRowAtIndexPath: 则本回调不会触发 */
- (void)didSelectRow:(ZKTableAdapterDidSelectRowBlock)block;

/** 设置行取消选中回调；若子类重写 tableView:didDeselectRowAtIndexPath: 则本回调不会触发 */
- (void)didDeselect:(ZKTableAdapterDidDeselectRowBlock)block;

/** 设置某行是否可编辑（如左滑删除、插入等） */
- (void)canEditRow:(ZKTableAdapterCanEditRowAtIndexPathBlock)block;

/** 设置某行的编辑样式（无 / 删除 / 插入等） */
- (void)editingStyleForRow:(ZKTableAdapterEditingStyleForRowBlock)block;

/** 设置左滑后点击「删除」等按钮时的提交编辑回调 */
- (void)commitEditingStyleForRow:(ZKTableAdapterCommitEditingStyleForRowBlock)block;

/** 设置左滑时删除按钮上显示的文字（如「删除」「移除」） */
- (void)titleForDeleteConfirmationButtonForRow:(ZKTableAdapterTitleForDeleteConfirmationButtonForRowBlock)block;

/** 设置左滑时显示的多个操作按钮（UITableViewRowAction 数组） */
- (void)editActionsForRow:(ZKTableAdapterEditActionsForRowBlock)block;

/** 设置行拖拽移动时的回调，adapter 会先同步内部数据再调用此 block，便于业务做额外处理 */
- (void)moveRowBlock:(ZKTableAdapterMoveRowBlock)block;

/** 设置 cell 即将显示时的回调（可用于曝光统计、预加载等） */
- (void)cellWillDisplay:(ZKTableAdapterCellWillDisplayBlock)block;
/** 设置 section 头部视图即将显示时的回调 */
- (void)headerWillDisplay:(ZKTableAdapterHeaderWillDisplayBlock)block;
/** 设置 section 尾部视图即将显示时的回调 */
- (void)footerWillDisplay:(ZKTableAdapterFooterWillDisplayBlock)block;

/** 设置返回自定义 section 头部视图的 block */
- (void)headerView:(ZKTableAdapterHeaderBlock)block;
/** 设置返回 section 头部纯文本标题的 block（与 headerView 二选一） */
- (void)headerTitle:(ZKTableAdapterTitleHeaderBlock)block;

/** 动态返回 section 头部高度。使用后建议将 estimatedSectionHeaderHeight 设为 0，关闭系统 self-sizing 以免跳动 */
- (void)heightForHeaderView:(ZKTableAdapterHeightForHeaderBlock)block;

/** 设置行右侧附件类型（已弃用，请直接设置 cell 的 accessoryType / editingAccessoryType） */
- (void)accessoryType:(ZKTableAdapterAccessoryTypeBlock)block API_DEPRECATED("请改用 cell 的 accessoryType / editingAccessoryType 属性", ios(2.0, 15.0));
/** 设置行右侧附件按钮（如详情箭头）被点击时的回调 */
- (void)accessoryButtonTappedForRow:(ZKTableAdapterAccessoryButtonTappedForRowAtIndexPathBlock)block;

/** 设置返回自定义 section 尾部视图的 block */
- (void)footerView:(ZKTableAdapterFooterBlock)block;
/** 设置返回 section 尾部纯文本标题的 block（与 footerView 二选一） */
- (void)footerTitle:(ZKTableAdapterTitleFooterBlock)block;

/** 动态返回 section 尾部高度。使用后建议将 estimatedSectionFooterHeight 设为 0，关闭系统 self-sizing 以免跳动 */
- (void)heightForFooterView:(ZKTableAdapterHeightForFooterBlock)block;

/** 设置 section 数量的自定义计算方式（不设则使用内部 data 的 section 数） */
- (void)numberOfSections:(ZKTableAdapterNumberOfSectionsBlock)block;

/** 设置每个 section 的行数计算方式（不设则使用该 section 数据源的元素个数） */
- (void)numberOfRowsInSection:(ZKTableAdapterNumberRowsBlock)block;

/** 根据业务将「数据源 + indexPath」映射为要展示的模型，用于扁平或重组数据结构 */
- (void)flattenMap:(ZKTableAdapterFlattenMapBlock)block;

#pragma mark - :. Handler

/** 用二维数组整体替换分组数据并刷新列表（已弃用，请用 stripAdapterGroupData:） */
- (void)kai_reloadGroupDataAry:(NSArray *)data ZK_API_DEPRECATED(-stripAdapterGroupData:);
/** 用二维数组整体替换分组数据并刷新列表，data 每个元素为一组的数据源 */
- (void)stripAdapterGroupData:(NSArray *)data;

/** 仅重载指定 section 的数据（已弃用，请用 stripAdapterGroupData:forSection:） */
- (void)kai_reloadGroupDataAry:(NSArray *)data
                    forSection:(NSInteger)section ZK_API_DEPRECATED(-stripAdapterGroupData:forSection:);
/** 用 data 替换指定 section 的数据并刷新该 section，section 必须在有效范围内 */
- (void)stripAdapterGroupData:(NSArray *)data forSection:(NSInteger)section;

/** 在末尾追加一个 section，数据为 data */
- (void)appendSection:(NSArray *)data;

/** 在指定位置插入一个 section；section 为 -1 表示插入到最前面 */
- (void)insertSection:(nonnull NSArray *)data
           forSection:(NSInteger)section;

/** 在指定位置连续插入多个 section；section 为 -1 表示从最前面开始插入 */
- (void)insertSections:(NSArray *)data
            forSection:(NSInteger)section;

/** 删除指定下标的 section（同时从数据源移除） */
- (void)deleteSection:(NSInteger)section;

#pragma mark - :. Plain

/** 清空并设置单 section 数据，等价于 stripAdapterData:forSection:0 */
- (void)stripAdapterData:(NSArray *)data;

/** 用 data 替换指定 section 的数据并刷新列表（不增删 section） */
- (void)stripAdapterData:(NSArray *)data forSection:(NSInteger)section;

/** 清空后设置单 section 数据并刷新，等价于 reloadData:forSection:0 */
- (void)reloadData:(NSArray *)data;

/** 用 data 替换指定 section 的数据并刷新（若 section 不存在会先补齐） */
- (void)reloadData:(NSArray *)data forSection:(NSInteger)section;

/** 在 section 0 末尾批量插入行 */
- (void)insertRows:(NSArray *)data;

/** 在指定 section 末尾批量插入行，section 不存在时会先补齐 */
- (void)insertRows:(NSArray *)data forSection:(NSInteger)section;

/** 在指定 indexPath 位置插入一条数据，row 不能大于当前该 section 行数（可等于表示插在末尾） */
- (void)insertData:(id)obj forIndexPath:(NSIndexPath *)indexPath;

/** 用 model 替换指定 indexPath 的数据并刷新该 cell */
- (void)reloadData:(id)model
      forIndexPath:(NSIndexPath *)indexPath;

/** 用 model 替换指定 indexPath 的数据并以指定动画刷新该 cell */
- (void)reloadData:(id)model
      forIndexPath:(NSIndexPath *)indexPath
         animation:(UITableViewRowAnimation)animated;

/** 删除指定 indexPath 的一行 */
- (void)deleteRowsAtIndexPath:(NSIndexPath *)indexPath;
/** 批量删除多个 indexPath 对应的行 */
- (void)deleteRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;

/** 编辑模式下当前选中的行对应的模型数组（需开启 allowsMultipleSelectionDuringEditing） */
- (nullable NSArray *)modelsForSelectedRows;
/** 当前选中行对应的模型（即 kai_indexPath 处的数据） */
- (id)currentModel;
/** 指定 indexPath 对应的数据模型 */
- (id)currentModelAtIndexPath:(NSIndexPath *)indexPath;
/** 配置 cell：若 cell 遵循 ZKTableViewAdapterInjectionDelegate 则调用 bindViewModel:forIndexPath:，子类可重写扩展 */
- (void)configureCell:(__kindof UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath withObject:(id)obj;

@end


NS_ASSUME_NONNULL_END
