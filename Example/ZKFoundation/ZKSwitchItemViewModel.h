//
//  ZKSwitchItemViewModel.h
//  ZKFoundation_Example
//
//  Created by zhangkai on 2021/7/28.
//  Copyright © 2021 zhangkai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZKSwitchItemViewModel : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) BOOL on;

+ (instancetype)itemWithTitle:(NSString *)title on:(BOOL)on;

@end

NS_ASSUME_NONNULL_END
