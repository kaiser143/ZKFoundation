//
//  ZKCollectionViewHelper.m
//  ZKFoundation
//
//  Created by Kaiser on 2019/3/12.
//

#import "ZKCollectionViewAdapter.h"
#import "UITableViewHeaderFooterView+ZKHelper.h"
#import "ZKCollectionViewAdapterInjectionDelegate.h"

@interface ZKCollectionViewAdapter () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) NSMutableArray<NSMutableArray *> *dataArray;
@property (nonatomic, strong) NSMutableArray<NSMutableArray *> *headerArray;
@property (nonatomic, strong) NSMutableArray<NSMutableArray *> *footerArray;

@property (nonatomic, copy) ZKCollectionAdapterHeaderViewBlock headerViewBlock;
@property (nonatomic, copy) ZKCollectionAdapterFooterViewBlock footerViewBlock;

@property (nonatomic, copy) ZKCollectionAdapterItemAutoHeightForRowBlock itemAutoHeightBlock;
@property (nonatomic, copy) ZKCollectionAdapterCellIdentifierForItemAtIndexPathBlock cellIdentifierBlock;
@property (nonatomic, copy) ZKCollectionAdapterHeaderIdentifierBlock headerIdentifierBlock;
@property (nonatomic, copy) ZKCollectionAdapterFooterIdentifierBlock footerIdentifierBlock;

@property (nonatomic, copy) ZKCollectionAdapterNumberOfItemsInSectionBlock numberOfItemsInSectionBlock;

@property (nonatomic, copy) ZKCollectionAdapterCellForItemAtIndexPathBlock cellForItemAtIndexPathBlock;
@property (nonatomic, copy) ZKCollectionAdapterHeaderForItemAtIndexPathBlock headerForItemAtIndexPathBlock;
@property (nonatomic, copy) ZKCollectionAdapterFooterForItemAtIndexPathBlock footerForItemAtIndexPathBlock;

@property (nonatomic, copy) ZKCollectionAdapterCellForItemSizeBlock sizeForItemAtIndexPathBlock;
@property (nonatomic, copy) ZKCollectionAdapterReferenceHeaderSizeBlock referenceHeaderSizeBlock;
@property (nonatomic, copy) ZKCollectionAdapterReferenceFooterSizeBlock referenceFooterSizeBlock;

@property (nonatomic, copy) ZKCollectionAdapterDidSelectItemAtIndexPathBlock didSelectItemAtIndexPathBlock;

@property (nonatomic, copy) ZKCollectionAdapterFlattenMapBlock flattenMapBlock;
@property (nonatomic, copy) ZKCollectionAdapterCurrentHeaderModelAtIndexPathBlock currentHeaderModelAtIndexPathBlock;
@property (nonatomic, copy) ZKCollectionAdapterCurrentFooterModelAtIndexPathBlock currentFooterModelAtIndexPathBlock;

@property (nonatomic, copy) ZKCollectionAdapterCellItemMarginBlock cellItemMarginBlock;
@property (nonatomic, copy) ZKCollectionAdapterMinimumInteritemSpacingForSectionBlock minimumInteritemSpacingForSectionBlock;
@property (nonatomic, copy) ZKCollectionAdapterMinimumLineSpacingForSectionBlock minimumLineSpacingForSectionBlock;

@end

@implementation ZKCollectionViewAdapter

- (void)registerNibs:(NSArray<NSString *> *)cellNibNames {
    if (cellNibNames.count > 0) {
        [cellNibNames enumerateObjectsUsingBlock:^(NSString *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            if (!self.kai_cellXIB && [[self.kai_cellXIB objectAtIndex:idx] boolValue])
                [self.kai_collectionView registerNib:[UINib nibWithNibName:obj bundle:nil] forCellWithReuseIdentifier:obj];
            else
                [self.kai_collectionView registerClass:NSClassFromString(obj) forCellWithReuseIdentifier:obj];
        }];

        if (cellNibNames.count == 1)
            self.cellIdentifier = cellNibNames[0];
    }
}

- (void)registerNibHeaders:(NSArray<NSString *> *)cellNibNames {
    if (cellNibNames) {
        [cellNibNames enumerateObjectsUsingBlock:^(NSString *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            if (self.kai_cellHeaderXIB && [[self.kai_cellHeaderXIB objectAtIndex:idx] boolValue])
                [self.kai_collectionView registerNib:[UINib nibWithNibName:obj bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:obj];
            else
                [self.kai_collectionView registerClass:NSClassFromString(obj) forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:obj];
        }];

        if (cellNibNames.count == 1) {
            self.headerIdentifier = cellNibNames[0];
        }
    }
}

- (void)registerNibFooters:(NSArray<NSString *> *)cellNibNames {
    if (cellNibNames) {
        [cellNibNames enumerateObjectsUsingBlock:^(NSString *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            if ([[self.kai_cellFooterXIB objectAtIndex:idx] boolValue])
                [self.kai_collectionView registerNib:[UINib nibWithNibName:obj bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:obj];
            else
                [self.kai_collectionView registerClass:NSClassFromString(obj) forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:obj];
        }];

        if (cellNibNames.count == 1)
            self.footerIdentifier = cellNibNames[0];
    }
}

- (NSMutableArray *)dataSource {
    NSMutableArray *array = [NSMutableArray array];
    if (self.dataArray.count > 1)
        array = self.dataArray;
    else
        array = self.dataArray.firstObject;

    return array;
}

#pragma mark - :. UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
    CGSize contentSize     = self.titleHeaderSize;
    if (self.referenceHeaderSizeBlock) {
        id curModel = [self currentHeaderModelAtIndexPath:indexPath];
        contentSize = self.referenceHeaderSizeBlock(collectionView, collectionViewLayout, section, curModel);
    } else if (CGSizeEqualToSize(contentSize, CGSizeMake(0, 0))) {
        if (@available(iOS 9.0, *)) {
            contentSize = [[collectionView supplementaryViewForElementKind:UICollectionElementKindSectionHeader atIndexPath:indexPath] systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        }
    }
    return contentSize;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
    CGSize contentSize     = self.titleFooterSize;
    if (self.referenceFooterSizeBlock) {
        id curModel = [self currentFooterModelAtIndexPath:indexPath];
        contentSize = self.referenceFooterSizeBlock(collectionView, collectionViewLayout, section, curModel);
    } else if (CGSizeEqualToSize(contentSize, CGSizeMake(0, 0))) {
        if (@available(iOS 9.0, *)) {
            contentSize = [[collectionView supplementaryViewForElementKind:UICollectionElementKindSectionFooter atIndexPath:indexPath] systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        }
    }
    return contentSize;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize curSize = CGSizeMake(ZKScreenSize().width, 0);
    if (self.itemAutoHeightBlock) {
        id curModel                 = [self currentModelAtIndexPath:indexPath];
        NSString *curCellIdentifier = [self cellIdentifierForRowAtIndexPath:indexPath model:curModel];
        self.itemAutoHeightBlock(collectionView, indexPath, curCellIdentifier, curModel);
    } else if (self.sizeForItemAtIndexPathBlock) {
        id curModel = [self currentModelAtIndexPath:indexPath];
        curSize     = self.sizeForItemAtIndexPathBlock(collectionView, collectionViewLayout, indexPath, curModel);
    }
    return curSize;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    if (self.cellItemMarginBlock) {
        id curModel = [self currentSectionModel:section];
        edgeInsets  = self.cellItemMarginBlock(collectionView, collectionViewLayout, section, curModel);
    }

    return edgeInsets;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    CGFloat minimum = 0;
    if (self.minimumInteritemSpacingForSectionBlock) {
        id curModel = [self currentSectionModel:section];
        minimum     = self.minimumInteritemSpacingForSectionBlock(collectionView, collectionViewLayout, section, curModel);
    }
    return minimum;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    CGFloat minimum = 0;
    if (self.minimumLineSpacingForSectionBlock) {
        id curModel = [self currentSectionModel:section];
        minimum     = self.minimumLineSpacingForSectionBlock(collectionView, collectionViewLayout, section, curModel);
    }
    return minimum;
}

#pragma mark - :. UICollectionViewDelegate && UICollectionViewDataSourse

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    NSInteger curNumOfSections = self.dataArray.count;
    return curNumOfSections;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger curNumOfRows = 0;
    if (self.dataArray.count > section) {
        NSMutableArray *subDataAry = self.dataArray[section];
        if (self.numberOfItemsInSectionBlock)
            curNumOfRows = self.numberOfItemsInSectionBlock(collectionView, section, subDataAry);
        else
            curNumOfRows = subDataAry.count;
    }
    return curNumOfRows;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableView;
    if (kind == UICollectionElementKindSectionHeader) {
        id curModel                 = [self currentHeaderModelAtIndexPath:indexPath];
        NSString *curCellIdentifier = [self headerIdentifierForRowAtIndexPath:indexPath model:curModel];
        if (self.headerViewBlock)
            reusableView = self.headerViewBlock(collectionView, kind, curCellIdentifier, indexPath, curModel);

        if (!reusableView && !self.headerViewBlock)
            reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:curCellIdentifier forIndexPath:indexPath];

        if (self.headerForItemAtIndexPathBlock) {
            self.headerForItemAtIndexPathBlock(reusableView, indexPath, curModel, YES);
        }
    } else if (kind == UICollectionElementKindSectionFooter) {
        id curModel                 = [self currentFooterModelAtIndexPath:indexPath];
        NSString *curCellIdentifier = [self footerIdentifierForRowAtIndexPath:indexPath model:curModel];
        if (self.footerViewBlock)
            reusableView = self.footerViewBlock(collectionView, kind, curCellIdentifier, indexPath, curModel);

        if (!reusableView && !self.footerViewBlock)
            reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:curCellIdentifier forIndexPath:indexPath];

        if (self.footerForItemAtIndexPathBlock) {
            self.footerForItemAtIndexPathBlock(reusableView, indexPath, curModel, YES);
        }
    }
    return reusableView;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell<ZKCollectionViewAdapterInjectionDelegate> *cell = nil;
    id curModel                                                          = [self currentModelAtIndexPath:indexPath];
    NSString *identifier                                                 = [self cellIdentifierForRowAtIndexPath:indexPath model:curModel];
    cell                                                                 = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    NSAssert(cell, @"cell is nil Identifier ⤭ %@ ⤪", identifier);

    [self configureCell:cell forIndexPath:indexPath withObject:curModel];

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    id curModel = [self currentModelAtIndexPath:indexPath];
    if (self.cellForItemAtIndexPathBlock) {
        self.cellForItemAtIndexPathBlock(cell, indexPath, curModel, YES);
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.kai_indexPath = indexPath;
    if (self.didSelectItemAtIndexPathBlock) {
        id curModel = [self currentModelAtIndexPath:indexPath];
        self.didSelectItemAtIndexPathBlock(collectionView, indexPath, curModel);
    }
}

#pragma mark - :. Handler

- (NSString *)cellIdentifierForRowAtIndexPath:(NSIndexPath *)indexPath model:(id)cModel {
    NSString *curCellIdentifier = nil;
    if (self.cellIdentifierBlock) {
        curCellIdentifier = self.cellIdentifierBlock(indexPath, cModel);
    } else {
        curCellIdentifier = self.cellIdentifier;
    }
    return curCellIdentifier;
}

- (id)currentSectionModel:(NSInteger)section {
    id currentModel = nil;
    NSArray *arr    = [self.dataArray objectAtIndex:section];
    if (arr.count)
        currentModel = [arr objectAtIndex:0];

    return currentModel;
}

- (id)currentModel {
    return [self currentModelAtIndexPath:self.kai_indexPath];
}

- (id)currentModelAtIndexPath:(NSIndexPath *)indexPath {
    if (self.flattenMapBlock) {
        return self.flattenMapBlock(self.dataArray, indexPath);
    } else if (self.dataArray.count > indexPath.section) {
        NSMutableArray *subDataAry = self.dataArray[indexPath.section];
        if (subDataAry.count > indexPath.row) {
            id curModel = subDataAry[indexPath.row];
            return curModel;
        }
    }
    return nil;
}

#pragma mark - :. Group

- (void)kai_reloadGroupDataAry:(NSArray *)data {
    [self stripAdapterGroupData:data];
}

- (void)stripAdapterGroupData:(NSArray *)data {
    self.dataArray = nil;
    for (NSInteger i = 0; i < data.count; i++)
        [self _kai_makeUpDataAryForSection:i];

    for (int idx = 0; idx < self.dataArray.count; idx++) {
        NSMutableArray *subAry = self.dataArray[idx];
        if (subAry.count) [subAry removeAllObjects];
        id obj = [data objectAtIndex:idx];
        if ([obj isKindOfClass:[NSArray class]]) {
            [subAry addObjectsFromArray:obj];
        } else {
            [subAry addObject:obj];
        }
    }
    [self.kai_collectionView reloadData];
}

- (void)appendSection:(NSArray *)data {
    [self.dataArray addObject:[NSMutableArray arrayWithArray:data]];
    [self.kai_collectionView reloadData];
}

- (void)insertSection:(NSArray *)data
           forSection:(NSInteger)cSection {
    [self.dataArray insertObject:[NSMutableArray arrayWithArray:data] atIndex:cSection == -1 ? 0 : cSection];
    [self.kai_collectionView reloadData];
}

- (void)insertSections:(NSArray *)data
            forSection:(NSInteger)cSection {
    NSMutableArray *idxArray = [NSMutableArray array];
    if (cSection < 0) {
        for (NSInteger i = 0; i < data.count; i++) {
            [self.dataArray insertObject:[NSMutableArray array] atIndex:0];
            [idxArray addObject:@(i)];
        }
    } else {
        for (NSInteger i = 0; i < data.count; i++) {
            [self.dataArray insertObject:[NSMutableArray array] atIndex:cSection + i];
            [idxArray addObject:@(cSection + i)];
        }
    }

    for (NSInteger i = 0; i < idxArray.count; i++) {
        NSInteger idx          = [[idxArray objectAtIndex:i] integerValue];
        NSMutableArray *subAry = self.dataArray[idx];
        if (subAry.count) [subAry removeAllObjects];
        id obj = [data objectAtIndex:i];
        if ([data isKindOfClass:[NSArray class]]) {
            [subAry addObjectsFromArray:obj];
        } else {
            [subAry addObject:obj];
        }
    }
    [self.kai_collectionView reloadData];
}

#pragma mark :.

- (void)stripAdapterData:(NSArray *)data {
    self.dataArray = nil;
    [self stripAdapterData:data forSection:0];
}

- (void)stripAdapterData:(NSArray *)data forSection:(NSInteger)cSection {
    [self _kai_makeUpDataAryForSection:cSection];
    NSMutableArray *subAry = self.dataArray[cSection];
    if (subAry.count) [subAry removeAllObjects];
    if (data.count) {
        [subAry addObjectsFromArray:data];
    }
    [self.kai_collectionView reloadData];
}

- (void)reloadItems:(NSArray *)data {
    [self reloadItems:data forSection:0];
}

- (void)reloadItems:(NSArray *)data forSection:(NSInteger)cSection {
    if (data.count == 0) return;

    NSIndexSet *curIndexSet = [self _kai_makeUpDataAryForSection:cSection];
    NSMutableArray *subAry  = self.dataArray[cSection];
    if (subAry.count) [subAry removeAllObjects];
    [subAry addObjectsFromArray:data];

    if (curIndexSet) {
        [self.kai_collectionView insertSections:curIndexSet];
    } else {
        [self.kai_collectionView reloadSections:[NSIndexSet indexSetWithIndex:cSection]];
    }
}

- (void)insertItems:(NSArray *)data {
    [self insertItems:data forSection:0];
}

- (void)insertItems:(NSArray *)data forSection:(NSInteger)cSection {
    if (data.count == 0) return;

    NSIndexSet *curIndexSet = [self _kai_makeUpDataAryForSection:cSection];
    NSMutableArray *subAry;
    if (cSection < 0) {
        subAry = self.dataArray[0];
    } else
        subAry = self.dataArray[cSection];

    if (curIndexSet) {
        [subAry addObjectsFromArray:data];
        [self.kai_collectionView insertSections:curIndexSet];
    } else {
        __block NSMutableArray *curIndexPaths = [NSMutableArray arrayWithCapacity:data.count];
        [data enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            [curIndexPaths addObject:[NSIndexPath indexPathForRow:subAry.count + idx inSection:cSection]];
        }];
        [subAry addObjectsFromArray:data];
        [self.kai_collectionView insertItemsAtIndexPaths:curIndexPaths];
    }
}

- (void)insertItem:(id)cModel forIndexPath:(NSIndexPath *)indexPath {
    NSIndexSet *curIndexSet = [self _kai_makeUpDataAryForSection:indexPath.section];
    NSMutableArray *subAry  = self.dataArray[indexPath.section];
    if (subAry.count < indexPath.row) return;
    [subAry insertObject:cModel atIndex:indexPath.row];
    if (curIndexSet) {
        [self.kai_collectionView insertSections:curIndexSet];
    } else {
        [subAry insertObject:cModel atIndex:indexPath.row];
        [self.kai_collectionView insertItemsAtIndexPaths:@[indexPath]];
    }
}

- (void)deleteItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.dataArray.count <= indexPath.section) return;
    NSMutableArray *subAry = self.dataArray[indexPath.section];
    if (subAry.count <= indexPath.row) return;

    [subAry removeObjectAtIndex:indexPath.row];
    [self.kai_collectionView insertItemsAtIndexPaths:@[indexPath]];
}

- (void)reloadItem:(id)model
      forIndexPath:(NSIndexPath *)indexPath {
    if (self.dataArray.count > indexPath.section) {
        NSMutableArray *subDataAry = self.dataArray[indexPath.section];
        if (subDataAry.count > indexPath.row) {
            [subDataAry replaceObjectAtIndex:indexPath.row withObject:model];
            [self.kai_collectionView reloadData];
        }
    }
}

- (NSIndexSet *)_kai_makeUpDataAryForSection:(NSInteger)cSection {
    NSMutableIndexSet *curIndexSet = nil;
    if (self.dataArray.count <= cSection) {
        curIndexSet = [NSMutableIndexSet indexSet];
        for (NSInteger idx = 0; idx < (cSection - self.dataArray.count + 1); idx++) {
            NSMutableArray *subAry = [NSMutableArray array];
            if (cSection < 0) {
                [self.dataArray insertObject:subAry atIndex:0];
                [curIndexSet addIndex:0];
                break;
            } else {
                [self.dataArray addObject:subAry];
                [curIndexSet addIndex:cSection - idx];
            }
        }
    }
    return curIndexSet;
}

- (NSMutableArray<NSMutableArray *> *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray new];
    }
    return _dataArray;
}

#pragma mark - :. Header

- (void)reloadHeaderData:(NSArray *)data {
    self.headerArray = [NSMutableArray arrayWithArray:data];
}

- (void)insertHeaderData:(NSArray *)data {
    [self.headerArray addObjectsFromArray:data];
}

- (void)insertHeaderData:(NSArray *)data
              forSection:(NSInteger)cSection {
    NSMutableIndexSet *set = [NSMutableIndexSet indexSet];
    for (NSInteger i = 0; i < data.count; i++)
        [set addIndex:cSection + i];

    [self.headerArray insertObjects:data atIndexes:set];
}

- (void)removeHeaderData:(NSInteger)cSection {
    [self.headerArray removeObjectAtIndex:cSection];
}

- (NSString *)headerIdentifierForRowAtIndexPath:(NSIndexPath *)indexPath model:(id)cModel {
    NSString *curCellIdentifier = nil;
    if (self.headerIdentifierBlock) {
        curCellIdentifier = self.headerIdentifierBlock(indexPath, cModel);
    } else {
        curCellIdentifier = self.headerIdentifier;
    }
    return curCellIdentifier;
}

- (id)currentHeaderModelAtIndexPath:(NSIndexPath *)indexPath {
    if (self.currentHeaderModelAtIndexPathBlock) {
        return self.currentHeaderModelAtIndexPathBlock(self.headerArray, indexPath);
    } else if (self.headerArray.count > indexPath.section) {
        id curModel = self.headerArray[indexPath.section];
        return curModel;
    }
    return nil;
}

- (NSMutableArray<NSMutableArray *> *)headerArray {
    if (!_headerArray) {
        _headerArray = [NSMutableArray new];
    }
    return _headerArray;
}

#pragma mark - :. Footer

- (void)reloadFooterData:(NSArray *)data {
    self.footerArray = [NSMutableArray arrayWithArray:data];
}

- (void)insertFooterData:(NSArray *)data {
    [self.footerArray addObjectsFromArray:data];
}

- (void)insertFooterData:(NSArray *)data
              forSection:(NSInteger)cSection {
    NSMutableIndexSet *set = [NSMutableIndexSet indexSet];
    for (NSInteger i = 0; i < data.count; i++)
        [set addIndex:cSection + i];

    [self.footerArray insertObjects:data atIndexes:set];
}

- (void)removeFooterData:(NSInteger)cSection {
    [self.footerArray removeObjectAtIndex:cSection];
}

- (NSString *)footerIdentifierForRowAtIndexPath:(NSIndexPath *)indexPath model:(id)cModel {
    NSString *curCellIdentifier = nil;
    if (self.footerIdentifierBlock) {
        curCellIdentifier = self.footerIdentifierBlock(indexPath, cModel);
    } else {
        curCellIdentifier = self.footerIdentifier;
    }
    return curCellIdentifier;
}

- (id)currentFooterModelAtIndexPath:(NSIndexPath *)indexPath {
    if (self.currentFooterModelAtIndexPathBlock) {
        return self.currentFooterModelAtIndexPathBlock(self.footerArray, indexPath);
    } else if (self.footerArray.count > indexPath.section) {
        id curModel = self.footerArray[indexPath.section];
        return curModel;
    }
    return nil;
}

- (NSIndexSet *)_kai_makeUpFooterArrForSection:(NSInteger)cSection {
    NSMutableIndexSet *curIndexSet = nil;
    if (self.footerArray.count <= cSection) {
        curIndexSet = [NSMutableIndexSet indexSet];
        for (NSInteger idx = 0; idx < (cSection - self.footerArray.count + 1); idx++) {
            NSMutableArray *subAry = [NSMutableArray array];
            if (cSection < 0) {
                [self.footerArray insertObject:subAry atIndex:0];
                [curIndexSet addIndex:0];
                break;
            } else {
                [self.footerArray addObject:subAry];
                [curIndexSet addIndex:cSection - idx];
            }
        }
    }
    return curIndexSet;
}

- (NSMutableArray<NSMutableArray *> *)footerArray {
    if (!_footerArray) {
        _footerArray = [NSMutableArray new];
    }
    return _footerArray;
}

#pragma mark - :. getters and setters

- (NSString *)cellIdentifier {
    if (_cellIdentifier == nil) {
        NSString *curVCIdentifier = NSStringFromClass(self.class);
        if (curVCIdentifier) {
            NSString *curCellIdentifier = [NSString stringWithFormat:@"ZK%@Cell", curVCIdentifier];
            _cellIdentifier             = curCellIdentifier;
        }
    }
    return _cellIdentifier;
}

- (NSString *)headerIdentifier {
    if (_headerIdentifier == nil) {
        NSString *curVCIdentifier = NSStringFromClass(self.class);
        if (curVCIdentifier) {
            NSString *curCellIdentifier = [NSString stringWithFormat:@"ZK%@Header", curVCIdentifier];
            _headerIdentifier           = curCellIdentifier;
        }
    }
    return _headerIdentifier;
}

- (NSString *)footerIdentifier {
    if (_footerIdentifier == nil) {
        NSString *curVCIdentifier = NSStringFromClass(self.class);
        if (curVCIdentifier) {
            NSString *curCellIdentifier = [NSString stringWithFormat:@"ZK%@Header", curVCIdentifier];
            _footerIdentifier           = curCellIdentifier;
        }
    }
    return _footerIdentifier;
}

- (void)autoHeightItem:(ZKCollectionAdapterItemAutoHeightForRowBlock)cb {
    self.itemAutoHeightBlock = cb;
}

- (void)cellIdentifierForItemAtIndexPath:(ZKCollectionAdapterCellIdentifierForItemAtIndexPathBlock)block {
    self.cellIdentifierBlock = block;
}

- (void)headerIdentifier:(ZKCollectionAdapterHeaderIdentifierBlock)block {
    self.headerIdentifierBlock = block;
}

- (void)footerIdentifier:(ZKCollectionAdapterFooterIdentifierBlock)block {
    self.footerIdentifierBlock = block;
}

- (void)flattenMap:(ZKCollectionAdapterFlattenMapBlock)block {
    self.flattenMapBlock = block;
}

- (void)numberOfItemsInSection:(ZKCollectionAdapterNumberOfItemsInSectionBlock)block {
    self.numberOfItemsInSectionBlock = block;
}

- (void)headerView:(ZKCollectionAdapterHeaderViewBlock)block {
    self.headerViewBlock = block;
}

- (void)currentHeaderModel:(ZKCollectionAdapterCurrentHeaderModelAtIndexPathBlock)block {
    self.currentHeaderModelAtIndexPathBlock = block;
}

- (void)footerView:(ZKCollectionAdapterFooterViewBlock)block {
    self.footerViewBlock = block;
}

- (void)currentFooterModel:(ZKCollectionAdapterCurrentFooterModelAtIndexPathBlock)block {
    self.currentFooterModelAtIndexPathBlock = block;
}

- (void)cellForItemAtIndexPath:(ZKCollectionAdapterCellForItemAtIndexPathBlock)block {
    self.cellForItemAtIndexPathBlock = block;
}

- (void)headerForItemAtIndexPah:(ZKCollectionAdapterHeaderForItemAtIndexPathBlock)block {
    self.headerForItemAtIndexPathBlock = block;
}

- (void)footerForItemAtIndexPah:(ZKCollectionAdapterFooterForItemAtIndexPathBlock)block {
    self.footerForItemAtIndexPathBlock = block;
}

- (void)sizeForItemAtIndexPath:(ZKCollectionAdapterCellForItemSizeBlock)block {
    self.sizeForItemAtIndexPathBlock = block;
}

- (void)referenceHeaderSize:(ZKCollectionAdapterReferenceHeaderSizeBlock)block {
    self.referenceHeaderSizeBlock = block;
}

- (void)referenceFooterSize:(ZKCollectionAdapterReferenceFooterSizeBlock)block {
    self.referenceFooterSizeBlock = block;
}

- (void)didSelectItem:(ZKCollectionAdapterDidSelectItemAtIndexPathBlock)block {
    self.didSelectItemAtIndexPathBlock = block;
}

- (void)cellItemMargin:(ZKCollectionAdapterCellItemMarginBlock)block {
    self.cellItemMarginBlock = block;
}

- (void)minimumInteritemSpacingForSection:(ZKCollectionAdapterMinimumInteritemSpacingForSectionBlock)blcok {
    self.minimumInteritemSpacingForSectionBlock = blcok;
}

- (void)minimumLineSpacingForSection:(ZKCollectionAdapterMinimumLineSpacingForSectionBlock)block {
    self.minimumLineSpacingForSectionBlock = block;
}

- (void)configureCell:(UICollectionViewCell<ZKCollectionViewAdapterInjectionDelegate> *)cell forIndexPath:(NSIndexPath *)indexPath withObject:(id)obj {
    if ([cell respondsToSelector:@selector(bindViewModel:forItemAtIndexPath:)]) {
        [cell bindViewModel:obj forItemAtIndexPath:indexPath];
    }
}

@end

@implementation ZKCollectionViewFlowLayout

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    //UICollectionViewLayoutAttributes：我称它为collectionView中的item（包括cell和header、footer这些）的《结构信息》
    //截取到父类所返回的数组（里面放的是当前屏幕所能展示的item的结构信息），并转化成不可变数组
    NSMutableArray *superArray = [[super layoutAttributesForElementsInRect:rect] mutableCopy];

    //创建存索引的数组，无符号（正整数），无序（不能通过下标取值），不可重复（重复的话会自动过滤）
    NSMutableIndexSet *noneHeaderSections = [NSMutableIndexSet indexSet];
    //遍历superArray，得到一个当前屏幕中所有的section数组
    for (UICollectionViewLayoutAttributes *attributes in superArray) {
        //如果当前的元素分类是一个cell，将cell所在的分区section加入数组，重复的话会自动过滤
        if (attributes.representedElementCategory == UICollectionElementCategoryCell) {
            [noneHeaderSections addIndex:attributes.indexPath.section];
        }
    }

    //遍历superArray，将当前屏幕中拥有的header的section从数组中移除，得到一个当前屏幕中没有header的section数组
    //正常情况下，随着手指往上移，header脱离屏幕会被系统回收而cell尚在，也会触发该方法
    for (UICollectionViewLayoutAttributes *attributes in superArray) {
        //如果当前的元素是一个header，将header所在的section从数组中移除
        if ([attributes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) {
            [noneHeaderSections removeIndex:attributes.indexPath.section];
        }
    }

    //遍历当前屏幕中没有header的section数组
    [noneHeaderSections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {

        //取到当前section中第一个item的indexPath
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:idx];
        //获取当前section在正常情况下已经离开屏幕的header结构信息
        UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:indexPath];

        //如果当前分区确实有因为离开屏幕而被系统回收的header
        if (attributes) {
            //将该header结构信息重新加入到superArray中去
            [superArray addObject:attributes];
        }
    }];

    //遍历superArray，改变header结构信息中的参数，使它可以在当前section还没完全离开屏幕的时候一直显示
    for (UICollectionViewLayoutAttributes *attributes in superArray) {
        //如果当前item是header
        if ([attributes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) {
            //得到当前header所在分区的cell的数量
            NSInteger numberOfItemsInSection = [self.collectionView numberOfItemsInSection:attributes.indexPath.section];
            //得到第一个item的indexPath
            NSIndexPath *firstItemIndexPath = [NSIndexPath indexPathForItem:0 inSection:attributes.indexPath.section];
            //得到最后一个item的indexPath
            NSIndexPath *lastItemIndexPath = [NSIndexPath indexPathForItem:MAX(0, numberOfItemsInSection - 1) inSection:attributes.indexPath.section];
            //得到第一个item和最后一个item的结构信息
            UICollectionViewLayoutAttributes *firstItemAttributes, *lastItemAttributes;
            if (numberOfItemsInSection > 0) {
                //cell有值，则获取第一个cell和最后一个cell的结构信息
                firstItemAttributes = [self layoutAttributesForItemAtIndexPath:firstItemIndexPath];
                lastItemAttributes  = [self layoutAttributesForItemAtIndexPath:lastItemIndexPath];
            } else {
                //cell没值,就新建一个UICollectionViewLayoutAttributes
                firstItemAttributes = [UICollectionViewLayoutAttributes new];
                //然后模拟出在当前分区中的唯一一个cell，cell在header的下面，高度为0，还与header隔着可能存在的sectionInset的top
                CGFloat y                 = CGRectGetMaxY(attributes.frame) + self.sectionInset.top;
                firstItemAttributes.frame = CGRectMake(0, y, 0, 0);
                //因为只有一个cell，所以最后一个cell等于第一个cell
                lastItemAttributes = firstItemAttributes;
            }

            //获取当前header的frame
            CGRect rect = attributes.frame;

            //当前的滑动距离 + 因为导航栏产生的偏移量，默认为64（如果app需求不同，需自己设置）
            CGFloat offset = self.collectionView.contentOffset.y + _naviHeight;
            //第一个cell的y值 - 当前header的高度 - 可能存在的sectionInset的top
            CGFloat headerY = firstItemAttributes.frame.origin.y - rect.size.height - self.sectionInset.top;

            //哪个大取哪个，保证header悬停
            //针对当前header基本上都是offset更加大，针对下一个header则会是headerY大，各自处理
            CGFloat maxY = MAX(offset,headerY);
            
            //最后一个cell的y值 + 最后一个cell的高度 + 可能存在的sectionInset的bottom - 当前header的高度
            //当当前section的footer或者下一个section的header接触到当前header的底部，计算出的headerMissingY即为有效值
            CGFloat headerMissingY = CGRectGetMaxY(lastItemAttributes.frame) + self.sectionInset.bottom - rect.size.height;
            
            //给rect的y赋新值，因为在最后消失的临界点要跟谁消失，所以取小
            rect.origin.y = MIN(maxY,headerMissingY);
            //给header的结构信息的frame重新赋值
            attributes.frame = rect;
            
            //如果按照正常情况下,header离开屏幕被系统回收，而header的层次关系又与cell相等，如果不去理会，会出现cell在header上面的情况
            //通过打印可以知道cell的层次关系zIndex数值为0，我们可以将header的zIndex设置成1，如果不放心，也可以将它设置成非常大，这里随便填了个7
            attributes.zIndex = 7;
        }
    }
    
    //转换回不可变数组，并返回
    return [superArray copy];
    
}

//return YES;表示一旦滑动就实时调用上面这个layoutAttributesForElementsInRect:方法
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBound {
    return YES;
}

@end
