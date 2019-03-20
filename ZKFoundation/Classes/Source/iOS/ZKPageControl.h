//
//  ZKPageControl.h
//  FBSnapshotTestCase
//
//  Created by Kaiser on 2019/3/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZKPageControl : UIView

@property (nonatomic, copy) UIColor *tintColor;
@property (nonatomic, copy) UIColor *currentTintColor;

@property (nonatomic, assign) NSInteger numberOfPages;
@property (nonatomic, assign) NSInteger currentPage;

@end

NS_ASSUME_NONNULL_END
