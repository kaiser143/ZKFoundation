//
//  ZKCollectionViewCell.m
//  ZKFoundation_Example
//
//  Created by zhangkai on 2019/12/3.
//  Copyright © 2019 zhangkai. All rights reserved.
//

#import "ZKCollectionViewCell.h"
#import <ZKCategories/ZKCategories.h>

@implementation ZKCollectionViewCell

- (void)bindViewModel:(__kindof NSObject *)viewModel forItemAtIndexPath:(NSIndexPath *)indexPath {
    self.contentView.backgroundColor = UIColor.randomColor;
}

@end
