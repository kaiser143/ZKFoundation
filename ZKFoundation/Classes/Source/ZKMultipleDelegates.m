//
//  ZKMultipleDelegates.m
//  ZKFoundation
//
//  Created by zhangkai on 2024/9/9.
//

#import "ZKMultipleDelegates.h"
#import <objc/runtime.h>
#import <ZKCategories/ZKCategories.h>

@interface NSPointerArray (ZKFoundation)

- (NSUInteger)kai_indexOfPointer:(nullable void *)pointer;
- (BOOL)kai_containsPointer:(nullable void *)pointer;
@end

@implementation NSPointerArray (ZKFoundation)

- (NSUInteger)kai_indexOfPointer:(nullable void *)pointer {
    if (!pointer) {
        return NSNotFound;
    }
    
    NSPointerArray *array = [self copy];
    for (NSUInteger i = 0; i < array.count; i++) {
        if ([array pointerAtIndex:i] == ((void *)pointer)) {
            return i;
        }
    }
    return NSNotFound;
}

- (BOOL)kai_containsPointer:(void *)pointer {
    if (!pointer) {
        return NO;
    }
    if ([self kai_indexOfPointer:pointer] != NSNotFound) {
        return YES;
    }
    return NO;
}

@end

@interface NSObject (ZKFoundation)

/**
 检查给定的 key 是否可以用于当前对象的 valueForKey: 调用。
 
 @note 这是针对 valueForKey: 内部查找 key 的逻辑的精简版，去掉了一些不常用的，如果按精简版查找不到，会返回 NO（但按完整版可能是能查找到的），避免抛出异常。文档描述的查找方法完整版请查看 https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/KeyValueCoding/SearchImplementation.html
 */
- (BOOL)kai_canGetValueForKey:(NSString *)key;

/**
 检查给定的 key 是否可以用于当前对象的 setValue:forKey: 调用。
 
 @note 对于 setter 而言这就是完整版的检查流程，可核对文档 https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/KeyValueCoding/SearchImplementation.html
 */
- (BOOL)kai_canSetValueForKey:(NSString *)key;

@end

@implementation NSObject (ZKFoundation)

- (BOOL)kai_canGetValueForKey:(NSString *)key {
    NSArray<NSString *> *getters = @[
        [NSString stringWithFormat:@"get%@", key.kai_capitalizedString],   // get<Key>
        key,
        [NSString stringWithFormat:@"is%@", key.kai_capitalizedString],    // is<Key>
        [NSString stringWithFormat:@"_%@", key]                             // _<key>
    ];
    for (NSString *selectorString in getters) {
        if ([self respondsToSelector:NSSelectorFromString(selectorString)]) return YES;
    }
    
    if (![self.class accessInstanceVariablesDirectly]) return NO;
    
    return [self _kai_hasSpecifiedIvarWithKey:key];
}

- (BOOL)kai_canSetValueForKey:(NSString *)key {
    NSArray<NSString *> *setter = @[
        [NSString stringWithFormat:@"set%@:", key.kai_capitalizedString],   // set<Key>:
        [NSString stringWithFormat:@"_set%@", key.kai_capitalizedString]   // _set<Key>
    ];
    for (NSString *selectorString in setter) {
        if ([self respondsToSelector:NSSelectorFromString(selectorString)]) return YES;
    }
    
    if (![self.class accessInstanceVariablesDirectly]) return NO;
    
    return [self _kai_hasSpecifiedIvarWithKey:key];
}

- (BOOL)_kai_hasSpecifiedIvarWithKey:(NSString *)key {
    __block BOOL result = NO;
    NSArray<NSString *> *ivars = @[
        [NSString stringWithFormat:@"_%@", key],
        [NSString stringWithFormat:@"_is%@", key.kai_capitalizedString],
        key,
        [NSString stringWithFormat:@"is%@", key.kai_capitalizedString]
    ];
    [NSObject kai_enumrateIvarsOfClass:self.class includingInherited:YES usingBlock:^(Ivar  _Nonnull ivar, NSString * _Nonnull ivarDescription) {
        if (!result) {
            NSString *ivarName = [NSString stringWithFormat:@"%s", ivar_getName(ivar)];
            if ([ivars containsObject:ivarName]) {
                result = YES;
            }
        }
    }];
    return result;
}

@end


@interface ZKMultipleDelegates ()

@property(nonatomic, strong, readwrite) NSPointerArray *delegates;
@property(nonatomic, strong) NSInvocation *forwardingInvocation;
@property(nonatomic, assign) SEL inquiringSelector;
@end

@implementation ZKMultipleDelegates

+ (instancetype)weakDelegates {
    ZKMultipleDelegates *delegates = [[self alloc] init];
    delegates.delegates = [NSPointerArray weakObjectsPointerArray];
    return delegates;
}

+ (instancetype)strongDelegates {
    ZKMultipleDelegates *delegates = [[self alloc] init];
    delegates.delegates = [NSPointerArray strongObjectsPointerArray];
    return delegates;
}

- (void)resetClassNameIfNeeded {
    if ([self.parentObject isKindOfClass:CALayer.class] || [self.parentObject isKindOfClass:CAAnimation.class]) {
        // CALayer 和 CAAnimation 会缓存同一个 delegate class 的 respondsToSelector: 结果，但是在 multipleDelegates 的设计下，可能存在当前的 delegate 无法响应某个 selector，而后添加了可以响应的 delegate，系统这个缓存机制仍会认为无法响应，所以每次添加新的 delegate 都要设置与之前不同的 className
        // 这里设置一个 ZKMultipleDelegates 的 subClass，其 className 由所有 delegate className 拼接而成。
        NSMutableString *className = [NSMutableString stringWithString:NSStringFromClass(ZKMultipleDelegates.class)];
        [self.delegates.allObjects enumerateObjectsUsingBlock:^(id  _Nonnull delegate, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *delegateClassName = NSStringFromClass(object_getClass(delegate));
            [className appendFormat:@"_%@", delegateClassName];
        }];
        Class class = NSClassFromString(className);
        if (!class) {
            class = objc_allocateClassPair(ZKMultipleDelegates.class, className.UTF8String, 0);
            objc_registerClassPair(class);
        }
        object_setClass(self, class);
    }
}

- (void)addDelegate:(id)delegate {
    if (![self containsDelegate:delegate] && delegate != self) {
        [self.delegates addPointer:(__bridge void *)delegate];
        [self resetClassNameIfNeeded];
    }
}

- (BOOL)removeDelegate:(id)delegate {
    NSUInteger index = [self.delegates kai_indexOfPointer:(__bridge void *)delegate];
    if (index != NSNotFound) {
        [self.delegates removePointerAtIndex:index];
        return YES;
    }
    return NO;
}

- (void)removeAllDelegates {
    for (NSInteger i = self.delegates.count - 1; i >= 0; i--) {
        [self.delegates removePointerAtIndex:i];
    }
}

- (BOOL)containsDelegate:(id)delegate {
    return [self.delegates kai_containsPointer:(__bridge void *)delegate];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature *result = nil;
    NSPointerArray *delegates = [self.delegates copy];
    for (id delegate in delegates) {
        result = [delegate methodSignatureForSelector:aSelector];
        if (result && [delegate respondsToSelector:aSelector]) {
            return result;
        }
    }
    
    return NSMethodSignature.kai_avoidExceptionSignature;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    SEL selector = anInvocation.selector;
    
    // RAC 那边会把相同的 invocation 传回来 ZKMultipleDelegates，引发死循环，所以这里做了个屏蔽
    // https://github.com/Tencent/QMUI_iOS/issues/970
    if (self.forwardingInvocation.selector != NULL && self.forwardingInvocation.selector == selector) {
        NSUInteger returnLength = anInvocation.methodSignature.methodReturnLength;
        if (returnLength) {
            void *buffer = (void *)malloc(returnLength);
            [self.forwardingInvocation getReturnValue:buffer];
            [anInvocation setReturnValue:buffer];
            free(buffer);
        }
        return;
    }
    
    NSPointerArray *delegates = self.delegates.copy;
    for (id delegate in delegates) {
        if ([delegate respondsToSelector:selector]) {
            // 当前 delegate 的实现可能再次调用原始 delegate 的实现，如果原始 delegate 是 ZKMultipleDelegates 就会造成死循环，所以要做 2 事：
            // 1、检测到循环就打破
            // 2、但是检测到循环时，新生成的 anInvocation 默认没有 returnValue，需要用上一次循环之前的结果
            self.forwardingInvocation = anInvocation;
            [anInvocation invokeWithTarget:delegate];
        }
    }
    
    self.forwardingInvocation = nil;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    
    if (self.inquiringSelector == aSelector) {
        /**
         这个判断是为了避免类似 RACDelegateProxy 的处理导致的死循环：
         RACDelegateProxy 会做以下事情：
         1.保存之前的代理
         2.把对象代理修改为 RACDelegateProxy
         由于 ZKMultipleDelegates 会拦截操作 2，保持原始代理一直是 ZKMultipleDelegates 不被修改，同时把 RACDelegateProxy 添加到 delegates，而 RACDelegateProxy 操作 1 又保存了 ZKMultipleDelegates 实例，当对其调用 respondsToSelector 时，又会转发到 ZKMultipleDelegates 造成死循环，所以要做这个保护。
         */
        return NO;
    }
    
    if ([super respondsToSelector:aSelector]) {
        return YES;
    }
    
    NSPointerArray *delegates = [self.delegates copy];
    for (id delegate in delegates) {
        if (class_respondsToSelector(self.class, aSelector)) {
            return YES;
        }
        
        // 对 QMUIMultipleDelegates 额外处理的解释在这里：https://github.com/Tencent/QMUI_iOS/issues/357
        BOOL delegateCanRespondToSelector;
        if ([delegate isProxy] || [delegate isKindOfClass:ZKMultipleDelegates.class]) {
            self.inquiringSelector = aSelector;
            delegateCanRespondToSelector = [delegate respondsToSelector:aSelector];
            self.inquiringSelector = NULL;
        } else {
            delegateCanRespondToSelector = class_respondsToSelector(object_getClass(delegate), aSelector);
        }
        if (delegateCanRespondToSelector) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - Overrides

- (BOOL)isProxy {
    return YES;
}

- (BOOL)isKindOfClass:(Class)aClass {
    BOOL result = [super isKindOfClass:aClass];
    if (result) return YES;
    
    NSPointerArray *delegates = [self.delegates copy];
    for (id delegate in delegates) {
        if ([delegate isKindOfClass:aClass]) return YES;
    }
    
    return NO;
}

- (BOOL)isMemberOfClass:(Class)aClass {
    BOOL result = [super isMemberOfClass:aClass];
    if (result) return YES;
    
    NSPointerArray *delegates = [self.delegates copy];
    for (id delegate in delegates) {
        if ([delegate isMemberOfClass:aClass]) return YES;
    }
    
    return NO;
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol {
    BOOL result = [super conformsToProtocol:aProtocol];
    if (result) return YES;
    
    NSPointerArray *delegates = [self.delegates copy];
    for (id delegate in delegates) {
        if ([delegate conformsToProtocol:aProtocol]) return YES;
    }
    
    return NO;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@, parentObject is %@, %@", [super description], self.parentObject, self.delegates];
}

- (id)valueForKey:(NSString *)key {
    NSPointerArray *delegates = [self.delegates copy];
    for (id delegate in delegates) {
        if ([delegate kai_canGetValueForKey:key]) {
            return [delegate valueForKey:key];
        }
    }
    return [super valueForKey:key];
}

- (void)setValue:(id)value forKey:(NSString *)key {
    NSPointerArray *delegates = [self.delegates copy];
    for (id delegate in delegates) {
        if ([delegate kai_canSetValueForKey:key]) {
            [delegate setValue:value forKey:key];
        }
    }
}

@end
