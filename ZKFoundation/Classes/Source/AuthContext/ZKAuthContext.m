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
        instance = ZKAuthContext.new;
    });

    return instance;
}

- (BOOL)canEvaluate {
    return [self canEvaluate:nil];
}

- (BOOL)canEvaluate:(NSError *__autoreleasing *)error {
    return [self canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:error];
}

- (void)authWithDescribe:(NSString *)desc callback:(void (^)(ZKAuthContextType, NSError *_Nullable))block {
    if (!block) return;

    if (@available(iOS 8.0, *)) {
        NSError *error = nil;
        if ([self canEvaluate:&error]) {
            __weak __typeof(self) weakSelf = self;
            [self evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                 localizedReason:desc
                           reply:^(BOOL success, NSError *_Nullable error) {
                               __strong __typeof(weakSelf) strongSelf = weakSelf;
                               ZKAuthContextType type                 = success ? ZKAuthContextTypeSuccess : [strongSelf translateTypeFrom:error.code];
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
            block(ZKAuthContextTypeNotSupport, nil);
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
        case LAErrorTouchIDNotEnrolled:
            type = ZKAuthContextTypeTouchIDNotSet;
            break;
        case LAErrorTouchIDNotAvailable:
            type = ZKAuthContextTypeTouchIDNotAvailable;
            break;
        case LAErrorTouchIDLockout:
            type = ZKAuthContextTypeTouchIDLockout;
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

@end
