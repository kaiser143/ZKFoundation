//
//  ZKPermission.h
//  ZKFoundation
//
//  Created by Kaiser on 2019/7/8.
//
//
//  使用说明：
//  本类会自动检测项目中是否引入了对应的框架，只编译已引入框架的权限代码
//  这样可以避免 App Store 审核时因未使用的权限被拒
//
//  工作原理：
//  - 使用 __has_include() 自动检测框架是否可用
//  - 如果项目中没有链接某个框架，对应的权限代码不会被编译
//  - Apple 的静态分析工具检测不到未引入的 API，就不会要求添加权限说明
//
//  如何移除不需要的权限：
//  在 Target > Build Phases > Link Binary With Libraries 中移除不需要的框架即可
//  例如：移除 CoreLocation.framework 就不会编译定位权限相关代码
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 自动检测框架是否可用，只编译已引入框架的权限代码
#if __has_include(<Photos/Photos.h>)
#define ZK_PERMISSION_PHOTO 1
#else
#define ZK_PERMISSION_PHOTO 0
#endif

#if __has_include(<AVFoundation/AVFoundation.h>)
#define ZK_PERMISSION_CAMERA 1
#define ZK_PERMISSION_MICROPHONE 1
#else
#define ZK_PERMISSION_CAMERA 0
#define ZK_PERMISSION_MICROPHONE 0
#endif

#if __has_include(<MediaPlayer/MediaPlayer.h>)
#define ZK_PERMISSION_MEDIA 1
#else
#define ZK_PERMISSION_MEDIA 0
#endif

#if __has_include(<CoreLocation/CoreLocation.h>)
#define ZK_PERMISSION_LOCATION 1
#else
#define ZK_PERMISSION_LOCATION 0
#endif

#if __has_include(<CoreBluetooth/CoreBluetooth.h>)
#define ZK_PERMISSION_BLUETOOTH 1
#else
#define ZK_PERMISSION_BLUETOOTH 0
#endif

#if __has_include(<UserNotifications/UserNotifications.h>)
#define ZK_PERMISSION_NOTIFICATION 1
#else
#define ZK_PERMISSION_NOTIFICATION 0
#endif

#if __has_include(<Speech/Speech.h>)
#define ZK_PERMISSION_SPEECH 1
#else
#define ZK_PERMISSION_SPEECH 0
#endif

#if __has_include(<EventKit/EventKit.h>)
#define ZK_PERMISSION_EVENT 1
#define ZK_PERMISSION_REMINDER 1
#else
#define ZK_PERMISSION_EVENT 0
#define ZK_PERMISSION_REMINDER 0
#endif

#if __has_include(<Contacts/Contacts.h>)
#define ZK_PERMISSION_CONTACT 1
#else
#define ZK_PERMISSION_CONTACT 0
#endif

typedef NS_ENUM(NSUInteger, ZKPermissionType) {
#if ZK_PERMISSION_PHOTO
    ZKPermissionTypePhoto = 0,
#endif
#if ZK_PERMISSION_CAMERA
    ZKPermissionTypeCamera,
#endif
#if ZK_PERMISSION_MEDIA
    ZKPermissionTypeMedia NS_ENUM_AVAILABLE_IOS(9_3),
#endif
#if ZK_PERMISSION_MICROPHONE
    ZKPermissionTypeMicrophone,
#endif
#if ZK_PERMISSION_LOCATION
    ZKPermissionTypeLocationAlways,
    ZKPermissionTypeLocationWhenInUse,
#endif
#if ZK_PERMISSION_BLUETOOTH
    ZKPermissionTypeBluetooth NS_ENUM_AVAILABLE_IOS(10),
#endif
#if ZK_PERMISSION_NOTIFICATION
    ZKPermissionTypePushNotification,
#endif
#if ZK_PERMISSION_SPEECH
    ZKPermissionTypeSpeech NS_ENUM_AVAILABLE_IOS(10),
#endif
#if ZK_PERMISSION_EVENT
    ZKPermissionTypeEvent,
#endif
#if ZK_PERMISSION_CONTACT
    ZKPermissionTypeContact NS_ENUM_AVAILABLE_IOS(9_0),
#endif
#if ZK_PERMISSION_REMINDER
    ZKPermissionTypeReminder,
#endif
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
