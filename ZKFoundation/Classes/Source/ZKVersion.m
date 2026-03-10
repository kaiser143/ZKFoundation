//
//  ZKVersion.m
//  ZKFoundation
//
//  Created by Kaiser on 2019/3/11.
//

#import "ZKVersion.h"

@implementation ZKVersion

#pragma mark Creating Versions

- (ZKVersion *)initWithMajor:(NSUInteger)major minor:(NSUInteger)minor maintenance:(NSUInteger)maintenance build:(NSUInteger)build {
    self = [super init];
    if (self) {
        _major       = major;
        _minor       = minor;
        _maintenance = maintenance;
        _build       = build;
    }
    return self;
}

- (ZKVersion *)initWithMajor:(NSUInteger)major minor:(NSUInteger)minor maintenance:(NSUInteger)maintenance {
    return [self initWithMajor:major minor:minor maintenance:maintenance build:0];
}

+ (ZKVersion *)versionWithString:(NSString *)versionString {
    if (!versionString) {
        return nil;
    }

    NSInteger major       = 0;
    NSInteger minor       = 0;
    NSInteger maintenance = 0;
    NSInteger build       = 0;

    NSError *error;
    NSString *pattern = @"^(\\d+)(?:\\.(\\d+))?(?:\\.(\\d+))?(?:\\.(\\d+))?(?:$|\\s)";

    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];

    NSTextCheckingResult *match = [regex firstMatchInString:versionString
                                                    options:0
                                                      range:NSMakeRange(0, [versionString length])];

    if (!match) {
        return nil;
    }
    for (NSUInteger i = 1; i < match.numberOfRanges; i++) {
        NSRange range = [match rangeAtIndex:i];
        if (range.location == NSNotFound) {
            break;
        }
        NSUInteger value = [[versionString substringWithRange:range] integerValue];

        switch (i) {
            case 1:
                major = value;
                break;
            case 2:
                minor = value;
                break;
            case 3:
                maintenance = value;
                break;
            case 4:
                build = value;
                break;
            default:
                break;
        }
    }

    if (major >= 0 &&
        minor >= 0 &&
        maintenance >= 0 &&
        build >= 0) {
        return [[ZKVersion alloc] initWithMajor:major minor:minor maintenance:maintenance build:build];
    }

    return nil;
}

+ (ZKVersion *)appBundleVersion {
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *version  = info[ @"CFBundleVersion" ];

    return [ZKVersion versionWithString:version];
}

+ (ZKVersion *)currentAppVersion {
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = info[@"CFBundleShortVersionString"];
    NSString *appBuildVersion = info[@"CFBundleVersion"];
    if (!appVersion.length) {
        return nil;
    }
    NSString *versionString = appVersion;
    if (appBuildVersion.length > 0) {
        versionString = [NSString stringWithFormat:@"%@.%@", appVersion, appBuildVersion];
    }
    return [ZKVersion versionWithString:versionString];
}

+ (ZKVersion *)osVersion {
    static dispatch_once_t onceToken;
    static ZKVersion *version = nil;

    dispatch_once(&onceToken, ^{
#if TARGET_OS_IPHONE
        NSString *versionStr = [[UIDevice currentDevice] systemVersion];
        version              = [ZKVersion versionWithString:versionStr];
#else
        NSString *versionStr = [[NSProcessInfo processInfo] operatingSystemVersionString];
        versionStr           = [versionStr stringByReplacingOccurrencesOfString:@"Version" withString:@""];
        versionStr           = [versionStr stringByReplacingOccurrencesOfString:@"Build" withString:@""];
        versionStr           = [versionStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        version              = [ZKVersion versionWithString:versionStr];
#endif
    });

    return version;
}

#pragma mark Comparing Versions

+ (BOOL)osVersionIsLessThen:(NSString *)versionString {
    return [[ZKVersion osVersion] isLessThenVersionString:versionString];
}

+ (BOOL)osVersionIsGreaterThen:(NSString *)versionString {
    return [[ZKVersion osVersion] isGreaterThenVersionString:versionString];
}

- (BOOL)isLessThenVersion:(ZKVersion *)version {
    int result = [self compare:version] == NSOrderedAscending;
    //DDLogVerbose(@"%@ < %@? %d =  %@", self, version, result, result ? @"YES" : @"NO");
    return result;
}

- (BOOL)isGreaterThenVersion:(ZKVersion *)version {
    return [self compare:version] == NSOrderedDescending;
}

- (BOOL)isLessThenVersionString:(NSString *)versionString {
    return [self isLessThenVersion:[ZKVersion versionWithString:versionString]];
}

- (BOOL)isGreaterThenVersionString:(NSString *)versionString {
    return [self isGreaterThenVersion:[ZKVersion versionWithString:versionString]];
}

- (BOOL)isEqualToVersion:(ZKVersion *)version {
    return (self.major == version.major) && (self.minor == version.minor) && (self.maintenance == version.maintenance);
}

- (BOOL)isEqualToString:(NSString *)versionString {
    ZKVersion *versionToTest = [ZKVersion versionWithString:versionString];
    return [self isEqualToVersion:versionToTest];
}

- (NSUInteger)hash {
    NSUInteger hash = self.major;
    hash            = hash * 31u + self.minor;
    hash            = hash * 31u + self.maintenance;
    hash            = hash * 31u + self.build;
    return hash;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[ZKVersion class]]) {
        return [self isEqualToVersion:(ZKVersion *)object];
    }
    if ([object isKindOfClass:[NSString class]]) {
        return [self isEqualToString:(NSString *)object];
    }
    return NO;
}

- (NSComparisonResult)compare:(ZKVersion *)version {
    if (version == nil) {
        return NSOrderedDescending;
    }

    if (self.major < version.major) {
        return NSOrderedAscending;
    }
    if (self.major > version.major) {
        return NSOrderedDescending;
    }
    if (self.minor < version.minor) {
        return NSOrderedAscending;
    }
    if (self.minor > version.minor) {
        return NSOrderedDescending;
    }
    if (self.maintenance < version.maintenance) {
        return NSOrderedAscending;
    }
    if (self.maintenance > version.maintenance) {
        return NSOrderedDescending;
    }
    if (self.build < version.build) {
        return NSOrderedAscending;
    }
    if (self.build > version.build) {
        return NSOrderedDescending;
    }

    return NSOrderedSame;
}

- (NSString *)description {
    if (_build > 0) {
        return [NSString stringWithFormat:@"%d.%d.%d.%d", (int)_major, (int)_minor, (int)_maintenance, (int)_build];
    }
    if (_maintenance > 0) {
        return [NSString stringWithFormat:@"%d.%d.%d", (int)_major, (int)_minor, (int)_maintenance];
    }
    return [NSString stringWithFormat:@"%d.%d", (int)_major, (int)_minor];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    return [[ZKVersion allocWithZone:zone] initWithMajor:_major minor:_minor maintenance:_maintenance build:_build];
}

@end
