//
//  ZKVersion.h
//  ZKFoundation
//
//  Created by Kaiser on 2019/3/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 用于比较两个软件版本号。
 * 示例：
 *     "3.0" = "3.0"
 *     "3.0a2" = "3.0a2"
 *     "3.0" > "2.5"
 *     "3.1" > "3.0"
 *     "3.02" < "3.03"
 *     "3.0.2" < "3.0.3"
 *     "3.00" = "3.0"
 *     "3.02" > "3.0.3"
 *     "3.02" > "3.0.2"
 */
@interface ZKVersion : NSObject

#pragma mark - 属性

/** 主版本号 */
@property (nonatomic, readonly) NSUInteger major;

/** 次版本号 */
@property (nonatomic, readonly) NSUInteger minor;

/** 修订/热修复版本号 */
@property (nonatomic, readonly) NSUInteger maintenance;

/** 构建号 */
@property (nonatomic, readonly) NSUInteger build;

#pragma mark - 创建版本对象

/**
 * 使用主版本号、次版本号、修订号初始化。
 * @param major        主版本号
 * @param minor        次版本号
 * @param maintenance  修订/热修复版本号
 * @return 初始化后的 ZKVersion
 */
- (ZKVersion *)initWithMajor:(NSUInteger)major minor:(NSUInteger)minor maintenance:(NSUInteger)maintenance;

/**
 * 使用主版本号、次版本号、修订号、构建号初始化。
 * @param major        主版本号
 * @param minor        次版本号
 * @param maintenance  修订/热修复版本号
 * @param build        构建号
 * @return 初始化后的 ZKVersion
 */
- (ZKVersion *)initWithMajor:(NSUInteger)major minor:(NSUInteger)minor maintenance:(NSUInteger)maintenance build:(NSUInteger)build;

/**
 * 根据版本字符串创建并返回 ZKVersion 对象。
 * @param versionString 用于解析的版本字符串
 * @return 解析成功返回 ZKVersion，否则返回 nil
 */
+ (ZKVersion *)versionWithString:(NSString *)versionString;

/**
 * 返回当前 App 的 Bundle 版本信息对应的 ZKVersion。
 * @return 解析成功返回 ZKVersion，否则返回 nil
 */
+ (ZKVersion *)appBundleVersion;

/**
 * 从 Main Bundle 的 CFBundleShortVersionString、CFBundleVersion 获取当前应用版本并初始化。
 * @return 解析成功返回 ZKVersion，否则返回 nil
 */
+ (nullable ZKVersion *)currentAppVersion;

/**
 * 返回当前系统版本对应的 ZKVersion。
 * @return 解析成功返回 ZKVersion，否则返回 nil
 */
+ (ZKVersion *)osVersion;

#pragma mark - 版本比较

/**
 * 判断当前系统版本是否小于给定版本字符串。
 * @param versionString 用于比较的系统版本字符串
 * @return 若字符串合法且当前系统版本小于该版本则返回 YES
 */
+ (BOOL)osVersionIsLessThen:(NSString *)versionString;

/**
 * 判断当前系统版本是否大于给定版本字符串。
 * @param versionString 用于比较的系统版本字符串
 * @return 若字符串合法且当前系统版本大于该版本则返回 YES
 */
+ (BOOL)osVersionIsGreaterThen:(NSString *)versionString;

/**
 * 判断当前版本是否小于给定 ZKVersion。
 * @param version 用于比较的版本对象
 * @return 若给定版本小于当前版本则返回 YES
 */
- (BOOL)isLessThenVersion:(ZKVersion *)version;

/**
 * 判断当前版本是否大于给定 ZKVersion。
 * @param version 用于比较的版本对象
 * @return 若给定版本大于当前版本则返回 YES
 */
- (BOOL)isGreaterThenVersion:(ZKVersion *)version;

/**
 * 判断当前版本是否小于给定版本字符串。
 * @param versionString 用于比较的版本字符串
 * @return 若给定版本小于当前版本则返回 YES
 */
- (BOOL)isLessThenVersionString:(NSString *)versionString;

/**
 * 判断当前版本是否大于给定版本字符串。
 * @param versionString 用于比较的版本字符串
 * @return 若给定版本大于当前版本则返回 YES
 */
- (BOOL)isGreaterThenVersionString:(NSString *)versionString;

/**
 * 与给定 ZKVersion 比较是否相等。
 * @param version 用于比较的版本对象
 * @return 版本相等返回 YES
 */
- (BOOL)isEqualToVersion:(ZKVersion *)version;

/**
 * 与给定版本字符串比较是否相等。
 * @param versionString 用于比较的版本字符串
 * @return 版本相等返回 YES
 */
- (BOOL)isEqualToString:(NSString *)versionString;

/**
 * 与给定对象比较是否版本相等，支持 NSString 或 ZKVersion。
 * @param object NSString 或 ZKVersion 实例
 * @return 版本相等返回 YES
 */
- (BOOL)isEqual:(id)object;

/**
 * 与给定 ZKVersion 比较大小。
 * @param version 用于比较的版本对象
 * @return 比较结果（NSOrderedAscending / NSOrderedSame / NSOrderedDescending）
 */
- (NSComparisonResult)compare:(ZKVersion *)version;

@end

NS_ASSUME_NONNULL_END
