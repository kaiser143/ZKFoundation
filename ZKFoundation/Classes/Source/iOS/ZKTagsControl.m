//
//  ZKTagsControl.m
//  ZKTagsControl
//
//  Created by zhangkai on 2019/5/24.
//  Copyright © 2019 zhangkai. All rights reserved.
//

#import "ZKTagsControl.h"
#import <ZKCategories/ZKCategories.h>
#import "ZKCollectionViewAdapterInjectionDelegate.h"

@class _KAITextField;

@protocol _KAITextFieldDelegate <NSObject>

- (void)textFieldDidDeleteBackwardForBlank:(_KAITextField *)textField;

@end

@interface ZKTagItem ()
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) id value;
@end

@implementation ZKTagItem

- (instancetype)initWithTitle:(NSString *)title value:(id)value {
    self = [super init];
    if (self == nil) return nil;

    _title = title;
    _value = value;

    return self;
}

+ (instancetype)itemWithTitle:(NSString *)title value:(id)value {
    return [[self alloc] initWithTitle:title value:value];
}

@end

@interface _KAITextField : UITextField
@property (nonatomic, weak) id<_KAITextFieldDelegate> _kai_delegate;
@end

@implementation _KAITextField

- (void)deleteBackward {
    NSRange range = self.selectedRange;
    if (range.location == 0) {
        if (self._kai_delegate && [self._kai_delegate respondsToSelector:@selector(textFieldDidDeleteBackwardForBlank:)]) {
            [self._kai_delegate textFieldDidDeleteBackwardForBlank:self];
        }
    }

    [super deleteBackward];
}

@end

@interface ZKTagsControl () <UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate, _KAITextFieldDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) _KAITextField *field;
@property (nonatomic, strong) UIView *placeholderView;
@property (nonatomic, strong) NSString *identifier;

@property (nonatomic, strong) NSLayoutConstraint *placeholderViewWidthC;
@property (nonatomic, strong) NSLayoutConstraint *collectionViewWidthC;
@property (nonatomic, assign) BOOL hasInstalledConstraints;

@end

@implementation ZKTagsControl

- (instancetype)init {
    self = [super init];
    if (self == nil) return nil;

    [self commonInit];

    return self;
}

#pragma mark - :. _KAITextFieldDelegate

- (void)textFieldDidDeleteBackwardForBlank:(_KAITextField *)textField {
    [self deleteCharacters:nil];
}

#pragma mark - :. UICollectionViewDelegate

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    //    return UIEdgeInsetsMake(0, CONTENT_LEFT_MARGIN, 0, 0);
    return UIEdgeInsetsZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = [self.delegate tagsControl:self widthForItemAtIndex:indexPath.item];
    return CGSizeMake(width, self.collectionView.height);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self removeTagAtIndexPath:indexPath];
}

#pragma mark - :. UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.tags.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell<ZKCollectionViewAdapterInjectionDelegate> *cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.identifier forIndexPath:indexPath];
    if ([cell respondsToSelector:@selector(bindViewModel:forItemAtIndexPath:)]) {
        [cell bindViewModel:[self.tags objectOrNilAtIndex:indexPath.item] forItemAtIndexPath:indexPath];
    }

    return cell;
}

#pragma mark - :. public methods

- (void)registerClass:(nullable Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier {
    self.identifier = identifier;
    [self.collectionView registerClass:cellClass forCellWithReuseIdentifier:identifier];
}

- (void)addTags:(NSArray<ZKTagItem *> *)tags {
    if (tags.count == 0) return;

    [UIView performWithoutAnimation:^{
        [self.collectionView performBatchUpdates:^{
            NSMutableArray *array = NSMutableArray.new;
            [tags enumerateObjectsUsingBlock:^(ZKTagItem *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
                [self.tags addObject:obj];

                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.tags.count - 1 inSection:0];
                [array addObject:indexPath];
            }];

            [self.collectionView insertItemsAtIndexPaths:array];
        }
            completion:^(BOOL finished) {
                [self.collectionView scrollToRightAnimated:YES];
            }];
    }];
}

- (void)addTag:(ZKTagItem *)tag {
    [self.tags addObject:tag];

    [UIView performWithoutAnimation:^{
        [self.collectionView performBatchUpdates:^{
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.tags.count - 1 inSection:0];
            [self.collectionView insertItemsAtIndexPaths:@[indexPath]];
        }
            completion:^(BOOL finished) {
                [self.collectionView scrollToRightAnimated:YES];
            }];
    }];
}

- (void)removeTagAtIndexPath:(NSIndexPath *)indexPath {
    [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
    ZKTagItem *item = [self.tags objectOrNilAtIndex:indexPath.item];
    [self.tags removeObject:item];

    [self.collectionView performBatchUpdates:^{
        [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
    }
        completion:^(BOOL finished) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(tagsControl:didRemoveWithItem:)]) {
                [self.delegate tagsControl:self didRemoveWithItem:item];
            }
        }];
}

- (void)removeAll {
    [self.tags removeAllObjects];
    [self.collectionView reloadData];
}

- (void)deleteCharacters:(id)obj {
    if (self.prefersHighlightBeforeDelete) {
        NSArray *array = self.collectionView.indexPathsForSelectedItems;
        if (array.count != 0) {
            for (NSIndexPath *indexPath in array) [self removeTagAtIndexPath:indexPath];
        } else {
            NSInteger item = self.tags.count - 1;
            if (item < 0) return;

            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:0];
            [self.collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
        }
    } else {
        NSInteger item = self.tags.count - 1;
        if (item < 0) return;

        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:0];
        [self removeTagAtIndexPath:indexPath];
    }
}

#pragma mark - Private Methods

- (void)commonInit {
    self.preferredMinFieldWidth       = 100;
    self.prefersHighlightBeforeDelete = YES;

    @weakify(self);
    [self.field setShouldReturnBlock:^BOOL(UITextField *_Nonnull textField) {
        @strongify(self);
        if (self.delegate && [self.delegate respondsToSelector:@selector(tagsControlShouldReturn:)]) {
            return [self.delegate tagsControlShouldReturn:self];
        }
        return NO;
    }];
    [self.field setDidBeginEditingBlock:^(UITextField *_Nonnull textField) {
        @strongify(self);
        self.placeholderViewWidthC.constant = 0;
        [self layoutIfNeeded];
    }];
    [self.field setDidEndEditingBlock:^(UITextField *_Nonnull textField) {
        @strongify(self);
        if (self.tags.count == 0) {
            self.placeholderViewWidthC.constant = self.inputLeftImage.size.width;
            [self layoutIfNeeded];
        }
    }];
    [self.field setShouldChangeCharactersInRangeBlock:^BOOL(UITextField *_Nonnull textField, NSRange range, NSString *_Nonnull string) {
        @strongify(self);
        if (self.delegate && [self.delegate respondsToSelector:@selector(tagsControl:inputValueChanged:)]) {
            NSString *value = [textField.text stringByReplacingCharactersInRange:range withString:string];
            [self.delegate tagsControl:self inputValueChanged:value];
        }
        return YES;
    }];
    [self.collectionView addObserverBlockForKeyPath:@keypath(self.collectionView, contentSize)
                                              block:^(UICollectionView *obj, NSValue *oldVal, NSValue *newVal) {
                                                  @strongify(self);
                                                  if (CGSizeEqualToSize(oldVal.CGSizeValue, newVal.CGSizeValue)) return;

                                                  CGSize size      = newVal.CGSizeValue;
                                                  CGFloat maxWidth = self.width - (self.safeArea.left + self.safeArea.right) - self.preferredMinFieldWidth - self.placeholderView.width - 8;
                                                  if (obj.width <= maxWidth && obj.width != size.width) {
                                                      self.collectionViewWidthC.constant = MIN(maxWidth, size.width);
                                                      [self layoutIfNeeded];
                                                  }
                                              }];
}

- (void)updateConstraints {
    if (!self.hasInstalledConstraints) {
        self.hasInstalledConstraints = YES;

        [self collectionView];
        [self placeholderView];
        [self field];
        NSDictionary *views   = NSDictionaryOfVariableBindings(_collectionView, _placeholderView, _field);
        NSDictionary *metrics = @{ @"top": @(self.safeArea.top),
                                   @"left": @(self.safeArea.left),
                                   @"bottom": @(self.safeArea.bottom),
                                   @"right": @(self.safeArea.right),
                                   @"width": @(self.preferredMinFieldWidth)
        };
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(top)-[_collectionView]-(bottom)-|"
                                                                     options:0
                                                                     metrics:metrics
                                                                       views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(top)-[_placeholderView]-(bottom)-|"
                                                                     options:0
                                                                     metrics:metrics
                                                                       views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(top)-[_field]-(bottom)-|"
                                                                     options:0
                                                                     metrics:metrics
                                                                       views:views]];

        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(left)-[_collectionView(==0)][_placeholderView(width@500)][_field(>=width@1000)]-(right)-|"
                                                                     options:0
                                                                     metrics:metrics
                                                                       views:views]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.field
                                                         attribute:NSLayoutAttributeLeft
                                                         relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                            toItem:self.collectionView
                                                         attribute:NSLayoutAttributeRight
                                                        multiplier:1
                                                          constant:10]];
        self.collectionViewWidthC  = [self constraintForAttribute:NSLayoutAttributeWidth firstItem:self.collectionView secondItem:nil];
        self.placeholderViewWidthC = [self constraintForAttribute:NSLayoutAttributeWidth firstItem:self.placeholderView secondItem:nil];
    }

    [super updateConstraints];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];

    UIColor *separatorColor = [UIColor colorWithWhite:0.8f alpha:1.0f];
    [separatorColor set];

    CGRect lineRect = CGRectMake(0.0f, CGRectGetHeight(rect) - 1, rect.size.width, 1);

    CGContextFillRect(UIGraphicsGetCurrentContext(), lineRect);
}

- (BOOL)isFirstResponder {
    return self.field.isFirstResponder;
}

- (BOOL)resignFirstResponder {
    return [self.field resignFirstResponder];
}

- (BOOL)becomeFirstResponder {
    [self willChangeValueForKey:@"active"];
    [self didChangeValueForKey:@"active"];
    return [self.field becomeFirstResponder];
}

#pragma mark - :. getters and setters

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flow = UICollectionViewFlowLayout.new;
        flow.minimumInteritemSpacing     = 10;
        flow.scrollDirection             = UICollectionViewScrollDirectionHorizontal;

        _collectionView                                           = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flow];
        _collectionView.allowsSelection                           = YES;
        _collectionView.showsHorizontalScrollIndicator            = YES;
        _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
        _collectionView.delegate                                  = self;
        _collectionView.dataSource                                = self;
        _collectionView.bounces                                   = NO;
        _collectionView.backgroundColor                           = UIColor.clearColor;

        [self addSubview:_collectionView];
    }

    return _collectionView;
}

- (UIView *)placeholderView {
    if (!_placeholderView) {
        _placeholderView                                           = UIView.new;
        _placeholderView.backgroundColor                           = UIColor.whiteColor;
        _placeholderView.translatesAutoresizingMaskIntoConstraints = NO;
        _placeholderView.clipsToBounds                             = YES;

        [self addSubview:_placeholderView];
    }

    return _placeholderView;
}

- (_KAITextField *)field {
    if (!_field) {
        _field                                           = _KAITextField.new;
        _field.translatesAutoresizingMaskIntoConstraints = NO;
        _field._kai_delegate                             = self;

        [self addSubview:_field];
    }

    return _field;
}

- (NSMutableArray<ZKTagItem *> *)tags {
    if (!_tags) {
        _tags = @[].mutableCopy;
    }

    return _tags;
}

- (void)setPlaceholder:(NSString *)placeholder {
    self.field.placeholder = placeholder;
}

- (NSString *)placeholder {
    return self.field.placeholder;
}

- (BOOL)active {
    return self.isFirstResponder;
}

- (void)setInputLeftImage:(UIImage *)inputLeftImage {
    _inputLeftImage = inputLeftImage;

    UIImageView *imageView                              = [[UIImageView alloc] initWithImage:inputLeftImage];
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.placeholderView addSubview:imageView];
    [self.placeholderView addConstraint:[NSLayoutConstraint constraintWithItem:imageView
                                                                     attribute:NSLayoutAttributeCenterX
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.placeholderView
                                                                     attribute:NSLayoutAttributeCenterX
                                                                    multiplier:1
                                                                      constant:0]];
    [self.placeholderView addConstraint:[NSLayoutConstraint constraintWithItem:imageView
                                                                     attribute:NSLayoutAttributeCenterY
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.placeholderView
                                                                     attribute:NSLayoutAttributeCenterY
                                                                    multiplier:1
                                                                      constant:0]];
}

@end
