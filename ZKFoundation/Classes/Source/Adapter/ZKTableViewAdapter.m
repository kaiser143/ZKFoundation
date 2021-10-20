//
//  ZKTableViewHelper.m
//  ZKFoundation
//
//  Created by Kaiser on 2019/3/12.
//

#import "ZKTableViewAdapter.h"
#import "UITableViewHeaderFooterView+ZKHelper.h"
#import "UITableView+ZKAdapter.h"
#import "ZKTableViewAdapterInjectionDelegate.h"

#define defaultInterval .5 //默认时间间隔
CGFloat ZKAutoHeightForHeaderFooterView = -1;

@interface ZKTableViewAdapter () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray<NSMutableArray *> *data;

@property (nonatomic, strong) NSMutableArray *sectionIndexTitles;

@property (nonatomic, strong) UILocalizedIndexedCollation *theCollation;

@property (nonatomic, assign) NSTimeInterval timeInterval;

@property (nonatomic, assign) BOOL isIgnoreEvent;

/**

 *  @brief 头部搜索
 */
@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic, copy) ZKTableAdapterCellAutoHeightForRowBlock cellAutoHeightForRowBlock;
@property (nonatomic, copy) ZKTableAdapterCellIdentifierForRowBlock cellIdentifierForRowAtIndexPathBlock;
@property (nonatomic, copy) ZKTableAdapterDidSelectRowBlock didSelectRowBlock;
@property (nonatomic, copy) ZKTableAdapterDidDeselectRowBlock didDeselectRowBlock;
@property (nonatomic, copy) ZKTableAdapterMoveRowBlock moveRowBlock;
@property (nonatomic, copy) ZKTableAdapterCellWillDisplayBlock didWillDisplayBlock;
@property (nonatomic, copy) ZKTableAdapterHeaderWillDisplayBlock didHeaderWillDisplayBlock;
@property (nonatomic, copy) ZKTableAdapterFooterWillDisplayBlock didFooterWillDisplayBlock;

@property (nonatomic, copy) ZKTableAdapterCommitEditingStyleForRowBlock didEditingBlock;
@property (nonatomic, copy) ZKTableAdapterTitleForDeleteConfirmationButtonForRowBlock didEditTileBlock;

@property (nonatomic, copy) ZKTableAdapterEditingStyleForRowBlock didEditingStyleBlock;
@property (nonatomic, copy) ZKTableAdapterEditActionsForRowBlock didEditActionsBlock;

@property (nonatomic, copy) ZKTableAdapterHeaderBlock headerBlock;
@property (nonatomic, copy) ZKTableAdapterTitleHeaderBlock headerTitleBlock;
@property (nonatomic, copy) ZKTableAdapterHeightForHeaderBlock heightForHeaderBlock;

@property (nonatomic, copy) ZKTableAdapterFooterBlock footerBlock;
@property (nonatomic, copy) ZKTableAdapterTitleFooterBlock footerTitleBlock;
@property (nonatomic, copy) ZKTableAdapterHeightForFooterBlock heightForFooterBlock;

@property (nonatomic, copy) ZKTableAdapterAccessoryTypeBlock accessoryTypeBlock API_DEPRECATED("", ios(2.0, 3.0));
@property (nonatomic, copy) ZKTableAdapterAccessoryButtonTappedForRowAtIndexPathBlock accessoryButtonTappedForRowAtIndexPathBlock;

@property (nonatomic, copy) ZKTableAdapterNumberOfSectionsBlock numberOfSectionsBlock;
@property (nonatomic, copy) ZKTableAdapterNumberRowsBlock numberRowBlock;

@property (nonatomic, copy) ZKTableAdapterCanEditRowAtIndexPathBlock canEditRowBlock;

@property (nonatomic, copy) ZKTableAdapterFlattenMapBlock flattenMapBlock;

@property (nullable, nonatomic, copy) NSString *cellIdentifier;
@property (nullable, nonatomic, copy) NSString *headerFooterIdentifier;

@property (nonatomic, copy) ZKScrollAdapterDidScrollBlock scrollViewddBlock;

@end

@implementation ZKTableViewAdapter

- (instancetype)init {
    if (self = [super init]) {
        [self initialization];
    }
    return self;
}

- (void)initialization {
    if (@available(iOS 15.0, *)) {
        self.kai_tableView.sectionHeaderTopPadding = 0;
        self.titleHeaderHeight = 0;
        self.titleFooterHeight = 0;
    } else {
        self.titleHeaderHeight = 0.001;
        self.titleFooterHeight = 0.001;
    }
}

- (void)registerNibs:(NSArray<NSString *> *)nibs {
    if (nibs.count > 0) {
        [nibs enumerateObjectsUsingBlock:^(NSString *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            if (self.kai_cellXIB && [[self.kai_cellXIB objectAtIndex:idx] boolValue])
                [self.kai_tableView registerNib:[UINib nibWithNibName:obj bundle:nil] forCellReuseIdentifier:obj];
            else
                [self.kai_tableView registerClass:NSClassFromString(obj) forCellReuseIdentifier:obj];
        }];
        if (nibs.count == 1) self.cellIdentifier = nibs.firstObject;
    }
}

- (void)registerHeaderFooterViewNibs:(NSArray<NSString *> *)nibs {
    if (nibs.count > 0) {
        [nibs enumerateObjectsUsingBlock:^(NSString *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            if (self.kai_cellXIB && [[self.kai_cellXIB objectAtIndex:idx] boolValue])
                [self.kai_tableView registerNib:[UINib nibWithNibName:obj bundle:nil] forHeaderFooterViewReuseIdentifier:obj];
            else
                [self.kai_tableView registerClass:NSClassFromString(obj) forHeaderFooterViewReuseIdentifier:obj];
        }];
        if (nibs.count == 1) self.headerFooterIdentifier = nibs.firstObject;
    }
}

#pragma mark - :. Block事件

- (void)autoHeightCell:(ZKTableAdapterCellAutoHeightForRowBlock)block {
    self.cellAutoHeightForRowBlock = block;
}

- (void)cellIdentifierForRowAtIndexPath:(ZKTableAdapterCellIdentifierForRowBlock)block {
    self.cellIdentifierForRowAtIndexPathBlock = block;
}

- (void)didSelectRow:(ZKTableAdapterDidSelectRowBlock)block {
    self.didSelectRowBlock = block;
}

- (void)didDeselect:(ZKTableAdapterDidDeselectRowBlock)block {
    self.didDeselectRowBlock = block;
}

- (void)commitEditingStyleForRow:(ZKTableAdapterCommitEditingStyleForRowBlock)block {
    self.didEditingBlock = block;
}

- (void)titleForDeleteConfirmationButtonForRow:(ZKTableAdapterTitleForDeleteConfirmationButtonForRowBlock)block {
    self.didEditTileBlock = block;
}

- (void)canEditRow:(ZKTableAdapterCanEditRowAtIndexPathBlock)block {
    self.canEditRowBlock = block;
}

- (void)editingStyleForRow:(ZKTableAdapterEditingStyleForRowBlock)block {
    self.didEditingStyleBlock = block;
}

- (void)editActionsForRow:(ZKTableAdapterEditActionsForRowBlock)block {
    self.didEditActionsBlock = block;
}

- (void)moveRowBlock:(ZKTableAdapterMoveRowBlock)block {
    self.moveRowBlock = block;
}

- (void)cellWillDisplay:(ZKTableAdapterCellWillDisplayBlock)block {
    self.didWillDisplayBlock = block;
}

- (void)headerWillDisplay:(ZKTableAdapterHeaderWillDisplayBlock)block {
    self.didHeaderWillDisplayBlock = block;
}

- (void)footerWillDisplay:(ZKTableAdapterFooterWillDisplayBlock)block {
    self.didFooterWillDisplayBlock = block;
}

- (void)headerView:(ZKTableAdapterHeaderBlock)block {
    self.headerBlock = block;
}

- (void)headerTitle:(ZKTableAdapterTitleHeaderBlock)block {
    self.headerTitleBlock = block;
}

- (void)heightForHeaderView:(ZKTableAdapterHeightForHeaderBlock)block {
    self.heightForHeaderBlock = block;
}

- (void)accessoryType:(ZKTableAdapterAccessoryTypeBlock)block {
    self.accessoryTypeBlock = block;
}

- (void)accessoryButtonTappedForRow:(ZKTableAdapterAccessoryButtonTappedForRowAtIndexPathBlock)block {
    self.accessoryButtonTappedForRowAtIndexPathBlock = block;
}

- (void)footerView:(ZKTableAdapterFooterBlock)block {
    self.footerBlock = block;
}

- (void)footerTitle:(ZKTableAdapterTitleFooterBlock)block {
    self.footerTitleBlock = block;
}

- (void)heightForFooterView:(ZKTableAdapterHeightForFooterBlock)block {
    self.heightForFooterBlock = block;
}

- (void)numberOfSections:(ZKTableAdapterNumberOfSectionsBlock)block {
    self.numberOfSectionsBlock = block;
}

- (void)numberOfRowsInSection:(ZKTableAdapterNumberRowsBlock)block {
    self.numberRowBlock = block;
}

- (void)flattenMap:(ZKTableAdapterFlattenMapBlock)block {
    self.flattenMapBlock = block;
}

#pragma mark - :. TableView DataSource Delegate

#pragma mark - :. TableView Gourps Count
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger curNumOfSections = self.data.count;
    if (self.numberOfSectionsBlock)
        curNumOfSections = self.numberOfSectionsBlock(tableView, curNumOfSections);

    return curNumOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger curNumOfRows = 0;
    if (self.data.count > section) {
        NSMutableArray *subDataAry = self.data[ section ];
        if (self.numberRowBlock)
            curNumOfRows = self.numberRowBlock(tableView, section, subDataAry);
        else {
            curNumOfRows = subDataAry.count;
        }
    }
    return curNumOfRows;
}

#pragma mark :. GourpsView

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat height = self.titleHeaderHeight;
    if (self.heightForHeaderBlock) {
        height = self.heightForHeaderBlock(tableView, section, [self currentSectionModel:section]) ?: 0.001;
    }

    if (self.headerBlock && ((self.heightForHeaderBlock && height <= 0) || !self.heightForHeaderBlock)) {
        UITableViewHeaderFooterView *headerView = self.headerBlock(tableView, section, [self currentSectionModel:section]);
        CGFloat fittingHeight;
        if (headerView && (fittingHeight = headerView.systemFittingHeightForHeaderFooterView) > height) {
            height = fittingHeight;
        }

        if (section > 0)
            height += self.titleHeaderSpacingHeight;
    }
    return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *hederView = nil;
    if (self.headerBlock) {
        hederView = self.headerBlock(tableView, section, [self currentSectionModel:section]);
    }
    return hederView;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = nil;
    if (self.headerTitleBlock)
        title = self.headerTitleBlock(tableView, section);

    return title;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(nonnull UIView *)view forSection:(NSInteger)section {
    if (!self.headerBlock)
        view.tintColor = tableView.backgroundColor;

    if (self.didHeaderWillDisplayBlock) self.didHeaderWillDisplayBlock(view, section, [self currentSectionModel:section]);
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    if (!self.footerBlock)
        view.tintColor = [UIColor clearColor];

    if (self.didFooterWillDisplayBlock) self.didFooterWillDisplayBlock(view, section, [self currentSectionModel:section]);
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    CGFloat height = self.titleFooterHeight;
    if (self.heightForFooterBlock) {
        height = self.heightForFooterBlock(tableView, section, [self currentSectionModel:section]) ?: 0.001;
    }

    if (self.footerBlock && ((self.heightForFooterBlock && height <= 0) || !self.heightForFooterBlock)) {
        UITableViewHeaderFooterView *footerView = self.footerBlock(tableView, section, [self currentSectionModel:section]);
        CGFloat fittingHeight;
        if (footerView && (fittingHeight = footerView.systemFittingHeightForHeaderFooterView) > height) {
            height = fittingHeight;
        }

        if (section > 0)
            height += self.titleFooterSpacingHeight;
    }

    return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = nil;
    if (self.footerBlock) {
        footerView = self.footerBlock(tableView, section, [self currentSectionModel:section]);
    }
    return footerView;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    NSString *title = nil;
    if (self.footerTitleBlock)
        title = self.footerTitleBlock(tableView, section);

    return title;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"
- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
    UITableViewCellAccessoryType type = UITableViewCellAccessoryNone;
    if (self.accessoryTypeBlock) type = self.accessoryTypeBlock(tableView, indexPath, [self currentModelAtIndexPath:indexPath]);

    return type;
}
#pragma clang diagnostic pop

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    !self.accessoryButtonTappedForRowAtIndexPathBlock ?: self.accessoryButtonTappedForRowAtIndexPathBlock(indexPath, [self currentModelAtIndexPath:indexPath]);
}

#pragma mark :. 侧边
/**
 *  @brief 侧边栏字母
 */
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    NSArray *sectionArr = nil;
    if (self.isSection) {
        sectionArr = self.sectionIndexTitles;
    }
    return sectionArr;
}

/**
 *  @brief 侧边字母点击
 */
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    NSInteger indexs = self.sectionIndexTitles.count == [[_theCollation sectionTitles] count] ? index : index - 1;
    if ([title isEqualToString:@"{search}"]) {
        [tableView scrollRectToVisible:_searchBar.frame animated:NO];
        indexs = -1;
    }

    return indexs;
}

#pragma mark :. delegate

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL edit = tableView.editing;
    if (self.canEditRowBlock) {
        edit = self.canEditRowBlock(indexPath, [self currentModelAtIndexPath:indexPath]);
    }

    return edit;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCellEditingStyle style = UITableViewCellEditingStyleNone;
    if (self.didEditingStyleBlock)
        style = self.didEditingStyleBlock(tableView, indexPath, [self currentModelAtIndexPath:indexPath]);
    else if (self.didEditActionsBlock && !tableView.allowsMultipleSelectionDuringEditing)
        style = UITableViewCellEditingStyleDelete;

    return style;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.didEditingBlock)
        self.didEditingBlock(tableView, editingStyle, indexPath, [self currentModelAtIndexPath:indexPath]);
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = nil;
    if (self.didEditTileBlock)
        title = self.didEditTileBlock(tableView, indexPath, [self currentModelAtIndexPath:indexPath]);

    return title;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *ary = [NSArray array];
    if (self.didEditActionsBlock)
        ary = self.didEditActionsBlock(tableView, indexPath, [self currentModelAtIndexPath:indexPath]);

    return ary;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat curHeight = 0;
    if (self.cellAutoHeightForRowBlock) {
        id curModel          = [self currentModelAtIndexPath:indexPath];
        NSString *identifier = [self _kai_cellIdentifierForRowAtIndexPath:indexPath model:curModel];
        curHeight            = self.cellAutoHeightForRowBlock(tableView, indexPath, identifier, curModel);
    } else {
        curHeight = tableView.rowHeight;
    }
    return curHeight;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.isCanMoveRow;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    if (self.moveRowBlock) {
        id sourceModel      = [self currentModelAtIndexPath:sourceIndexPath];
        id destinationModel = [self currentModelAtIndexPath:destinationIndexPath];
        self.moveRowBlock(tableView, sourceIndexPath, sourceModel, destinationIndexPath, destinationModel);
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id curModel           = [self currentModelAtIndexPath:indexPath];
    NSString *identifier  = [self _kai_cellIdentifierForRowAtIndexPath:indexPath model:curModel];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];

    NSAssert(cell, @"cell is nil Identifier ⤭ %@ ⤪", identifier);

    [self configureCell:cell forIndexPath:indexPath withObject:curModel];

    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.paddedSeparator) {
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            [cell setSeparatorInset:UIEdgeInsetsZero];
        }
        if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
            [cell setPreservesSuperviewLayoutMargins:NO];
        }
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:UIEdgeInsetsZero];
        }
    }

    id curModel = [self currentModelAtIndexPath:indexPath];

    if (self.didWillDisplayBlock) {
        self.didWillDisplayBlock(cell, indexPath, curModel, YES);
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.kai_indexPath = indexPath;

    if (self.isAntiHurry) {
        self.timeInterval = self.timeInterval == 0 ? defaultInterval : self.timeInterval;
        if (self.isIgnoreEvent) {
            return;
        } else if (self.timeInterval > 0) {
            [self performSelector:@selector(resetState) withObject:nil afterDelay:self.timeInterval];
        }

        self.isIgnoreEvent = YES;
    }
    if (self.didSelectRowBlock) {
        id curModel = [self currentModelAtIndexPath:indexPath];
        self.didSelectRowBlock(tableView, indexPath, curModel);
    }
}

- (void)resetState {
    self.isIgnoreEvent = NO;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.kai_indexPath = indexPath;
    if (self.didDeselectRowBlock) {
        id curModel = [self currentModelAtIndexPath:indexPath];
        self.didDeselectRowBlock(tableView, indexPath, curModel);
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.scrollViewddBlock)
        self.scrollViewddBlock(scrollView);

    if (self.isHover) {
        CGFloat sectionHeaderHeight = 40;
        if (scrollView.contentOffset.y <= sectionHeaderHeight && scrollView.contentOffset.y >= 0) {
            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
        } else if (scrollView.contentOffset.y >= sectionHeaderHeight) {
            scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
        }
    }

    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(scrollViewDidEndScrollingAnimation:) object:scrollView];
    [self performSelector:@selector(scrollViewDidEndScrollingAnimation:) withObject:scrollView afterDelay:0.5];
}

#pragma mark - :. public methods

//section 头部,为了iOS6的美化
- (UIView *)tableViewSectionView:(UITableView *)tableView section:(NSInteger)section {
    UIView *customHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.kai_tableView.bounds), self.titleHeaderHeight)];
    UIColor *color           = tableView.backgroundColor;
    if (!color) {
        color = [UIColor colorWithRed:0.926 green:0.920 blue:0.956 alpha:1.000];
    }
    customHeaderView.backgroundColor = color;

    UILabel *headerLabel        = [[UILabel alloc] initWithFrame:CGRectMake(15.0f, 0, CGRectGetWidth(customHeaderView.bounds) - 15.0f, self.titleHeaderHeight)];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.font            = [UIFont boldSystemFontOfSize:14.0f];
    headerLabel.textColor       = [UIColor darkGrayColor];
    [customHeaderView addSubview:headerLabel];

    if (self.isSection) {
        BOOL showSection = NO;
        showSection      = [tableView numberOfRowsInSection:section] != 0;
        headerLabel.text = (showSection) ? (self.sectionIndexTitles.count == [[_theCollation sectionTitles] count] ? [_sectionIndexTitles objectAtIndex:section] : [_sectionIndexTitles objectAtIndex:section + 1]) : nil;
    }
    return customHeaderView;
}

- (UITableViewHeaderFooterView *)tableViewSectionViewWithIdentifier:(NSString *)identifier
                                                            section:(NSInteger)section {
    UITableViewHeaderFooterView *sectionHeadView = [self.kai_tableView dequeueReusableHeaderFooterViewWithIdentifier:identifier];
    if (!sectionHeadView) {
        sectionHeadView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:identifier];

        UIView *customHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, !section ? 0 : self.titleHeaderSpacingHeight, CGRectGetWidth(self.kai_tableView.bounds), self.titleHeaderHeight)];
        UIColor *color = self.kai_tableView.backgroundColor;
        if (!color)
            color                        = [UIColor colorWithRed:0.926 green:0.920 blue:0.956 alpha:1.000];
        customHeaderView.backgroundColor = color;
        [sectionHeadView.contentView addSubview:customHeaderView];

        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 0, CGRectGetWidth(self.kai_tableView.bounds) - 10.0f, self.titleHeaderHeight)];
        headerLabel.tag             = 1;
        headerLabel.backgroundColor = [UIColor clearColor];
        headerLabel.font            = [UIFont boldSystemFontOfSize:14.0f];
        headerLabel.textColor       = [UIColor darkGrayColor];
        [customHeaderView addSubview:headerLabel];

        UIView *lineView         = [[UIView alloc] initWithFrame:CGRectMake(0, customHeaderView.frame.size.height - 1, customHeaderView.frame.size.width, 1)];
        lineView.backgroundColor = [UIColor colorWithRed:246.0 / 255.0 green:245.0 / 255.0 blue:245.0 / 255.0 alpha:1];
        [customHeaderView addSubview:lineView];

        if (self.isSection) {
            BOOL showSection = NO;
            showSection      = [self.kai_tableView numberOfRowsInSection:section] != 0;
            headerLabel.text = (showSection) ? (self.sectionIndexTitles.count == [[_theCollation sectionTitles] count] ? [_sectionIndexTitles objectAtIndex:section] : [_sectionIndexTitles objectAtIndex:section + 1]) : nil;
        }
    }
    return sectionHeadView;
}

#pragma mark :. Handler

- (NSString *)_kai_cellIdentifierForRowAtIndexPath:(NSIndexPath *)indexPath model:(id)model {
    NSString *curCellIdentifier = nil;
    if (self.cellIdentifierForRowAtIndexPathBlock) {
        curCellIdentifier = self.cellIdentifierForRowAtIndexPathBlock(indexPath, model);
    } else {
        curCellIdentifier = self.cellIdentifier;
    }
    return curCellIdentifier;
}

- (id)currentSectionModel:(NSInteger)section {
    id currentModel = nil;
    if (section < self.data.count) {
        NSArray *arr = [self.data objectAtIndex:section];
        if (arr.count)
            currentModel = [arr objectAtIndex:0];
    }
    return currentModel;
}

- (NSArray *)modelsForSelectedRows {
    NSArray<NSIndexPath *> *indexPaths = [self.kai_tableView indexPathsForSelectedRows];
    if (indexPaths.count == 0) return nil;

    NSMutableArray *result = NSMutableArray.new;
    for (NSIndexPath *each in indexPaths) {
        id obj = [self currentModelAtIndexPath:each];
        [result addObject:obj];
    }

    return result;
}

- (id)currentModel {
    return [self currentModelAtIndexPath:self.kai_indexPath];
}

- (id)currentModelAtIndexPath:(NSIndexPath *)indexPath {
    if (self.flattenMapBlock) {
        return self.flattenMapBlock(self.data, indexPath);
    } else if (self.data.count > indexPath.section) {
        NSMutableArray *subDataAry = self.data[ indexPath.section ];
        if (subDataAry.count > indexPath.row) {
            id curModel = subDataAry[ indexPath.row ];
            return curModel;
        }
    }
    return nil;
}

- (void)configureCell:(UITableViewCell<ZKTableViewAdapterInjectionDelegate> *)cell forIndexPath:(NSIndexPath *)indexPath withObject:(id)obj {
    if ([cell respondsToSelector:@selector(bindViewModel:forIndexPath:)]) {
        [cell bindViewModel:obj forIndexPath:indexPath];
    }
}

- (void)kai_reloadGroupDataAry:(NSArray *)data {
    [self stripAdapterGroupData:data];
}

- (void)stripAdapterGroupData:(NSArray *)data {
    [self.data removeAllObjects];
    for (NSInteger i = 0; i < data.count; i++)
        [self kai_makeUpDataAryForSection:i];

    for (int idx = 0; idx < self.data.count; idx++) {
        NSMutableArray *subAry = self.data[idx];
        if (subAry.count)
            [subAry removeAllObjects];
        id obj = [data objectAtIndex:idx];
        if ([obj isKindOfClass:[NSArray class]]) {
            [subAry addObjectsFromArray:obj];
        } else {
            [subAry addObject:obj];
        }
    }
    [self.kai_tableView reloadData];
}

- (void)kai_reloadGroupDataAry:(NSArray *)data
                    forSection:(NSInteger)section {
    [self stripAdapterGroupData:data forSection:section];
}

- (void)stripAdapterGroupData:(NSArray *)data forSection:(NSInteger)section {
    if (data.count == 0)
        return;

    NSMutableArray *subAry = self.data[section];
    if (subAry.count)
        [subAry removeAllObjects];
    [subAry addObjectsFromArray:data];

    [self.kai_tableView beginUpdates];
    [self.kai_tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationNone];
    [self.kai_tableView endUpdates];
}

- (void)appendSection:(NSArray *)data {
    [self.data addObject:[NSMutableArray arrayWithArray:data]];
    [self.kai_tableView reloadData];
}

- (void)insertSection:(NSArray *)data
                    forSection:(NSInteger)section {
    [self.data insertObject:[NSMutableArray arrayWithArray:data] atIndex:section == -1 ? 0 : section];
    [self.kai_tableView reloadData];
}

- (void)insertSections:(NSArray *)newDataAry
                           forSection:(NSInteger)section {
    NSMutableArray *idxArray = [NSMutableArray array];
    if (section < 0) {
        for (NSInteger i = 0; i < newDataAry.count; i++) {
            [self.data insertObject:[NSMutableArray array] atIndex:0];
            [idxArray addObject:@(i)];
        }
    } else {
        for (NSInteger i = 0; i < newDataAry.count; i++) {
            [self.data insertObject:[NSMutableArray array] atIndex:section + i];
            [idxArray addObject:@(section + i)];
        }
    }

    for (NSInteger i = 0; i < idxArray.count; i++) {
        NSInteger idx          = [[idxArray objectAtIndex:i] integerValue];
        NSMutableArray *subAry = self.data[ idx ];
        if (subAry.count)
            [subAry removeAllObjects];
        id data = [newDataAry objectAtIndex:i];
        if ([data isKindOfClass:[NSArray class]]) {
            [subAry addObjectsFromArray:data];
        } else {
            [subAry addObject:data];
        }
    }
    [self.kai_tableView reloadData];
}

- (void)deleteSection:(NSInteger)section {
    NSMutableArray *subAry = self.data[ section ];
    if (subAry.count)
        [subAry removeAllObjects];

    [self.kai_tableView beginUpdates];
    [self.kai_tableView deleteSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationNone];
    [self.kai_tableView endUpdates];
}

- (void)stripAdapterData:(NSArray *)data {
    self.data = nil;
    [self stripAdapterData:data forSection:0];
}

- (void)stripAdapterData:(NSArray *)data forSection:(NSInteger)section {
    [self kai_makeUpDataAryForSection:section];
    NSMutableArray *subAry = self.data[ section ];
    if (subAry.count)
        [subAry removeAllObjects];
    if (data.count) {
        [subAry addObjectsFromArray:data];
    }
    [self.kai_tableView reloadData];
}

- (void)reloadData:(NSArray *)data {
    self.data = nil;
    [self reloadData:data forSection:0];
}

- (void)reloadData:(NSArray *)data forSection:(NSInteger)section {
    if (data.count == 0)
        return;

    NSIndexSet *curIndexSet = [self kai_makeUpDataAryForSection:section];
    NSMutableArray *subAry  = self.data[ section ];
    if (subAry.count)
        [subAry removeAllObjects];
    [subAry addObjectsFromArray:data];

    [self.kai_tableView beginUpdates];
    if (curIndexSet) {
        [self.kai_tableView insertSections:curIndexSet withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        [self.kai_tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationNone];
    }
    [self.kai_tableView endUpdates];
}

- (void)insertRows:(NSArray *)data {
    [self insertRows:data forSection:0];
}

- (void)insertRows:(NSArray *)data forSection:(NSInteger)section {
    if (data.count == 0)
        return;

    NSIndexSet *curIndexSet = [self kai_makeUpDataAryForSection:section];
    NSMutableArray *subAry;
    if (section < 0) {
        subAry = self.data[ 0 ];
    } else
        subAry = self.data[ section ];

    if (curIndexSet) {
        [subAry addObjectsFromArray:data];
        [self.kai_tableView beginUpdates];
        [self.kai_tableView insertSections:curIndexSet withRowAnimation:UITableViewRowAnimationNone];
        [self.kai_tableView endUpdates];
    } else {
        __block NSMutableArray *curIndexPaths = [NSMutableArray arrayWithCapacity:data.count];
        [data enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            [curIndexPaths addObject:[NSIndexPath indexPathForRow:subAry.count + idx inSection:section]];
        }];
        [subAry addObjectsFromArray:data];
        [self.kai_tableView beginUpdates];
        [self.kai_tableView insertRowsAtIndexPaths:curIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.kai_tableView endUpdates];
    }
}

- (void)insertData:(id)model forIndexPath:(NSIndexPath *)indexPath {
    NSIndexSet *curIndexSet = [self kai_makeUpDataAryForSection:indexPath.section];
    NSMutableArray *subAry  = self.data[indexPath.section];
    if (subAry.count < indexPath.row)
        return;
    [subAry insertObject:model atIndex:indexPath.row];

    [self.kai_tableView beginUpdates];
    if (curIndexSet) {
        [self.kai_tableView insertSections:curIndexSet withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        [self.kai_tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    [self.kai_tableView endUpdates];
}

- (void)deleteRowsAtIndexPath:(NSIndexPath *)indexPath {
    [self deleteRowsAtIndexPaths:@[indexPath]];
}

- (void)deleteRowsAtIndexPaths:(NSArray *)indexPaths {
    NSMutableArray *delArray = [NSMutableArray array];
    for (NSArray *arr in self.data) {
        NSMutableArray *sectionArray = [NSMutableArray array];
        [sectionArray addObjectsFromArray:arr];
        [delArray addObject:sectionArray];
    }

    for (NSIndexPath *indexPath in indexPaths) {
        if (self.data.count <= indexPath.section)
            continue;
        NSMutableArray *subAry = self.data[ indexPath.section ];
        if (subAry.count <= indexPath.row)
            continue;

        [[delArray objectAtIndex:indexPath.section] removeObject:[subAry objectAtIndex:indexPath.row]];
    }
    self.data = delArray;

    [self.kai_tableView beginUpdates];
    [self.kai_tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    [self.kai_tableView endUpdates];
}

- (void)reloadData:(id)model
      forIndexPath:(NSIndexPath *)indexPath {
    [self reloadData:model forIndexPath:indexPath animation:UITableViewRowAnimationAutomatic];
}

- (void)reloadData:(id)model
      forIndexPath:(NSIndexPath *)indexPath
         animation:(UITableViewRowAnimation)animated {
    if (self.data.count > indexPath.section) {
        NSMutableArray *subDataAry = self.data[indexPath.section];
        if (subDataAry.count > indexPath.row) {
            [subDataAry replaceObjectAtIndex:indexPath.row withObject:model];
            [self.kai_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:animated];
        }
    }
}

// 新建section个二维数组
- (NSIndexSet *)kai_makeUpDataAryForSection:(NSInteger)section {
    NSMutableIndexSet *curIndexSet = nil;
    if (self.data.count <= section) {
        curIndexSet = [NSMutableIndexSet indexSet];
        for (NSInteger idx = 0; idx < (section - self.data.count + 1); idx++) {
            NSMutableArray *subAry = [NSMutableArray array];
            if (section < 0) {
                [self.data insertObject:subAry atIndex:0];
                [curIndexSet addIndex:0];
                break;
            } else {
                [self.data addObject:subAry];
                [curIndexSet addIndex:section - idx];
            }
        }
    }
    return curIndexSet;
}

#pragma mark - :. getters and setters

- (NSMutableArray<NSMutableArray *> *)data {
    if (!_data) {
        _data = NSMutableArray.new;
    }
    return _data;
}

- (NSMutableArray *)dataSource {
    NSMutableArray *array = [NSMutableArray array];
    if (self.data.count > 1)
        array = self.data;
    else
        array = self.data.firstObject;

    return array;
}

- (NSArray *)sectionIndexTitles {
    if (!_sectionIndexTitles) {
        NSMutableArray *sectionIndex = [NSMutableArray array];
        if (self.kai_tableView.tableHeaderView && [self.kai_tableView.tableHeaderView isKindOfClass:[UISearchBar class]]) {
            self.searchBar = (UISearchBar *)self.kai_tableView.tableHeaderView;
            [sectionIndex addObject:UITableViewIndexSearch];
        }

        if (self.sectionIndexTitle)
            [sectionIndex addObjectsFromArray:self.sectionIndexTitle];
        else
            [sectionIndex addObjectsFromArray:[UILocalizedIndexedCollation.currentCollation sectionIndexTitles]];
        _sectionIndexTitles = sectionIndex;
    }
    return _sectionIndexTitles;
}

- (void)setSectionIndexTitle:(NSArray *)sectionIndexTitle {
    _sectionIndexTitle                                                               = sectionIndexTitle;
    _sectionIndexTitles                                                              = nil;
    if (sectionIndexTitle.count != 0 && _titleHeaderHeight < 0.2) _titleHeaderHeight = 30.f;
}

- (UILocalizedIndexedCollation *)theCollation {
    if (!_theCollation) {
        _theCollation = [UILocalizedIndexedCollation currentCollation];
    }
    return _theCollation;
}

- (BOOL)allowsMultipleSelectionDuringEditing {
    return self.kai_tableView.allowsMultipleSelectionDuringEditing;
}

- (void)setAllowsMultipleSelectionDuringEditing:(BOOL)allowsMultipleSelectionDuringEditing {
    self.kai_tableView.allowsMultipleSelectionDuringEditing = allowsMultipleSelectionDuringEditing;
    self.kai_tableView.editing                              = allowsMultipleSelectionDuringEditing;
}

- (NSString *)cellIdentifier {
    if (_cellIdentifier == nil) {
        NSString *curVCIdentifier = nil;
        if (curVCIdentifier) {
            NSString *curCellIdentifier = [NSString stringWithFormat:@"KAI%@Cell", curVCIdentifier];
            _cellIdentifier             = curCellIdentifier;
        }
    }
    return _cellIdentifier;
}

#pragma mark - :. getters and setters

- (void)setKai_tableView:(UITableView *)kai_tableView {
    _kai_tableView = kai_tableView;
    
    kai_tableView.delaysContentTouches = NO;
    kai_tableView.canCancelContentTouches = YES;
    
    // Remove touch delay (since iOS 8)
    UIView *wrapView = kai_tableView.subviews.firstObject;
    // UITableViewWrapperView
    if (wrapView && [NSStringFromClass(wrapView.class) hasSuffix:@"WrapperView"]) {
        for (UIGestureRecognizer *gesture in wrapView.gestureRecognizers) {
            // UIScrollViewDelayedTouchesBeganGestureRecognizer
            if ([NSStringFromClass(gesture.class) containsString:@"DelayedTouchesBegan"] ) {
                gesture.enabled = NO;
                break;
            }
        }
    }
}

@end

