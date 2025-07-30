//
//  ZKAuthContext.h
//  ZKFoundation
//
//  Created by Kaiser on 2019/3/13.
//

#import <LocalAuthentication/LocalAuthentication.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ZKAuthContextType) {
    /**
     *  当前设备不支持生物识别（TouchID/FaceID）
     */
    ZKAuthContextTypeNotSupport = 0,
    /**
     *  生物识别验证成功
     */
    ZKAuthContextTypeSuccess = 1,

    /**
     *  生物识别验证失败
     */
    ZKAuthContextTypeFail = 2,
    /**
     *  生物识别被用户手动取消
     */
    ZKAuthContextTypeUserCancel = 3,
    /**
     *  用户不使用生物识别,选择手动输入密码
     */
    ZKAuthContextTypeInputPassword = 4,
    /**
     *  生物识别被系统取消 (如遇到来电,锁屏,按了Home键等)
     */
    ZKAuthContextTypeSystemCancel = 5,
    /**
     *  生物识别无法启动,因为用户没有设置密码
     */
    ZKAuthContextTypePasswordNotSet = 6,
    /**
     *  生物识别无法启动,因为用户没有设置TouchID/FaceID
     */
    ZKAuthContextTypeBiometricNotSet = 7,
    /**
     *  生物识别不可用
     */
    ZKAuthContextTypeBiometricNotAvailable = 8,
    /**
     *  生物识别被锁定(连续多次验证失败,系统需要用户手动输入密码)
     */
    ZKAuthContextTypeBiometricLockout = 9,
    /**
     *  当前软件被挂起并取消了授权 (如App进入了后台等)
     */
    ZKAuthContextTypeAppCancel = 10,
    /**
     *  当前软件被挂起并取消了授权 (LAContext对象无效)
     */
    ZKAuthContextTypeInvalidContext = 11,
    /**
     *  系统版本不支持生物识别 (必须高于iOS 11.0才能使用)
     */
    ZKAuthContextTypeVersionNotSupport = 12,
    
    // 为了向后兼容保留的旧类型
    ZKAuthContextTypeTouchIDNotSet API_DEPRECATED("Use ZKAuthContextTypeBiometricNotSet instead", ios(8.0, 15.0)) = ZKAuthContextTypeBiometricNotSet,
    ZKAuthContextTypeTouchIDNotAvailable API_DEPRECATED("Use ZKAuthContextTypeBiometricNotAvailable instead", ios(8.0, 15.0)) = ZKAuthContextTypeBiometricNotAvailable,
    ZKAuthContextTypeTouchIDLockout API_DEPRECATED("Use ZKAuthContextTypeBiometricLockout instead", ios(8.0, 15.0)) = ZKAuthContextTypeBiometricLockout
};

API_AVAILABLE(ios(11.0))
@interface ZKAuthContext : LAContext

+ (instancetype)manager;

/*!
 *  @brief    硬件是否支持生物识别
 */
- (BOOL)canEvaluate;

/*!
 *  @brief    硬件是否支持生物识别（带错误信息）
 *  @param    error 错误信息
 */
- (BOOL)canEvaluateWithError:(NSError *__autoreleasing *)error;

/*!
 *  @brief    进行生物识别认证
 *  @param    desc 认证描述信息
 *  @param    fallbackTitle 回退选项标题（可选）
 *  @param    block 认证完成回调
 */
- (void)authWithDescribe:(NSString *)desc 
         fallbackTitle:(NSString * _Nullable)fallbackTitle
              callback:(void(^)(ZKAuthContextType type, NSError *_Nullable error))block;

/*!
 *  @brief    进行生物识别认证（简化版本，向后兼容）
 *  @param    desc 认证描述信息
 *  @param    block 认证完成回调
 */
- (void)authWithDescribe:(NSString *)desc callback:(void(^)(ZKAuthContextType type, NSError *_Nullable error))block;

/*!
 *  @brief    获取当前设备支持的生物识别类型
 *  @return   生物识别类型
 */
- (LABiometryType)biometryType;

/*!
 *  @brief    获取当前设备支持的生物识别类型描述
 *  @return   生物识别类型描述字符串
 */
- (NSString *)biometryTypeDescription;

@end

NS_ASSUME_NONNULL_END
