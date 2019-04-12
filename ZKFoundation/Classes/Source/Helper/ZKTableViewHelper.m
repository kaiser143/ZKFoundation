//
//  ZKTableViewHelper.m
//  FBSnapshotTestCase
//
//  Created by Kaiser on 2019/3/12.
//

#import "ZKTableViewHelper.h"
#import "UIView+ZKHelper.h"
#import "UITableView+ZKHelper.h"
#import "UITableViewCell+ZKHelper.h"

#define defaultInterval .5 //默认时间间隔

@interface ZKTableViewHelper ()

@property (nonatomic, strong) NSMutableArray<NSMutableArray *> *dataArray;

@property (nonatomic, strong) NSMutableArray *sectionIndexTitles;

@property (nonatomic, strong) UILocalizedIndexedCollation *theCollation;

@property (nonatomic, assign) NSTimeInterval timeInterval;

@property (nonatomic, assign) BOOL isIgnoreEvent;

/**

 *  @brief 头部搜索
 */
@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic, copy) ZKTableHelperCellAutoHeightForRowBlock cellAutoHeightForRowBlock;
@property (nonatomic, copy) ZKTableHelperCellIdentifierForRowBlock cellIdentifierForRowAtIndexPathBlock;
@property (nonatomic, copy) ZKTableHelperDidSelectBlock didSelectBlock;
@property (nonatomic, copy) ZKTableHelperDidDeSelectBlock didDeSelectBlock;
@property (nonatomic, copy) ZKTableHelperDidMoveToRowBlock didMoveToRowBlock;
@property (nonatomic, copy) ZKTableHelperDidWillDisplayBlock didWillDisplayBlock;

@property (nonatomic, copy) ZKTableHelperDidEditingBlock didEditingBlock;
@property (nonatomic, copy) ZKTableHelperDidEditTitleBlock didEditTileBlock;

@property (nonatomic, copy) ZKTableHelperEditingStyleBlock didEditingStyle;
@property (nonatomic, copy) ZKTableHelperDidEditActionsBlock didEditActionsBlock;

@property (nonatomic, copy) ZKScrollViewWillBeginDraggingBlock scrollViewBdBlock;
@property (nonatomic, copy) ZKScrollViewDidScrollBlock scrollViewddBlock;
@property (nonatomic, copy) ZKScrollViewDidEndDraggingBlock scrollViewDicEndBlock;

@property (nonatomic, copy) ZKTableHelperHeaderBlock headerBlock;
@property (nonatomic, copy) ZKTableHelperTitleHeaderBlock headerTitleBlock;

@property (nonatomic, copy) ZKTableHelperFooterBlock footerBlock;
@property (nonatomic, copy) ZKTableHelperTitleFooterBlock footerTitleBlock;

@property (nonatomic, copy) ZKTableHelperNumberOfSectionsBlock numberOfSections;
@property (nonatomic, copy) ZKTableHelperNumberRowsBlock numberRow;

@property (nonatomic, copy) ZKTableHelperCurrentModelAtIndexPathBlock currentModelAtIndexPath;
@property (nonatomic, copy) ZKTableHelperScrollViewDidEndScrollingBlock scrollViewDidEndScrolling;

@end

@implementation ZKTableViewHelper

- (instancetype)init {
    if (self = [super init]) {
        [self initialization];
    }
    return self;
}

- (void)initialization {
    self.titleHeaderHeight = 0.1;
    self.titleFooterHeight = 0.1;
}

#pragma mark -
#pragma mark :. getset
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

- (void)registerNibs:(NSArray<NSString *> *)nibs {
    if (nibs.count > 0) {
        [nibs enumerateObjectsUsingBlock:^(NSString *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            if (self.kai_cellXIB && [[self.kai_cellXIB objectAtIndex:idx] boolValue])
                [self.kai_tableView registerNib:[UINib nibWithNibName:obj bundle:nil] forCellReuseIdentifier:obj];
            else
                [self.kai_tableView registerClass:NSClassFromString(obj) forCellReuseIdentifier:obj];
        }];
        if (nibs.count == 1) {
            self.cellIdentifier = nibs[ 0 ];
        }
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

- (UILocalizedIndexedCollation *)theCollation {
    if (!_theCollation) {
        _theCollation = [UILocalizedIndexedCollation currentCollation];
    }
    return _theCollation;
}

#pragma mark -
#pragma mark :. Block事件

- (void)autoHeightCell:(ZKTableHelperCellAutoHeightForRowBlock)cb {
    self.cellAutoHeightForRowBlock = cb;
}

- (void)cellIdentifierForRowAtIndexPath:(ZKTableHelperCellIdentifierForRowBlock)cb {
    self.cellIdentifierForRowAtIndexPathBlock = cb;
}

- (void)didSelect:(ZKTableHelperDidSelectBlock)cb {
    self.didSelectBlock = cb;
}

- (void)didDeSelect:(ZKTableHelperDidDeSelectBlock)cb {
    self.didDeSelectBlock = cb;
}

- (void)didEditing:(ZKTableHelperDidEditingBlock)cb {
    self.didEditingBlock = cb;
}

- (void)didEditTitle:(ZKTableHelperDidEditTitleBlock)cb {
    self.didEditTileBlock = cb;
}

- (void)didEditingStyle:(ZKTableHelperEditingStyleBlock)cb {
    self.didEditingStyle = cb;
}

- (void)didEditActions:(ZKTableHelperDidEditActionsBlock)cb {
    self.didEditActionsBlock = cb;
}

- (void)didMoveToRowBlock:(ZKTableHelperDidMoveToRowBlock)cb {
    self.didMoveToRowBlock = cb;
}

- (void)cellWillDisplay:(ZKTableHelperDidWillDisplayBlock)cb {
    self.didWillDisplayBlock = cb;
}

- (void)didScrollViewWillBeginDragging:(ZKScrollViewWillBeginDraggingBlock)block {
    self.scrollViewBdBlock = block;
}

- (void)didScrollViewEndDragging:(ZKScrollViewDidEndDraggingBlock)block {
    self.scrollViewDicEndBlock = block;
}

- (void)headerView:(ZKTableHelperHeaderBlock)cb {
    self.headerBlock = cb;
}

- (void)headerTitle:(ZKTableHelperTitleHeaderBlock)cb {
    self.headerTitleBlock = cb;
}

- (void)footerView:(ZKTableHelperFooterBlock)cb {
    self.footerBlock = cb;
}

- (void)footerTitle:(ZKTableHelperTitleFooterBlock)cb {
    self.footerTitleBlock = cb;
}

- (void)numberOfSections:(ZKTableHelperNumberOfSectionsBlock)cb {
    self.numberOfSections = cb;
}

- (void)numberOfRowsInSection:(ZKTableHelperNumberRowsBlock)cb {
    self.numberRow = cb;
}

- (void)didScrollViewDidScroll:(ZKScrollViewDidScrollBlock)block {
    self.scrollViewddBlock = block;
}

- (void)currentModelIndexPath:(ZKTableHelperCurrentModelAtIndexPathBlock)cb {
    self.currentModelAtIndexPath = cb;
}

- (void)didScrollViewDidEndScrolling:(ZKTableHelperScrollViewDidEndScrollingBlock)cb {
    self.scrollViewDidEndScrolling = cb;
}

#pragma mark -
#pragma mark :.TableView DataSource Delegate

#pragma mark :. TableView Gourps Count
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger curNumOfSections = self.dataArray.count;
    if (self.numberOfSections)
        curNumOfSections = self.numberOfSections(tableView, curNumOfSections);

    return curNumOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger curNumOfRows = 0;
    if (self.dataArray.count > section) {
        NSMutableArray *subDataAry = self.dataArray[ section ];
        if (self.numberRow)
            curNumOfRows = self.numberRow(tableView, section, subDataAry);
        else {
            curNumOfRows = subDataAry.count;
        }
    }
    return curNumOfRows;
}

#pragma mark :. GourpsView
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat height = self.titleHeaderHeight;
    if (self.headerBlock) {
        UIView *headerView = [tableView headerViewForSection:section];
        if (headerView) {
            if ([headerView systemLayoutSizeFitting].height > height)
                height = [headerView systemLayoutSizeFitting].height;
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
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    CGFloat height = self.titleFooterHeight;
    if (self.footerBlock) {
        UIView *footerView = [tableView footerViewForSection:section];
        if (footerView) {
            if ([footerView systemLayoutSizeFitting].height > height)
                height = [footerView systemLayoutSizeFitting].height;
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

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    if (!self.footerBlock)
        view.tintColor = [UIColor clearColor];
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

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCellEditingStyle style = UITableViewCellEditingStyleNone;
    if (self.didEditingStyle)
        style = self.didEditingStyle(tableView, indexPath, [self currentModelAtIndexPath:indexPath]);
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
    if (self.didMoveToRowBlock) {
        id sourceModel      = [self currentModelAtIndexPath:sourceIndexPath];
        id destinationModel = [self currentModelAtIndexPath:destinationIndexPath];
        self.didMoveToRowBlock(tableView, sourceIndexPath, sourceModel, destinationIndexPath, destinationModel);
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id curModel                 = [self currentModelAtIndexPath:indexPath];
    NSString *curCellIdentifier = [self _kai_cellIdentifierForRowAtIndexPath:indexPath model:curModel];
    UITableViewCell *cell       = [tableView dequeueReusableCellWithIdentifier:curCellIdentifier forIndexPath:indexPath];

    NSAssert(cell, @"cell is nil Identifier ⤭ %@ ⤪", curCellIdentifier);

    [self configureCell:cell forIndexPath:indexPath withObjet:curModel];

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
    if (self.didSelectBlock) {
        id curModel = [self currentModelAtIndexPath:indexPath];
        self.didSelectBlock(tableView, indexPath, curModel);
    }
}

- (void)resetState {
    self.isIgnoreEvent = NO;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.kai_indexPath = indexPath;
    if (self.didDeSelectBlock) {
        id curModel = [self currentModelAtIndexPath:indexPath];
        self.didDeSelectBlock(tableView, indexPath, curModel);
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.scrollViewBdBlock)
        self.scrollViewBdBlock(scrollView);
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

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(scrollViewDidEndScrollingAnimation:) object:scrollView];
    if (self.scrollViewDidEndScrolling && scrollView)
        self.scrollViewDidEndScrolling(scrollView);
}

#pragma mark :. handle

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
        UIColor *color           = self.kai_tableView.backgroundColor;
        if (!color)
            color                        = [UIColor colorWithRed:0.926 green:0.920 blue:0.956 alpha:1.000];
        customHeaderView.backgroundColor = color;
        [sectionHeadView.contentView addSubview:customHeaderView];

        UILabel *headerLabel        = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 0, CGRectGetWidth(self.kai_tableView.bounds) - 10.0f, self.titleHeaderHeight)];
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

- (NSString *)_kai_cellIdentifierForRowAtIndexPath:(NSIndexPath *)cIndexPath model:(id)cModel {
    NSString *curCellIdentifier = nil;
    if (self.cellIdentifierForRowAtIndexPathBlock) {
        curCellIdentifier = self.cellIdentifierForRowAtIndexPathBlock(cIndexPath, cModel);
    } else {
        curCellIdentifier = self.cellIdentifier;
    }
    return curCellIdentifier;
}

- (id)currentSectionModel:(NSInteger)section {
    id currentModel = nil;
    if (section < self.dataArray.count) {
        NSArray *arr = [self.dataArray objectAtIndex:section];
        if (arr.count)
            currentModel = [arr objectAtIndex:0];
    }
    return currentModel;
}

- (id)currentModel {
    return [self currentModelAtIndexPath:self.kai_indexPath];
}

- (id)currentModelAtIndexPath:(NSIndexPath *)cIndexPath {
    if (self.currentModelAtIndexPath) {
        return self.currentModelAtIndexPath(self.dataArray, cIndexPath);
    } else if (self.dataArray.count > cIndexPath.section) {
        NSMutableArray *subDataAry = self.dataArray[ cIndexPath.section ];
        if (subDataAry.count > cIndexPath.row) {
            id curModel = subDataAry[ cIndexPath.row ];
            return curModel;
        }
    }
    return nil;
}

- (void)configureCell:(UITableViewCell<ZKTableViewHelperInjectionDelegate> *)cell forIndexPath:(NSIndexPath *)indexPath withObjet:(id)obj {
    if ([cell respondsToSelector:@selector(bindViewModel:)]) {
        [cell performSelector:@selector(bindViewModel:) withObject:obj];
    }
}

- (void)kai_reloadGroupDataAry:(NSArray *)newDataAry {
    [self.dataArray removeAllObjects];
    for (NSInteger i = 0; i < newDataAry.count; i++)
        [self kai_makeUpDataAryForSection:i];

    for (int idx = 0; idx < self.dataArray.count; idx++) {
        NSMutableArray *subAry = self.dataArray[ idx ];
        if (subAry.count)
            [subAry removeAllObjects];
        id data = [newDataAry objectAtIndex:idx];
        if ([data isKindOfClass:[NSArray class]]) {
            [subAry addObjectsFromArray:data];
        } else {
            [subAry addObject:data];
        }
    }
    [self.kai_tableView reloadData];
}

- (void)kai_reloadGroupDataAry:(NSArray *)newDataAry
                    forSection:(NSInteger)cSection {
    if (newDataAry.count == 0)
        return;

    NSMutableArray *subAry = self.dataArray[ cSection ];
    if (subAry.count)
        [subAry removeAllObjects];
    [subAry addObjectsFromArray:newDataAry];

    [self.kai_tableView beginUpdates];
    [self.kai_tableView reloadSections:[NSIndexSet indexSetWithIndex:cSection] withRowAnimation:UITableViewRowAnimationNone];
    [self.kai_tableView endUpdates];
}

- (void)kai_addGroupDataAry:(NSArray *)newDataAry {
    [self.dataArray addObject:[NSMutableArray arrayWithArray:newDataAry]];
    [self.kai_tableView reloadData];
}

- (void)kai_insertGroupDataAry:(NSArray *)newDataAry
                    forSection:(NSInteger)cSection {
    [self.dataArray insertObject:[NSMutableArray arrayWithArray:newDataAry] atIndex:cSection == -1 ? 0 : cSection];
    [self.kai_tableView reloadData];
}

- (void)kai_insertMultiplGroupDataAry:(NSArray *)newDataAry
                           forSection:(NSInteger)cSection {
    NSMutableArray *idxArray = [NSMutableArray array];
    if (cSection < 0) {
        for (NSInteger i = 0; i < newDataAry.count; i++) {
            [self.dataArray insertObject:[NSMutableArray array] atIndex:0];
            [idxArray addObject:@(i)];
        }
    } else {
        for (NSInteger i = 0; i < newDataAry.count; i++) {
            [self.dataArray insertObject:[NSMutableArray array] atIndex:cSection + i];
            [idxArray addObject:@(cSection + i)];
        }
    }

    for (NSInteger i = 0; i < idxArray.count; i++) {
        NSInteger idx          = [[idxArray objectAtIndex:i] integerValue];
        NSMutableArray *subAry = self.dataArray[ idx ];
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

- (void)kai_deleteGroupData:(NSInteger)cSection {
    NSMutableArray *subAry = self.dataArray[ cSection ];
    if (subAry.count)
        [subAry removeAllObjects];

    [self.kai_tableView beginUpdates];
    [self.kai_tableView deleteSections:[NSIndexSet indexSetWithIndex:cSection] withRowAnimation:UITableViewRowAnimationNone];
    [self.kai_tableView endUpdates];
}

#pragma mark -
#pragma mark :. Plain

- (void)kai_resetDataAry:(NSArray *)newDataAry {
    self.dataArray = nil;
    [self kai_resetDataAry:newDataAry forSection:0];
}

- (void)kai_resetDataAry:(NSArray *)newDataAry forSection:(NSInteger)cSection {
    [self kai_makeUpDataAryForSection:cSection];
    NSMutableArray *subAry = self.dataArray[ cSection ];
    if (subAry.count)
        [subAry removeAllObjects];
    if (newDataAry.count) {
        [subAry addObjectsFromArray:newDataAry];
    }
    [self.kai_tableView reloadData];
}

- (void)kai_reloadDataAry:(NSArray *)newDataAry {
    self.dataArray = nil;
    [self kai_reloadDataAry:newDataAry forSection:0];
}

- (void)kai_reloadDataAry:(NSArray *)newDataAry forSection:(NSInteger)cSection {
    if (newDataAry.count == 0)
        return;

    NSIndexSet *curIndexSet = [self kai_makeUpDataAryForSection:cSection];
    NSMutableArray *subAry  = self.dataArray[ cSection ];
    if (subAry.count)
        [subAry removeAllObjects];
    [subAry addObjectsFromArray:newDataAry];

    [self.kai_tableView beginUpdates];
    if (curIndexSet) {
        [self.kai_tableView insertSections:curIndexSet withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        [self.kai_tableView reloadSections:[NSIndexSet indexSetWithIndex:cSection] withRowAnimation:UITableViewRowAnimationNone];
    }
    [self.kai_tableView endUpdates];
}

- (void)kai_addDataAry:(NSArray *)newDataAry {
    [self kai_addDataAry:newDataAry forSection:0];
}

- (void)kai_addDataAry:(NSArray *)newDataAry forSection:(NSInteger)cSection {
    if (newDataAry.count == 0)
        return;

    NSIndexSet *curIndexSet = [self kai_makeUpDataAryForSection:cSection];
    NSMutableArray *subAry;
    if (cSection < 0) {
        subAry = self.dataArray[ 0 ];
    } else
        subAry = self.dataArray[ cSection ];

    if (curIndexSet) {
        [subAry addObjectsFromArray:newDataAry];
        [self.kai_tableView beginUpdates];
        [self.kai_tableView insertSections:curIndexSet withRowAnimation:UITableViewRowAnimationNone];
        [self.kai_tableView endUpdates];
    } else {
        __block NSMutableArray *curIndexPaths = [NSMutableArray arrayWithCapacity:newDataAry.count];
        [newDataAry enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            [curIndexPaths addObject:[NSIndexPath indexPathForRow:subAry.count + idx inSection:cSection]];
        }];
        [subAry addObjectsFromArray:newDataAry];
        [self.kai_tableView beginUpdates];
        [self.kai_tableView insertRowsAtIndexPaths:curIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.kai_tableView endUpdates];
    }
}

- (void)kai_insertData:(id)cModel atIndex:(NSIndexPath *)cIndexPath;
{
    NSIndexSet *curIndexSet = [self kai_makeUpDataAryForSection:cIndexPath.section];
    NSMutableArray *subAry  = self.dataArray[ cIndexPath.section ];
    if (subAry.count < cIndexPath.row)
        return;
    [subAry insertObject:cModel atIndex:cIndexPath.row];

    [self.kai_tableView beginUpdates];
    if (curIndexSet) {
        [self.kai_tableView insertSections:curIndexSet withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        [self.kai_tableView insertRowsAtIndexPaths:@[cIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    [self.kai_tableView endUpdates];
}

- (void)kai_deleteDataAtIndex:(NSIndexPath *)cIndexPath {
    [self kai_deleteDataAtIndexs:@[cIndexPath]];
}

- (void)kai_deleteDataAtIndexs:(NSArray *)indexPaths {
    NSMutableArray *delArray = [NSMutableArray array];
    for (NSArray *arr in self.dataArray) {
        NSMutableArray *sectionArray = [NSMutableArray array];
        [sectionArray addObjectsFromArray:arr];
        [delArray addObject:sectionArray];
    }

    for (NSIndexPath *indexPath in indexPaths) {
        if (self.dataArray.count <= indexPath.section)
            continue;
        NSMutableArray *subAry = self.dataArray[ indexPath.section ];
        if (subAry.count <= indexPath.row)
            continue;

        [[delArray objectAtIndex:indexPath.section] removeObject:[subAry objectAtIndex:indexPath.row]];
    }
    self.dataArray = delArray;

    [self.kai_tableView beginUpdates];
    [self.kai_tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    [self.kai_tableView endUpdates];
}

- (void)kai_replaceDataAtIndex:(id)model
                  forIndexPath:(NSIndexPath *)cIndexPath {
    [self kai_replaceDataAtIndex:model forIndexPath:cIndexPath withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)kai_replaceDataAtIndex:(id)model
                  forIndexPath:(NSIndexPath *)cIndexPath
              withRowAnimation:(UITableViewRowAnimation)animated {
    if (self.dataArray.count > cIndexPath.section) {
        NSMutableArray *subDataAry = self.dataArray[ cIndexPath.section ];
        if (subDataAry.count > cIndexPath.row) {
            [subDataAry replaceObjectAtIndex:cIndexPath.row withObject:model];
            [self.kai_tableView reloadRowsAtIndexPaths:@[cIndexPath] withRowAnimation:animated];
        }
    }
}

- (NSIndexSet *)kai_makeUpDataAryForSection:(NSInteger)cSection {
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
        _dataArray = NSMutableArray.new;
    }
    return _dataArray;
}


@end

