//
//  ZKCollectionViewAdapter.h
//  ZKFoundation
//
//  Created by Kaiser on 2019/3/12.
//

#import <Foundation/Foundation.h>
#import <ZKCategories/ZKCategories.h>
#import "ZKScrollViewAdapter.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ZKCollectionViewAdapterInjectionDelegate;

typedef NSString *_Nullable (^ZKCollectionAdapterCellIdentifierForItemAtIndexPathBlock)(NSIndexPath *indexPath, id dataSource);
typedef NSString *_Nullable (^ZKCollectionAdapterHeaderIdentifierBlock)(NSIndexPath *indexPath, id dataSource);
typedef NSString *_Nullable (^ZKCollectionAdapterFooterIdentifierBlock)(NSIndexPath *indexPath, id dataSource);
typedef CGFloat (^ZKCollectionAdapterItemAutoHeightForRowBlock)(UICollectionView *collectionView, NSIndexPath *indexPath, NSString *identifier, id dataSource);

typedef NSInteger (^ZKCollectionAdapterNumberOfItemsInSectionBlock)(UICollectionView *collectionView, NSInteger section, id dataSource);

typedef UICollectionReusableView *_Nullable (^ZKCollectionAdapterHeaderViewBlock)(UICollectionView *collectionView, NSString *kind, NSString *cellIdentifier, NSIndexPath *indexPath, id dataSource);
typedef UICollectionReusableView *_Nullable (^ZKCollectionAdapterFooterViewBlock)(UICollectionView *collectionView, NSString *kind, NSString *cellIdentifier, NSIndexPath *indexPath, id dataSource);

typedef void (^ZKCollectionAdapterDidSelectItemAtIndexPathBlock)(UICollectionView *collectionView, NSIndexPath *indexPath, id dataSource);
typedef void (^ZKCollectionAdapterCellForItemAtIndexPathBlock)(__kindof UICollectionViewCell *cell, NSIndexPath *indexPath, id dataSource, BOOL IsCelldisplay);
typedef void (^ZKCollectionAdapterHeaderForItemAtIndexPathBlock)(__kindof UICollectionReusableView *header, NSIndexPath *indexPath, id _Nullable dataSource, BOOL IsCelldisplay);
typedef void (^ZKCollectionAdapterFooterForItemAtIndexPathBlock)(__kindof UICollectionReusableView *footer, NSIndexPath *indexPath, id _Nullable dataSource, BOOL IsCelldisplay);

typedef CGSize (^ZKCollectionAdapterCellForItemSizeBlock)(UICollectionView *collectionView, UICollectionViewLayout *layout, NSIndexPath *indexPath, id _Nullable dataSource);
typedef CGSize (^ZKCollectionAdapterReferenceHeaderSizeBlock)(UICollectionView *collectionView, UICollectionViewLayout *layout, NSInteger section, id _Nullable dataSource);
typedef CGSize (^ZKCollectionAdapterReferenceFooterSizeBlock)(UICollectionView *collectionView, UICollectionViewLayout *layout, NSInteger section, id _Nullable dataSource);

typedef UIEdgeInsets (^ZKCollectionAdapterInsetForSectionAtIndexBlock)(UICollectionView *collectionView, UICollectionViewLayout *layout, NSInteger section, id _Nullable dataSource);
typedef CGFloat (^ZKCollectionAdapterMinimumInteritemSpacingForSectionBlock)(UICollectionView *collectionView, UICollectionViewLayout *layout, NSInteger section, id _Nullable dataSource);
typedef CGFloat (^ZKCollectionAdapterMinimumLineSpacingForSectionBlock)(UICollectionView *collectionView, UICollectionViewLayout *layout, NSInteger section, id _Nullable dataSource);

typedef id _Nullable (^ZKCollectionAdapterFlattenMapBlock)(id dataAry, NSIndexPath *indexPath);
typedef id _Nullable (^ZKCollectionAdapterCurrentHeaderModelAtIndexPathBlock)(id dataAry, NSIndexPath *indexPath);
typedef id _Nullable (^ZKCollectionAdapterCurrentFooterModelAtIndexPathBlock)(id dataAry, NSIndexPath *indexPath);

@interface ZKCollectionViewAdapter : ZKScrollViewAdapter

/** 当前数据源（只读）。单 section 时返回该 section 的数组，多 section 时返回二维数组 */
@property (nonatomic, readonly) NSMutableArray *dataSource;
/** 当前 Header 数据源（只读），与 section 一一对应 */
@property (nonatomic, readonly) NSMutableArray *headerSource;
/** 当前 Footer 数据源（只读），与 section 一一对应 */
@property (nonatomic, readonly) NSMutableArray *footerSource;

/** 默认 section 头部参考尺寸 */
@property (nonatomic, assign) CGSize titleHeaderSize;
/** 默认 section 尾部参考尺寸 */
@property (nonatomic, assign) CGSize titleFooterSize;

/** 与 registerNibs 对应：每个元素表示该下标是否用 XIB 注册 cell（NSNumber boolValue） */
@property (nonatomic, strong) NSArray *kai_cellXIB;

/** 与 registerNibHeaders 对应：每个元素表示该下标是否用 XIB 注册 Header */
@property (nonatomic, strong) NSArray *kai_cellHeaderXIB;

/** 与 registerNibFooters 对应：每个元素表示该下标是否用 XIB 注册 Footer */
@property (nonatomic, strong) NSArray *kai_cellFooterXIB;

/** 绑定的 UICollectionView，由外部设置 */
@property (nonatomic, weak) UICollectionView *kai_collectionView;
/** 当前选中的 indexPath，在 didSelectItem 时更新 */
@property (nonatomic, strong) NSIndexPath *kai_indexPath;

/** 当前使用的 cell 复用标识符 */
@property (nonatomic, copy) NSString *cellIdentifier;
/** 当前使用的 Header 复用标识符 */
@property (nonatomic, copy) NSString *headerIdentifier;
/** 当前使用的 Footer 复用标识符 */
@property (nonatomic, copy) NSString *footerIdentifier;

/** 批量注册 cell：传入 class 名或 nib 名，配合 kai_cellXIB 区分用 nib 还是 class 注册 */
- (void)registerNibs:(NSArray<NSString *> *)cellNibNames;

/** 批量注册 Header  SupplementaryView：传入 class 名或 nib 名 */
- (void)registerNibHeaders:(NSArray<NSString *> *)cellNibNames;

/** 批量注册 Footer SupplementaryView：传入 class 名或 nib 名 */
- (void)registerNibFooters:(NSArray<NSString *> *)cellNibNames;

#pragma mark - :. Handler

/** 根据 indexPath 与模型返回 cell 复用标识符 */
- (NSString *)cellIdentifierForRowAtIndexPath:(NSIndexPath *)indexPath model:(id)cModel;

/** 指定 section 对应的 section 级模型（通常取该 section 第一条数据） */
- (id)currentSectionModel:(NSInteger)section;

/** 当前选中 item 对应的模型（即 kai_indexPath 处的数据） */
- (id)currentModel;

/** 指定 indexPath 对应的数据模型 */
- (id)currentModelAtIndexPath:(NSIndexPath *)indexPath;
/** 指定 indexPath 对应 section 的 Footer 模型 */
- (id)currentFooterModelAtIndexPath:(NSIndexPath *)indexPath;
/** 配置 cell：若 cell 遵循 ZKCollectionViewAdapterInjectionDelegate 则调用 bindViewModel:forItemAtIndexPath: */
- (void)configureCell:(UICollectionViewCell<ZKCollectionViewAdapterInjectionDelegate> *)cell forIndexPath:(NSIndexPath *)indexPath withObject:(id)obj;

#pragma mark :. Group

/** 用二维数组整体替换分组数据并刷新（已弃用，请用 stripAdapterGroupData:） */
- (void)kai_reloadGroupDataAry:(NSArray *)data ZK_API_DEPRECATED(-stripAdapterGroupData:);
/** 用二维数组整体替换分组数据并刷新，data 每个元素为一组的数据源 */
- (void)stripAdapterGroupData:(NSArray *)data;

/** 在末尾追加一个 section */
- (void)appendSection:(NSArray *)data;

/** 在指定位置插入一个 section；section 为 -1 表示插入到最前面 */
- (void)insertSection:(NSArray *)data
           forSection:(NSInteger)section;

/** 在指定位置连续插入多个 section；section 为 -1 表示从最前面开始插入 */
- (void)insertSections:(NSArray *)data
            forSection:(NSInteger)section;

#pragma mark :.

/** 清空并设置单 section 数据，等价于 stripAdapterData:forSection:0 */
- (void)stripAdapterData:(NSArray *)data;
/** 用 data 替换指定 section 的数据并刷新（不增删 section） */
- (void)stripAdapterData:(NSArray *)data forSection:(NSInteger)section;

/** 用 data 替换 section 0 的数据并刷新 */
- (void)reloadItems:(NSArray *)data;
/** 用 data 替换指定 section 的数据并刷新（若 section 不存在会先补齐） */
- (void)reloadItems:(NSArray *)data forSection:(NSInteger)section;

/** 在 section 0 末尾批量插入 item */
- (void)insertItems:(NSArray *)data;
/** 在指定 section 末尾批量插入 item，section 不存在时会先补齐 */
- (void)insertItems:(NSArray *)data forSection:(NSInteger)section;
/** 在指定 indexPath 位置插入一条数据，row 不能大于当前该 section 的 item 数（可等于表示插在末尾） */
- (void)insertItem:(id)cModel forIndexPath:(NSIndexPath *)indexPath;

/** 删除指定 indexPath 的 item */
- (void)deleteItemAtIndexPath:(NSIndexPath *)indexPath;

/** 用 model 替换指定 indexPath 的数据并刷新该 item */
- (void)reloadItem:(id)model
      forIndexPath:(NSIndexPath *)indexPath;

#pragma mark - :. Header

/** 用 data 整体替换 Header 数据源（与 section 一一对应） */
- (void)reloadHeaderData:(NSArray *)data;

/** 在 Header 数据源末尾追加 */
- (void)insertHeaderData:(NSArray *)data;
/** 从指定 section 下标起插入若干 Header 数据，cSection 不能大于当前 header 数量 */
- (void)insertHeaderData:(NSArray *)data
              forSection:(NSInteger)section;

/** 删除指定下标的 Header 数据 */
- (void)removeHeaderData:(NSInteger)section;

/** 指定 indexPath 对应 section 的 Header 模型 */
- (id)currentHeaderModelAtIndexPath:(NSIndexPath *)indexPath;

#pragma mark - :. Footer

/** 用 data 整体替换 Footer 数据源（与 section 一一对应） */
- (void)reloadFooterData:(NSArray *)data;

/** 在 Footer 数据源末尾追加 */
- (void)insertFooterData:(NSArray *)data;
/** 从指定 section 下标起插入若干 Footer 数据，cSection 不能大于当前 footer 数量 */
- (void)insertFooterData:(NSArray *)data
              forSection:(NSInteger)section;

/** 删除指定下标的 Footer 数据 */
- (void)removeFooterData:(NSInteger)section;

#pragma mark - :. Block事件

/** 设置动态计算 item 尺寸的 block（如高度/宽度） */
- (void)autoHeightItem:(ZKCollectionAdapterItemAutoHeightForRowBlock)block;

/** 设置每个 section 的内边距（inset） */
- (void)insetForSectionAtIndex:(ZKCollectionAdapterInsetForSectionAtIndexBlock)block;
/** 设置同一行内左右两个 item 之间的最小间距 */
- (void)minimumInteritemSpacingForSection:(ZKCollectionAdapterMinimumInteritemSpacingForSectionBlock)block;
/** 设置上下两行 item 之间的最小间距 */
- (void)minimumLineSpacingForSection:(ZKCollectionAdapterMinimumLineSpacingForSectionBlock)block;

/** 多种 cell 时，通过 block 按 indexPath 与数据返回对应的 cell 复用标识符 */
- (void)cellIdentifierForItemAtIndexPath:(ZKCollectionAdapterCellIdentifierForItemAtIndexPathBlock)block;
/** 设置按 indexPath 与数据返回 Header 复用标识符的 block */
- (void)headerIdentifier:(ZKCollectionAdapterHeaderIdentifierBlock)block;
/** 设置按 indexPath 与数据返回 Footer 复用标识符的 block */
- (void)footerIdentifier:(ZKCollectionAdapterFooterIdentifierBlock)block;

/** 根据业务将「数据源 + indexPath」映射为要展示的模型，用于扁平或重组数据结构 */
- (void)flattenMap:(ZKCollectionAdapterFlattenMapBlock)block;

/** 设置每个 section 的 item 数量计算方式（不设则使用该 section 数据源的元素个数） */
- (void)numberOfItemsInSection:(ZKCollectionAdapterNumberOfItemsInSectionBlock)block;

/** 设置返回自定义 Header 视图的 block */
- (void)headerView:(ZKCollectionAdapterHeaderViewBlock)block;
/** 设置按数据源与 indexPath 返回当前 Header 模型的 block */
- (void)currentHeaderModel:(ZKCollectionAdapterCurrentHeaderModelAtIndexPathBlock)block;
/** 设置返回自定义 Footer 视图的 block */
- (void)footerView:(ZKCollectionAdapterFooterViewBlock)block;
/** 设置按数据源与 indexPath 返回当前 Footer 模型的 block */
- (void)currentFooterModel:(ZKCollectionAdapterCurrentFooterModelAtIndexPathBlock)block;

/** 设置 cell 即将/已显示时的回调（可用于绑定数据、曝光等） */
- (void)cellForItemAtIndexPath:(ZKCollectionAdapterCellForItemAtIndexPathBlock)block;
/** 设置 Header 即将/已显示时的回调 */
- (void)headerForItemAtIndexPath:(ZKCollectionAdapterHeaderForItemAtIndexPathBlock)block;
/** 设置 Footer 即将/已显示时的回调 */
- (void)footerForItemAtIndexPath:(ZKCollectionAdapterFooterForItemAtIndexPathBlock)block;

/** 设置每个 item 的尺寸 */
- (void)sizeForItemAtIndexPath:(ZKCollectionAdapterCellForItemSizeBlock)block;
/** 设置每个 section Header 的参考尺寸 */
- (void)referenceHeaderSize:(ZKCollectionAdapterReferenceHeaderSizeBlock)block;
/** 设置每个 section Footer 的参考尺寸 */
- (void)referenceFooterSize:(ZKCollectionAdapterReferenceFooterSizeBlock)block;

/** 设置 item 选中回调；若子类重写 collectionView:didSelectItemAtIndexPath: 则本回调可能不触发 */
- (void)didSelectItem:(ZKCollectionAdapterDidSelectItemAtIndexPathBlock)block;

@end

/** 支持 section Header 悬停的 FlowLayout（常用于导航栏下方吸顶效果） */
@interface ZKCollectionViewFlowLayout : UICollectionViewFlowLayout

/** 导航栏高度偏移，默认为 64.0，用于计算 Header 悬停位置 */
@property (nonatomic, assign) CGFloat naviHeight;

@end


NS_ASSUME_NONNULL_END
