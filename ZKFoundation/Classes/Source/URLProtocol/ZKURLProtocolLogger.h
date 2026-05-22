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
    ZKHTTPRequestLoggerLevelError,             // 仅打印 HTTP 状态码不为 200 或发生网络错误的请求（按 HTTP status 判断，不含业务 code）
};

typedef NS_ENUM(NSUInteger, ZKNetworkLoggerPhase) {
    ZKNetworkLoggerPhaseRequest,               // 请求发出
    ZKNetworkLoggerPhaseResponse,              // 收到响应
};

@protocol ZKNetworkLoggerProtocol <NSObject>
@property (nonatomic, strong) NSPredicate *filter;

@optional
/// 与控制台 NSLog 输出内容一致的网络日志回调
- (void)logger:(id<ZKNetworkLoggerProtocol>)logger
didOutputNetworkLog:(NSString *)message
     forRequest:(NSURLRequest *)request
          phase:(ZKNetworkLoggerPhase)phase;
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

    - (void)logger:(id<ZKNetworkLoggerProtocol>)logger
didOutputNetworkLog:(NSString *)message
     forRequest:(NSURLRequest *)request
          phase:(ZKNetworkLoggerPhase)phase {
        // 自定义展示，例如写入文件
    }
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
