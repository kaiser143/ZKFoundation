//
//  ZKAuthContext.h
//  FBSnapshotTestCase
//
//  Created by Kaiser on 2019/3/13.
//

#import <LocalAuthentication/LocalAuthentication.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ZKAuthContextType) {
    /**
     *  当前设备不支持TouchID/FaceID
     */
    ZKAuthContextTypeNotSupport = 0,
    /**
     *  TouchID 验证成功
     */
    ZKAuthContextTypeSuccess = 1,

    /**
     *  TouchID 验证失败
     */
    ZKAuthContextTypeFail = 2,
    /**
     *  TouchID 被用户手动取消
     */
    ZKAuthContextTypeUserCancel = 3,
    /**
     *  用户不使用TouchID,选择手动输入密码
     */
    ZKAuthContextTypeInputPassword = 4,
    /**
     *  TouchID 被系统取消 (如遇到来电,锁屏,按了Home键等)
     */
    ZKAuthContextTypeSystemCancel = 5,
    /**
     *  TouchID 无法启动,因为用户没有设置密码
     */
    ZKAuthContextTypePasswordNotSet = 6,
    /**
     *  TouchID 无法启动,因为用户没有设置TouchID
     */
    ZKAuthContextTypeTouchIDNotSet = 7,
    /**
     *  TouchID 无效
     */
    ZKAuthContextTypeTouchIDNotAvailable = 8,
    /**
     *  TouchID 被锁定(连续多次验证TouchID失败,系统需要用户手动输入密码)
     */
    ZKAuthContextTypeTouchIDLockout = 9,
    /**
     *  当前软件被挂起并取消了授权 (如App进入了后台等)
     */
    ZKAuthContextTypeAppCancel = 10,
    /**
     *  当前软件被挂起并取消了授权 (LAContext对象无效)
     */
    ZKAuthContextTypeInvalidContext = 11,
    /**
     *  系统版本不支持TouchID (必须高于iOS 8.0才能使用)
     */
    ZKAuthContextTypeVersionNotSupport = 12
};

@interface ZKAuthContext : LAContext

+ (instancetype)manager;

/*!
 *  @brief    硬件是否支持
 */
- (BOOL)canEvaluate;


- (void)authWithDescribe:(NSString *)desc callback:(void(^)(ZKAuthContextType type, NSError *_Nullable error))block;

@end

NS_ASSUME_NONNULL_END
