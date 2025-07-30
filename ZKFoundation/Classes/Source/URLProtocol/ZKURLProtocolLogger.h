//
//  ZKURLProtocolLogger.h
//  ZKFoundation
//
//  Created by Kaiser on 2018/8/24.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ZKHTTPRequestLoggerLevel) {
    ZKHTTPRequestLoggerLevelVerbose,           // 打印全部信息
    ZKHTTPRequestLoggerLevelInfo,              // 打印简短信息
};

@protocol ZKNetworkLoggerProtocol <NSObject>
@property (nonatomic, strong) NSPredicate *filter;
@end

@interface ZKURLProtocolLogger : NSURLProtocol

/// 开始打印网络请求和返回的数据
+ (void)startLogging;

/// 停止打印
+ (void)stopLogging;

+ (void)setLogLevel:(ZKHTTPRequestLoggerLevel)level;

/*!
 *  @brief    添加自定义网络日志记录器
 *  @code
    @interface ZKNetworkConsoleLogger : NSObject <ZKNetworkLoggerProtocol> @end

    @implementation ZKNetworkConsoleLogger
    @synthesize filter = _filter;
    @end
 
    ZKNetworkConsoleLogger<ZKNetworkLoggerProtocol> *testLogger = [ZKNetworkConsoleLogger new];
    NSPredicate *filter = [NSPredicate predicateWithBlock:^BOOL(NSURLRequest *request, NSDictionary<NSString *,id> * _Nullable bindings) {
        return !([request.URL.absoluteString containsString:@"httpbin.org"]);
    }];
    testLogger.filter = filter;
 
    [ZKURLProtocolLogger addLogger:testLogger];
    [ZKURLProtocolLogger startLogging];
 *  @endcode
 */
+ (void)addLogger:(id<ZKNetworkLoggerProtocol>)logger;

+ (void)removeLogger:(id<ZKNetworkLoggerProtocol>)logger;

@end
