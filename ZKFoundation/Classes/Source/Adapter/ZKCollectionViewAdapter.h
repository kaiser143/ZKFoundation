//
//  ZKCollectionViewHelper.h
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

@property (nonatomic, weak, readonly) NSMutableArray *dataSource;
@property (nonatomic, weak, readonly) NSMutableArray *headerSource;
@property (nonatomic, weak, readonly) NSMutableArray *footerSource;

@property (nonatomic, assign) CGSize titleHeaderSize;
@property (nonatomic, assign) CGSize titleFooterSize;

/**
 Cell 是否加载XIB
 */
@property (nonatomic, strong) NSArray *kai_cellXIB;

/**
 Header 是否加载XIB
 */
@property (nonatomic, strong) NSArray *kai_cellHeaderXIB;

/**
 Footer 是否加载XIB
 */
@property (nonatomic, strong) NSArray *kai_cellFooterXIB;
@property (nonatomic, weak) UICollectionView *kai_collectionView;
@property (nonatomic, strong) NSIndexPath *kai_indexPath;

@property (nonatomic, copy) NSString *cellIdentifier;
@property (nonatomic, copy) NSString *headerIdentifier;
@property (nonatomic, copy) NSString *footerIdentifier;

- (void)registerNibs:(NSArray<NSString *> *)cellNibNames;

/**
 Hader集合
 */
- (void)registerNibHeaders:(NSArray<NSString *> *)cellNibNames;

/**
 Footer集合
 */
- (void)registerNibFooters:(NSArray<NSString *> *)cellNibNames;

#pragma mark - :. Handler

- (NSString *)cellIdentifierForRowAtIndexPath:(NSIndexPath *)indexPath model:(id)cModel;

- (id)currentSectionModel:(NSInteger)section;

- (id)currentModel;

- (id)currentModelAtIndexPath:(NSIndexPath *)indexPath;
- (id)currentFooterModelAtIndexPath:(NSIndexPath *)indexPath;
- (void)configureCell:(UICollectionViewCell<ZKCollectionViewAdapterInjectionDelegate> *)cell forIndexPath:(NSIndexPath *)indexPath withObject:(id)obj;

#pragma mark :. Group

- (void)kai_reloadGroupDataAry:(NSArray *)data ZK_API_DEPRECATED(-stripAdapterGroupData:);
- (void)stripAdapterGroupData:(NSArray *)data;

- (void)appendSection:(NSArray *)data;

- (void)insertSection:(NSArray *)data
           forSection:(NSInteger)section;

- (void)insertSections:(NSArray *)data
            forSection:(NSInteger)section;

#pragma mark :.

- (void)stripAdapterData:(NSArray *)data;
- (void)stripAdapterData:(NSArray *)data forSection:(NSInteger)section;

- (void)reloadItems:(NSArray *)data;
- (void)reloadItems:(NSArray *)data forSection:(NSInteger)section;

- (void)insertItems:(NSArray *)data;
- (void)insertItems:(NSArray *)data forSection:(NSInteger)section;
- (void)insertItem:(id)cModel forIndexPath:(NSIndexPath *)indexPath;

- (void)deleteItemAtIndexPath:(NSIndexPath *)indexPath;

- (void)reloadItem:(id)model
      forIndexPath:(NSIndexPath *)indexPath;

#pragma mark - :. Header

- (void)reloadHeaderData:(NSArray *)data;

- (void)insertHeaderData:(NSArray *)data;
- (void)insertHeaderData:(NSArray *)data
              forSection:(NSInteger)section;

- (void)removeHeaderData:(NSInteger)section;

- (id)currentHeaderModelAtIndexPath:(NSIndexPath *)indexPath;

#pragma mark - :. Footer

- (void)reloadFooterData:(NSArray *)data;

- (void)insertFooterData:(NSArray *)data;
- (void)insertFooterData:(NSArray *)data
              forSection:(NSInteger)section;

- (void)removeFooterData:(NSInteger)section;

#pragma mark - :. Block事件

/*!
*  @brief    动态计算高度cell的高度并返回
*/
- (void)autoHeightItem:(ZKCollectionAdapterItemAutoHeightForRowBlock)block;

/// 设置section的边距
- (void)insetForSectionAtIndex:(ZKCollectionAdapterInsetForSectionAtIndexBlock)block;
/// 这是左右两个cell之间的间距
- (void)minimumInteritemSpacingForSection:(ZKCollectionAdapterMinimumInteritemSpacingForSectionBlock)blcok;
/// 设置上下两个cell之间的间距
- (void)minimumLineSpacingForSection:(ZKCollectionAdapterMinimumLineSpacingForSectionBlock)block;

/**
*  When there are multiple cell, returned identifier in block
*/
- (void)cellIdentifierForItemAtIndexPath:(ZKCollectionAdapterCellIdentifierForItemAtIndexPathBlock)block;
- (void)headerIdentifier:(ZKCollectionAdapterHeaderIdentifierBlock)block;
- (void)footerIdentifier:(ZKCollectionAdapterFooterIdentifierBlock)block;

- (void)flattenMap:(ZKCollectionAdapterFlattenMapBlock)block;

- (void)numberOfItemsInSection:(ZKCollectionAdapterNumberOfItemsInSectionBlock)block;

- (void)headerView:(ZKCollectionAdapterHeaderViewBlock)block;
- (void)currentHeaderModel:(ZKCollectionAdapterCurrentHeaderModelAtIndexPathBlock)block;
- (void)footerView:(ZKCollectionAdapterFooterViewBlock)block;
- (void)currentFooterModel:(ZKCollectionAdapterCurrentFooterModelAtIndexPathBlock)block;

- (void)cellForItemAtIndexPath:(ZKCollectionAdapterCellForItemAtIndexPathBlock)block;
- (void)headerForItemAtIndexPah:(ZKCollectionAdapterHeaderForItemAtIndexPathBlock)block;
- (void)footerForItemAtIndexPah:(ZKCollectionAdapterFooterForItemAtIndexPathBlock)block;

- (void)sizeForItemAtIndexPath:(ZKCollectionAdapterCellForItemSizeBlock)block;
- (void)referenceHeaderSize:(ZKCollectionAdapterReferenceHeaderSizeBlock)block;
- (void)referenceFooterSize:(ZKCollectionAdapterReferenceFooterSizeBlock)block;

/**
*  If you override tableView:didSelectRowAtIndexPath: method, it will be invalid
*/
- (void)didSelectItem:(ZKCollectionAdapterDidSelectItemAtIndexPathBlock)block;

@end

/** 漂浮 **/
@interface ZKCollectionViewFlowLayout : UICollectionViewFlowLayout

//默认为64.0, default is 64.0
@property (nonatomic, assign) CGFloat naviHeight;

@end


NS_ASSUME_NONNULL_END
