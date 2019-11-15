//
//  ZKNavigationControllerDelegateProxy.m
//  ZKFoundation
//
//  Created by zhangkai on 2019/11/14.
//

#import "ZKNavigationControllerDelegateProxy.h"

static BOOL KAIInterceptedSelector(SEL sel) {
    return (
        sel == @selector(navigationController:willShowViewController:animated:) ||
        sel == @selector(navigationController:didShowViewController:animated:));
}

@implementation ZKNavigationControllerDelegateProxy {
    __weak id _navigationTarget;
    __weak ZKNavigationController *_interceptor;
}

- (instancetype)initWithNavigationTarget:(nullable id<UINavigationControllerDelegate>)navigationTarget
                             interceptor:(ZKNavigationController *)interceptor {
    NSParameterAssert(interceptor != nil);
    if (self) {
        _navigationTarget = navigationTarget;
        _interceptor      = interceptor;
    }

    return self;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return KAIInterceptedSelector(aSelector) || [_navigationTarget respondsToSelector:aSelector];
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    return KAIInterceptedSelector(aSelector) ? _interceptor : _navigationTarget;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    void *nullPointer = NULL;
    [invocation setReturnValue:&nullPointer];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    return [NSObject instanceMethodSignatureForSelector:@selector(init)];
}

@end
