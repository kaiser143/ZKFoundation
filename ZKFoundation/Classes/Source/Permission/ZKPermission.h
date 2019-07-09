//
//  ZKPermission.h
//  Pods
//
//  Created by Kaiser on 2019/7/8.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ZKPermissionType) {
    ZKPermissionTypePhoto = 0,
    ZKPermissionTypeCamera,
    ZKPermissionTypeMedia NS_ENUM_AVAILABLE_IOS(9_3),
    ZKPermissionTypeMicrophone,
    ZKPermissionTypeLocationAlways,
    ZKPermissionTypeLocationWhenInUse,
    ZKPermissionTypeBluetooth NS_ENUM_AVAILABLE_IOS(10),
    ZKPermissionTypePushNotification,
    ZKPermissionTypeSpeech NS_ENUM_AVAILABLE_IOS(10),
    ZKPermissionTypeEvent,
    ZKPermissionTypeContact NS_ENUM_AVAILABLE_IOS(9_0),
    ZKPermissionTypeReminder,
};

typedef NS_ENUM(NSUInteger, ZKPermissionAuthorizationStatus) {
    ZKPermissionAuthorizationStatusAuthorized = 0,
    ZKPermissionAuthorizationStatusDenied,
    ZKPermissionAuthorizationStatusNotDetermined,
    ZKPermissionAuthorizationStatusRestricted,
    ZKPermissionAuthorizationStatusLocationAlways,
    ZKPermissionAuthorizationStatusLocationWhenInUse,
    ZKPermissionAuthorizationStatusUnkonwn,
};

/*!
 *	@brief	各种权限请求
 */
@interface ZKPermission : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (id)copy NS_UNAVAILABLE;
- (id)mutableCopy NS_UNAVAILABLE;

+ (instancetype)manager;

- (void)requestWithType:(ZKPermissionType)type
               callback:(void(^)(BOOL response, ZKPermissionAuthorizationStatus status))callback;

@end

NS_ASSUME_NONNULL_END
