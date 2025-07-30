//
//  ZKAuthContext.m
//  ZKFoundation
//
//  Created by Kaiser on 2019/3/13.
//

#import "ZKAuthContext.h"
#import <pthread.h>

static inline void _kai_dispatch_async_on_main_queue(void (^block)(void)) {
    if (pthread_main_np()) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

@implementation ZKAuthContext

+ (instancetype)manager {
    static dispatch_once_t onceToken;
    static ZKAuthContext *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[ZKAuthContext alloc] init];
    });

    return instance;
}

- (BOOL)canEvaluate {
    NSError *error = nil;
    return [self canEvaluateWithError:&error];
}

- (BOOL)canEvaluateWithError:(NSError *__autoreleasing *)error {
    if (@available(iOS 11.0, *)) {
        // 优先使用更通用的生物识别策略
        return [self canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:error];
    } else {
        return NO;
    }
}

- (void)authWithDescribe:(NSString *)desc callback:(void(^)(ZKAuthContextType type, NSError *_Nullable error))block {
    [self authWithDescribe:desc fallbackTitle:nil callback:block];
}

- (void)authWithDescribe:(NSString *)desc 
         fallbackTitle:(NSString * _Nullable)fallbackTitle
              callback:(void(^)(ZKAuthContextType type, NSError *_Nullable error))block {
    if (!block) return;
    
    if (@available(iOS 11.0, *)) {
        NSError *error = nil;
        if ([self canEvaluateWithError:&error]) {
            if (fallbackTitle) {
                self.localizedFallbackTitle = fallbackTitle;
            }
            
            [self evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                 localizedReason:desc
                           reply:^(BOOL success, NSError *_Nullable error) {
                               ZKAuthContextType type = success ? ZKAuthContextTypeSuccess : [self translateTypeFrom:error.code];
                               _kai_dispatch_async_on_main_queue(^{
                                   block(type, error);
                               });
                           }];
        } else {
            _kai_dispatch_async_on_main_queue(^{
                block(ZKAuthContextTypeNotSupport, error);
            });
        }
    } else {
        _kai_dispatch_async_on_main_queue(^{
            block(ZKAuthContextTypeVersionNotSupport, nil);
        });
    }
}

- (ZKAuthContextType)translateTypeFrom:(LAError)error {
    ZKAuthContextType type = ZKAuthContextTypeFail;
    switch (error) {
        case LAErrorAuthenticationFailed:
            type = ZKAuthContextTypeFail;
            break;
        case LAErrorUserCancel:
            type = ZKAuthContextTypeUserCancel;
            break;
        case LAErrorUserFallback:
            type = ZKAuthContextTypeInputPassword;
            break;
        case LAErrorSystemCancel:
            type = ZKAuthContextTypeSystemCancel;
            break;
        case LAErrorPasscodeNotSet:
            type = ZKAuthContextTypePasswordNotSet;
            break;
        // 使用新的生物识别错误码（iOS 11.0+），它们与旧的TouchID错误码值相同
        case LAErrorBiometryNotEnrolled:  // 等同于 LAErrorTouchIDNotEnrolled
            type = ZKAuthContextTypeBiometricNotSet;
            break;
        case LAErrorBiometryNotAvailable:  // 等同于 LAErrorTouchIDNotAvailable  
            type = ZKAuthContextTypeBiometricNotAvailable;
            break;
        case LAErrorBiometryLockout:  // 等同于 LAErrorTouchIDLockout
            type = ZKAuthContextTypeBiometricLockout;
            break;
        case LAErrorAppCancel:
            type = ZKAuthContextTypeAppCancel;
            break;
        case LAErrorInvalidContext:
            type = ZKAuthContextTypeInvalidContext;
            break;

        default:
            break;
    }

    return type;
}

- (LABiometryType)biometryType API_AVAILABLE(ios(11.0)) {
    NSError *error = nil;
    [self canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
    return self.biometryType;
}

- (NSString *)biometryTypeDescription API_AVAILABLE(ios(11.0)) {
    switch (self.biometryType) {
        case LABiometryTypeFaceID:
            return @"Face ID";
        case LABiometryTypeTouchID:
            return @"Touch ID";
        case LABiometryTypeNone:
            return @"无生物识别";
        default:
            return @"未知类型";
    }
}

@end
