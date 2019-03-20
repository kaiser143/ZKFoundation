//
//  ZKVersion.h
//  FBSnapshotTestCase
//
//  Created by Kaiser on 2019/3/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZKVersion : NSObject

/**-------------------------------------------------------------------------------------
 @name Properties
 ---------------------------------------------------------------------------------------
 */

/**
 The major version number
 */
@property (nonatomic, readonly) NSUInteger major;

/**
 The minor version number
 */
@property (nonatomic, readonly) NSUInteger minor;


/**
 The maintenance/hotfix version number
 */
@property (nonatomic, readonly) NSUInteger maintenance;

/**
 The build number
 */
@property (nonatomic, readonly) NSUInteger build;

/**-------------------------------------------------------------------------------------
 @name Creating Versions
 ---------------------------------------------------------------------------------------
 */

/**
 Initializes the receiver with major, minor and maintenance version.
 @param major The major version number
 @param minor The minor version number
 @param maintenance The maintainance/hotfix version number
 @returns The initialized `ZKVersion`
 */
- (ZKVersion *)initWithMajor:(NSUInteger)major minor:(NSUInteger)minor maintenance:(NSUInteger)maintenance;

/**
 Initializes the receiver with major, minor and maintenance version.
 @param major The major version number
 @param minor The minor version number
 @param maintenance The maintainance/hotfix version number
 @param build The build number
 @returns The initialized `ZKVersion`
 */
- (ZKVersion *)initWithMajor:(NSUInteger)major minor:(NSUInteger)minor maintenance:(NSUInteger)maintenance build:(NSUInteger)build;

/**
 creates and returns a ZKVersion object initialized using the provided string
 @param versionString The `NSString` to create a `ZKVersion` from
 @returns A ZKVersion object or <code>nil</code> if the string is not a valid version number
 */
+ (ZKVersion *)versionWithString:(NSString *)versionString;

/**
 creates and retuns a ZKVersion object initialized with the version information of the current application
 @returns A ZKVersion object or <code>nil</code> if the string of the current application is not a valid version number
 */
+ (ZKVersion *)appBundleVersion;

/**
 creates and retuns a ZKVersion object initialized with the version information of the operating system
 @returns A ZKVersion object or <code>nil</code> if the string of the current application is not a valid version number
 */
+ (ZKVersion *)osVersion;

/**-------------------------------------------------------------------------------------
 @name Comparing Versions
 ---------------------------------------------------------------------------------------
 */

/**
 @param versionString The OS version as `NSString` to compare the receiver to
 @returns <code>true</code> if the given version string is valid and less then the osVersion
 */
+ (BOOL)osVersionIsLessThen:(NSString *)versionString;

/**
 @param versionString The OS version as `NSString` to compare the receiver to
 @returns <code>true</code> if the given version string is valid and greater then the osVersion
 */
+ (BOOL)osVersionIsGreaterThen:(NSString *)versionString;

/**
 @param version The `ZKVersion` to compare the receiver to
 @returns <code>true</code> if the give version is less then this version
 */
- (BOOL)isLessThenVersion:(ZKVersion *)version;

/**
 @param version The `ZKVersion` to compare the receiver to
 @returns <code>true</code> if the give version is greater then this version
 */
- (BOOL)isGreaterThenVersion:(ZKVersion *)version;

/**
 @param versionString The version as `NSString` to compare the receiver to
 @returns <code>true</code> if the give version is less then this version string
 */
- (BOOL)isLessThenVersionString:(NSString *)versionString;

/**
 @param versionString The version as `NSString` to compare the receiver to
 * @returns <code>true</code> if the give version is greater then version string
 */
- (BOOL)isGreaterThenVersionString:(NSString *)versionString;

/**
 Compares the receiver against a passed `ZKVersion` instance
 @param version The `ZKVersion` to compare the receiver to
 @returns `YES` is the versions are equal
 */
- (BOOL)isEqualToVersion:(ZKVersion *)version;

/**
 Compares the receiver against a passed version as `NSString`
 @param versionString The version as `NSString` to compare the receiver to
 @returns `YES` is the versions are equal
 */
- (BOOL)isEqualToString:(NSString *)versionString;

/**
 Compares the receiver against a passed object
 @param object An object of either `NSString` or `ZKVersion`
 @returns `YES` is the versions are equal
 */
- (BOOL)isEqual:(id)object;

/**
 Compares the receiver against a passed `ZKVersion` instance
 @param version The `ZKVersion` to compare the receiver to
 @returns The comparison result
 */
- (NSComparisonResult)compare:(ZKVersion *)version;

@end

NS_ASSUME_NONNULL_END
