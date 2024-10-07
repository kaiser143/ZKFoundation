//
//  NSObject+ZKMultipleDelegates.m
//  ZKFoundation
//
//  Created by zhangkai on 2024/9/9.
//

#import "NSObject+ZKMultipleDelegates.h"
#import "ZKMultipleDelegates.h"
#import <ZKCategories/ZKCategories.h>

/**
 根据给定的 getter selector 获取对应的 setter selector
 @param getter 目标 getter selector
 @return 对应的 setter selector
 */
CG_INLINE SEL setterWithGetter(SEL getter) {
    NSString *getterString = NSStringFromSelector(getter);
    NSMutableString *setterString = [[NSMutableString alloc] initWithString:@"set"];
    [setterString appendString:getterString.kai_capitalizedString];
    [setterString appendString:@":"];
    SEL setter = NSSelectorFromString(setterString);
    return setter;
}

@interface NSObject ()

@property(nonatomic, strong) NSMutableDictionary<NSString *, ZKMultipleDelegates *> *kai_delegates;
@end

/// 以高级语言的方式描述一个 objc_property_t 的各种属性，请使用 `+descriptorWithProperty` 生成对象后直接读取对象的各种值。
@interface ZKPropertyDescriptor : NSObject

@property(nonatomic, strong) NSString *name;
@property(nonatomic, assign) SEL getter;
@property(nonatomic, assign) SEL setter;

@property(nonatomic, assign) BOOL isAtomic;
@property(nonatomic, assign) BOOL isNonatomic;

@property(nonatomic, assign) BOOL isAssign;
@property(nonatomic, assign) BOOL isWeak;
@property(nonatomic, assign) BOOL isStrong;
@property(nonatomic, assign) BOOL isCopy;

@property(nonatomic, assign) BOOL isReadonly;
@property(nonatomic, assign) BOOL isReadwrite;

@property(nonatomic, copy) NSString *type;

+ (instancetype)descriptorWithProperty:(objc_property_t)property;

@end

@implementation NSObject (ZKMultipleDelegates)

- (void)setKai_multipleDelegatesEnabled:(BOOL)kai_multipleDelegatesEnabled {
    [self setAssociateValue:@(kai_multipleDelegatesEnabled) withKey:@selector(kai_multipleDelegatesEnabled)];
    if (kai_multipleDelegatesEnabled) {
        if (!self.kai_delegates) {
            self.kai_delegates = [NSMutableDictionary dictionary];
        }
        [self kai_registerDelegateSelector:@selector(delegate)];
        if ([self isKindOfClass:[UITableView class]] || [self isKindOfClass:[UICollectionView class]]) {
            [self kai_registerDelegateSelector:@selector(dataSource)];
        }
    }
}

- (void)setKai_delegates:(NSMutableDictionary<NSString *,ZKMultipleDelegates *> *)kai_delegates {
    [self setAssociateValue:kai_delegates withKey:@selector(kai_delegates)];
}

- (NSMutableDictionary<NSString *,ZKMultipleDelegates *> *)kai_delegates {
    return [self associatedValueForKey:_cmd];
}

- (BOOL)kai_multipleDelegatesEnabled {
    return [self associatedValueForKey:_cmd];
}

- (void)kai_registerDelegateSelector:(SEL)getter {
    if (!self.kai_multipleDelegatesEnabled) {
        return;
    }
    
    Class targetClass = [self class];
    SEL originDelegateSetter = setterWithGetter(getter);
    SEL newDelegateSetter = [self newSetterWithGetter:getter];
    Method originMethod = class_getInstanceMethod(targetClass, originDelegateSetter);
    if (!originMethod) {
        return;
    }
    
    NSString *delegateGetterKey = NSStringFromSelector(getter);
    
    
    [ZKHelper executeBlock:^{
        IMP originIMP = method_getImplementation(originMethod);
        void (*originSelectorIMP)(id, SEL, id);
        originSelectorIMP = (void (*)(id, SEL, id))originIMP;
        
        BOOL isAddedMethod = class_addMethod(targetClass, newDelegateSetter, imp_implementationWithBlock(^(NSObject *selfObject, id aDelegate){
            
            // 这一段保护的原因请查看 https://github.com/Tencent/QMUI_iOS/issues/292
            if (!selfObject.kai_multipleDelegatesEnabled || selfObject.class != targetClass) {
                originSelectorIMP(selfObject, originDelegateSetter, aDelegate);
                return;
            }
            
            // 为这个 selector 创建一个 ZKMultipleDelegates 容器
            ZKMultipleDelegates *delegates = selfObject.kai_delegates[delegateGetterKey];
            if (!aDelegate) {
                // 对应 setDelegate:nil，表示清理所有的 delegate
                if (delegates) {
                    [delegates removeAllDelegates];
                    [selfObject.kai_delegates removeObjectForKey:delegateGetterKey];
                }
                // 必须要清空，否则遇到像 tableView:cellForRowAtIndexPath: 这种“要求返回值不能为 nil” 的场景就会中 assert
                // https://github.com/Tencent/QMUI_iOS/issues/1411
                originSelectorIMP(selfObject, originDelegateSetter, nil);
                return;
            }
            
            if (!delegates) {
                objc_property_t prop = class_getProperty(selfObject.class, delegateGetterKey.UTF8String);
                ZKPropertyDescriptor *property = [ZKPropertyDescriptor descriptorWithProperty:prop];
                if (property.isStrong) {
                    // strong property
                    delegates = [ZKMultipleDelegates strongDelegates];
                } else {
                    // weak property
                    delegates = [ZKMultipleDelegates weakDelegates];
                }
                delegates.parentObject = selfObject;
                selfObject.kai_delegates[delegateGetterKey] = delegates;
            }
            
            if (aDelegate != delegates) {// 过滤掉容器自身，避免把 delegates 传进去 delegates 里，导致死循环
                [delegates addDelegate:aDelegate];
            }
            
            originSelectorIMP(selfObject, originDelegateSetter, nil);// 先置为 nil 再设置 delegates，从而避免这个问题 https://github.com/Tencent/QMUI_iOS/issues/305
            originSelectorIMP(selfObject, originDelegateSetter, delegates);// 不管外面将什么 object 传给 setDelegate:，最终实际上传进去的都是 ZKMultipleDelegates 容器
            
        }), method_getTypeEncoding(originMethod));
        if (isAddedMethod) {
            Method newMethod = class_getInstanceMethod(targetClass, newDelegateSetter);
            method_exchangeImplementations(originMethod, newMethod);
        }
    } oncePerIdentifier:[NSString stringWithFormat:@"MultipleDelegates %@-%@", NSStringFromClass(targetClass), NSStringFromSelector(getter)]];
    
    // 如果原来已经有 delegate，则将其加到新建的容器里
    // @see https://github.com/Tencent/QMUI_iOS/issues/378
    BeginIgnorePerformSelectorLeaksWarning
    id originDelegate = [self performSelector:getter];
    if (originDelegate && originDelegate != self.kai_delegates[delegateGetterKey]) {
        [self performSelector:originDelegateSetter withObject:originDelegate];
    }
    EndIgnorePerformSelectorLeaksWarning
}

- (void)kai_removeDelegate:(id)delegate {
    if (!self.kai_delegates) {
        return;
    }
    NSMutableArray<NSString *> *delegateGetters = [[NSMutableArray alloc] init];
    [self.kai_delegates enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, ZKMultipleDelegates * _Nonnull obj, BOOL * _Nonnull stop) {
        BOOL removeSucceed = [obj removeDelegate:delegate];
        if (removeSucceed) {
            [delegateGetters addObject:key];
        }
    }];
    if (delegateGetters.count > 0) {
        for (NSString *getterString in delegateGetters) {
            [self refreshDelegateWithGetter:NSSelectorFromString(getterString)];
        }
    }
}

- (void)refreshDelegateWithGetter:(SEL)getter {
    SEL originSetterSEL = [self newSetterWithGetter:getter];
    BeginIgnorePerformSelectorLeaksWarning
    id originDelegate = [self performSelector:getter];
    [self performSelector:originSetterSEL withObject:nil];// 先置为 nil 再设置 delegates，从而避免这个问题 https://github.com/Tencent/QMUI_iOS/issues/305
    [self performSelector:originSetterSEL withObject:originDelegate];
    EndIgnorePerformSelectorLeaksWarning
}

// 根据 delegate property 的 getter，得到 ZKMultipleDelegates 为它的 setter 创建的新 setter 方法，最终交换原方法，因此利用这个方法返回的 SEL，可以调用到原来的 delegate property setter 的实现
- (SEL)newSetterWithGetter:(SEL)getter {
    return NSSelectorFromString([NSString stringWithFormat:@"kai_%@", NSStringFromSelector(setterWithGetter(getter))]);
}

@end


@implementation ZKPropertyDescriptor

+ (instancetype)descriptorWithProperty:(objc_property_t)property {
    ZKPropertyDescriptor *descriptor = [[self alloc] init];
    NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
    descriptor.name = propertyName;
    
    // getter
    char *getterChar = property_copyAttributeValue(property, "G");
    descriptor.getter = NSSelectorFromString(getterChar != NULL ? [NSString stringWithUTF8String:getterChar] : propertyName);
    if (getterChar != NULL) {
        free(getterChar);
    }
    
    // setter
    char *setterChar = property_copyAttributeValue(property, "S");
    NSString *setterString = setterChar != NULL ? [NSString stringWithUTF8String:setterChar] : NSStringFromSelector(setterWithGetter(NSSelectorFromString(propertyName)));
    descriptor.setter = NSSelectorFromString(setterString);
    if (setterChar != NULL) {
        free(setterChar);
    }
    
    // atomic/nonatomic
    char *attrValue_N = property_copyAttributeValue(property, "N");
    BOOL isAtomic = (attrValue_N == NULL);
    descriptor.isAtomic = isAtomic;
    descriptor.isNonatomic = !isAtomic;
    if (attrValue_N != NULL) {
        free(attrValue_N);
    }
    
    // assign/weak/strong/copy
    char *attrValue_isCopy = property_copyAttributeValue(property, "C");
    char *attrValue_isStrong = property_copyAttributeValue(property, "&");
    char *attrValue_isWeak = property_copyAttributeValue(property, "W");
    BOOL isCopy = attrValue_isCopy != NULL;
    BOOL isStrong = attrValue_isStrong != NULL;
    BOOL isWeak = attrValue_isWeak != NULL;
    if (attrValue_isCopy != NULL) {
        free(attrValue_isCopy);
    }
    if (attrValue_isStrong != NULL) {
        free(attrValue_isStrong);
    }
    if (attrValue_isWeak != NULL) {
        free(attrValue_isWeak);
    }
    descriptor.isCopy = isCopy;
    descriptor.isStrong = isStrong;
    descriptor.isWeak = isWeak;
    descriptor.isAssign = !isCopy && !isStrong && !isWeak;
    
    // readonly/readwrite
    char *attrValue_isReadonly = property_copyAttributeValue(property, "R");
    BOOL isReadonly = (attrValue_isReadonly != NULL);
    if (attrValue_isReadonly != NULL) {
        free(attrValue_isReadonly);
    }
    descriptor.isReadonly = isReadonly;
    descriptor.isReadwrite = !isReadonly;
    
    // type
    char *type = property_copyAttributeValue(property, "T");
    descriptor.type = [ZKPropertyDescriptor typeWithEncodeString:[NSString stringWithUTF8String:type]];
    if (type != NULL) {
        free(type);
    }
    
    return descriptor;
}

#define _DetectTypeAndReturn(_type) if (strncmp(@encode(_type), typeEncoding, strlen(@encode(_type))) == 0) return @#_type;

+ (NSString *)typeWithEncodeString:(NSString *)encodeString {
    if ([encodeString containsString:@"@\""]) {
        NSString *result = [encodeString substringWithRange:NSMakeRange(2, encodeString.length - 2 - 1)];
        if ([result containsString:@"<"] && [result containsString:@">"]) {
            // protocol
            if ([result hasPrefix:@"<"]) {
                // id pointer
                return [NSString stringWithFormat:@"id%@", result];
            }
        }
        // class
        return [NSString stringWithFormat:@"%@ *", result];
    }
    
    const char *typeEncoding = encodeString.UTF8String;
    _DetectTypeAndReturn(NSInteger)
    _DetectTypeAndReturn(NSUInteger)
    _DetectTypeAndReturn(int)
    _DetectTypeAndReturn(short)
    _DetectTypeAndReturn(long)
    _DetectTypeAndReturn(long long)
    _DetectTypeAndReturn(char)
    _DetectTypeAndReturn(unsigned char)
    _DetectTypeAndReturn(unsigned int)
    _DetectTypeAndReturn(unsigned short)
    _DetectTypeAndReturn(unsigned long)
    _DetectTypeAndReturn(unsigned long long)
    _DetectTypeAndReturn(CGFloat)
    _DetectTypeAndReturn(float)
    _DetectTypeAndReturn(double)
    _DetectTypeAndReturn(void)
    _DetectTypeAndReturn(char *)
    _DetectTypeAndReturn(id)
    _DetectTypeAndReturn(Class)
    _DetectTypeAndReturn(SEL)
    _DetectTypeAndReturn(BOOL)
    
    return encodeString;
}

@end
