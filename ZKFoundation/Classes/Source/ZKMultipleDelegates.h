//
//  ZKMultipleDelegates.h
//  ZKFoundation
//
//  Created by zhangkai on 2024/9/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 存放多个 delegate 指针的容器，必须搭配其他控件使用，一般不需要你自己 init。作用是让某个 class 支持同时存在多个 delegate。更多说明请查看 NSObject (ZKMultipleDelegates) 的注释。
@interface ZKMultipleDelegates : NSObject

+ (instancetype)weakDelegates;
+ (instancetype)strongDelegates;

@property(nonatomic, strong, readonly) NSPointerArray *delegates;
@property(nonatomic, weak) NSObject *parentObject;

- (void)addDelegate:(id)delegate;
- (BOOL)removeDelegate:(id)delegate;
- (void)removeAllDelegates;
- (BOOL)containsDelegate:(id)delegate;

@end

NS_ASSUME_NONNULL_END
