//
//  ZKCollectionViewHelper.h
//  ZKFoundation
//
//  Created by Kaiser on 2019/3/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ZKCollectionViewHelperInjectionDelegate;

typedef NSString *_Nullable (^ZKCollectionHelperCellIdentifierForItemBlock)(NSIndexPath *indexPath, id dataSource);
typedef NSString *_Nullable (^ZKCollectionHelperHeaderIdentifierBlock)(NSIndexPath *indexPath, id dataSource);
typedef NSString *_Nullable (^ZKCollectionHelperFooterIdentifierBlock)(NSIndexPath *indexPath, id dataSource);
typedef CGFloat (^ZKCollectionHelperItemAutoHeightForRowBlock)(UICollectionView *collectionView, NSIndexPath *indexPath, NSString *identifier, id dataSource);

typedef NSInteger (^ZKCollectionHelperNumberOfItemsInSection)(UICollectionView *collectionView, NSInteger section, id dataSource);

typedef UICollectionReusableView *_Nullable (^ZKCollectionHelperHeaderView)(UICollectionView *collectionView, NSString *kind, NSString *cellIdentifier, NSIndexPath *indexPath, id dataSource);
typedef UICollectionReusableView *_Nullable (^ZKCollectionHelperFooterView)(UICollectionView *collectionView, NSString *kind, NSString *cellIdentifier, NSIndexPath *indexPath, id dataSource);

typedef void (^ZKCollectionHelperDidSelectItemAtIndexPath)(UICollectionView *collectionView, NSIndexPath *indexPath, id dataSource);
typedef void (^ZKCollectionHelperCellForItemAtIndexPath)(UICollectionViewCell *cell, NSIndexPath *indexPath, id dataSource, BOOL IsCelldisplay);
typedef void (^ZKCollectionHelperHeaderForItemAtIndexPath)(UICollectionReusableView *header, NSIndexPath *indexPath, id dataSource, BOOL IsCelldisplay);
typedef void (^ZKCollectionHelperFooterForItemAtIndexPath)(UICollectionReusableView *footer, NSIndexPath *indexPath, id dataSource, BOOL IsCelldisplay);

typedef CGSize (^ZKCollectionHelperCellForItemSize)(UICollectionView *collectionView, UICollectionViewLayout *layout, NSIndexPath *indexPath, id dataSource);
typedef CGSize (^ZKCollectionHelperReferenceHeaderSize)(UICollectionView *collectionView, UICollectionViewLayout *layout, NSInteger section, id dataSource);
typedef CGSize (^ZKCollectionHelperReferenceFooterSize)(UICollectionView *collectionView, UICollectionViewLayout *layout, NSInteger section, id dataSource);

typedef UIEdgeInsets (^ZKCollectionHelperCellItemMargin)(UICollectionView *collectionView, UICollectionViewLayout *layout, NSInteger section, id dataSource);
typedef CGFloat (^ZKCollectionHelperMinimumInteritemSpacingForSection)(UICollectionView *collectionView, UICollectionViewLayout *layout, NSInteger section, id dataSource);

typedef id _Nullable (^ZKCollectionHelperCurrentModelAtIndexPath)(id dataAry, NSIndexPath *indexPath);
typedef id _Nullable (^ZKCollectionHelperCurrentHeaderModelAtIndexPath)(id dataAry, NSIndexPath *indexPath);
typedef id _Nullable (^ZKCollectionHelperCurrentFooterModelAtIndexPath)(id dataAry, NSIndexPath *indexPath);

typedef void (^ZKScrollViewDidScroll)(UIScrollView *scrollView);
typedef void (^ZKScrollViewDidEndDragging)(UIScrollView *scrollView);
typedef void (^ZKScrollViewDidEndDecelerating)(UIScrollView *srollView);

@interface ZKCollectionViewHelper : NSObject <UICollectionViewDelegate, UICollectionViewDataSource>

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
 Hader 是否加载XIB
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

#pragma mark -
#pragma mark :. Handler

- (NSString *)cellIdentifierForRowAtIndexPath:(NSIndexPath *)indexPath model:(id)cModel;

- (id)currentSectionModel:(NSInteger)section;

- (id)currentModel;

- (id)currentModelAtIndexPath:(NSIndexPath *)indexPath;
- (id)currentFooterModelAtIndexPath:(NSIndexPath *)indexPath;
- (void)configureCell:(UICollectionViewCell<ZKCollectionViewHelperInjectionDelegate> *)cell forIndexPath:(NSIndexPath *)indexPath withObject:(id)obj;

#pragma mark :. Group
- (void)kai_reloadGroupDataAry:(NSArray *)newDataAry;

- (void)kai_addGroupDataAry:(NSArray *)newDataAry;

- (void)kai_insertGroupDataAry:(NSArray *)newDataAry
                    forSection:(NSInteger)section;

- (void)kai_insertMultiplGroupDataAry:(NSArray *)newDataAry
                           forSection:(NSInteger)section;

#pragma mark :.

- (void)kai_resetDataAry:(NSArray *)newDataAry;

- (void)kai_resetDataAry:(NSArray *)newDataAry forSection:(NSInteger)section;

- (void)kai_reloadDataAry:(NSArray *)newDataAry;
- (void)kai_reloadDataAry:(NSArray *)newDataAry forSection:(NSInteger)section;

- (void)kai_addDataAry:(NSArray *)newDataAry;

- (void)kai_addDataAry:(NSArray *)newDataAry forSection:(NSInteger)section;
- (void)kai_insertData:(id)cModel atIndexPath:(NSIndexPath *)indexPath;

- (void)kai_deleteDataAtIndexPath:(NSIndexPath *)indexPath;

- (void)kai_replaceData:(id)model
            atIndexPath:(NSIndexPath *)indexPath;
#pragma mark -
#pragma mark :. Header

- (void)kai_reloadHeaderArr:(NSArray *)newDataAry;

- (void)kai_addHeaderArr:(NSArray *)newDataAry;

- (void)kai_insertHeaderArr:(NSArray *)newDataAry
                 forSection:(NSInteger)section;

- (void)kai_removerHeaderData:(NSInteger)section;

- (id)currentHeaderModelAtIndexPath:(NSIndexPath *)indexPath;

#pragma mark -
#pragma mark :. Footer

- (void)kai_reloadFooterArr:(NSArray *)newDataAry;

- (void)kai_addFooterArr:(NSArray *)newDataAry;

- (void)kai_insertFooterArr:(NSArray *)newDataAry
                 forSection:(NSInteger)section;

- (void)kai_removerFooterData:(NSInteger)section;

#pragma mark -
#pragma mark :. Block事件

- (void)autoHeightItem:(ZKCollectionHelperItemAutoHeightForRowBlock)block;

- (void)cellIdentifierForItemAtIndexPath:(ZKCollectionHelperCellIdentifierForItemBlock)block;
- (void)headerIdentifier:(ZKCollectionHelperHeaderIdentifierBlock)block;
- (void)footerIdentifier:(ZKCollectionHelperFooterIdentifierBlock)block;

- (void)currentModelIndexPath:(ZKCollectionHelperCurrentModelAtIndexPath)block;

- (void)numberOfItemsInSection:(ZKCollectionHelperNumberOfItemsInSection)block;

- (void)didHeaderView:(ZKCollectionHelperHeaderView)block;
- (void)didCurrentHeaderModel:(ZKCollectionHelperCurrentHeaderModelAtIndexPath)block;
- (void)didFooterView:(ZKCollectionHelperFooterView)block;
- (void)didCurrentFooterModel:(ZKCollectionHelperCurrentFooterModelAtIndexPath)block;

- (void)didCellForItemAtIndexPath:(ZKCollectionHelperCellForItemAtIndexPath)block;
- (void)didHeaderForItemAtIndexPah:(ZKCollectionHelperHeaderForItemAtIndexPath)block;
- (void)didFooterForItemAtIndexPah:(ZKCollectionHelperFooterForItemAtIndexPath)block;

- (void)didSizeForItemAtIndexPath:(ZKCollectionHelperCellForItemSize)block;
- (void)didReferenceHeaderSize:(ZKCollectionHelperReferenceHeaderSize)block;
- (void)didReferenceFooterSize:(ZKCollectionHelperReferenceFooterSize)block;

- (void)didSelectItem:(ZKCollectionHelperDidSelectItemAtIndexPath)block;

- (void)didCellItemMargin:(ZKCollectionHelperCellItemMargin)block;

- (void)didMinimumInteritemSpacingForSection:(ZKCollectionHelperMinimumInteritemSpacingForSection)blcok;

- (void)didScrollViewDidScroll:(ZKScrollViewDidScroll)block;
- (void)didEndDragging:(ZKScrollViewDidEndDragging)block;
- (void)didEndDecelerating:(ZKScrollViewDidEndDecelerating)block;

@end

/** 漂浮 **/
@interface ZKCollectionViewFlowLayout : UICollectionViewFlowLayout

//默认为64.0, default is 64.0
@property (nonatomic, assign) CGFloat naviHeight;

@end


NS_ASSUME_NONNULL_END
