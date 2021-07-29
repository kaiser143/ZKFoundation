//
//  ZKSwitchItemViewModel.m
//  ZKFoundation_Example
//
//  Created by zhangkai on 2021/7/28.
//  Copyright © 2021 zhangkai. All rights reserved.
//

#import "ZKSwitchItemViewModel.h"

@implementation ZKSwitchItemViewModel

+ (instancetype)itemWithTitle:(NSString *)title on:(BOOL)on {
    return [[self alloc] initWithTitle:title on:on];
}

- (instancetype)initWithTitle:(NSString *)title on:(BOOL)on {
    self = [super init];
    if (self == nil) return nil;
    
    self.title = title;
    self.on = on;
    
    return self;
}

@end
