//
//  ZKNavigationControllerDelegateProxy.h
//  ZKFoundation
//
//  Created by zhangkai on 2019/11/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class ZKNavigationController;
@protocol UINavigationControllerDelegate;

@interface ZKNavigationControllerDelegateProxy : NSProxy

- (instancetype)initWithNavigationTarget:(nullable id<UINavigationControllerDelegate>)navigationTarget
                             interceptor:(ZKNavigationController *)interceptor;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
