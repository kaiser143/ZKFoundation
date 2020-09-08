//
//  ZKURLProtocol.m
//  ZKFoundation
//
//  Created by Kaiser on 2018/8/24.
//

#import "ZKURLProtocol.h"
#import "ZKSessionConfiguration.h"
#import <ZKCategories/ZKCategories.h>

@interface __KAILogger : NSObject
@property (nonatomic, strong) NSMutableSet *mutableLoggers;
@end

@implementation __KAILogger

+ (void)load {
    [self manager];
}

+ (instancetype)manager {
    static dispatch_once_t onceToken;
    static __KAILogger *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (NSMutableSet *)mutableLoggers {
    if (!_mutableLoggers) {
        _mutableLoggers = NSMutableSet.new;
    }
    return _mutableLoggers;
}

@end

@interface NSObject (__KAIURL)

- (id)KAI_defaultValue:(id)defaultData;

@end

@interface NSMutableString (__KAIURL)
- (void)appendURLRequest:(NSURLRequest *)request;
@end

// 为了避免canInitWithRequest和canonicalRequestForRequest的死循环
static NSString *const kProtocolHandledKey = @"kProtocolHandledKey";
static void * kNetworkRequestStartDate = &kNetworkRequestStartDate;

@interface ZKURLProtocolLogger () <NSURLConnectionDelegate, NSURLConnectionDataDelegate, NSURLSessionDelegate>

@property (nonatomic, strong) NSURLSessionDataTask *dataTask;
@property (nonatomic, strong) NSOperationQueue *sessionDelegateQueue;
@property (nonatomic, strong) NSURLResponse *response;

@end

@implementation ZKURLProtocolLogger

#pragma mark - Public

/// 开始监听
+ (void)startLogging {
    ZKSessionConfiguration *sessionConfiguration = [ZKSessionConfiguration defaultConfiguration];
    [NSURLProtocol registerClass:[ZKURLProtocolLogger class]];
    if (![sessionConfiguration isSwizzle]) {
        [sessionConfiguration load];
    }
}

/// 停止监听
+ (void)stopLogging {
    ZKSessionConfiguration *sessionConfiguration = [ZKSessionConfiguration defaultConfiguration];
    [NSURLProtocol unregisterClass:[ZKURLProtocolLogger class]];
    if ([sessionConfiguration isSwizzle]) {
        [sessionConfiguration unload];
        [[__KAILogger manager].mutableLoggers removeAllObjects];
    }
}

#pragma mark - Override

/**
 需要控制的请求
 
 @param request 此次请求
 @return 是否需要监控
 */
+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    // 如果是已经拦截过的就放行，避免出现死循环
    if ([NSURLProtocol propertyForKey:kProtocolHandledKey inRequest:request]) {
        return NO;
    }

    // 不是网络请求，不处理
    if (![request.URL.scheme isEqualToString:@"http"] &&
        ![request.URL.scheme isEqualToString:@"https"]) {
        return NO;
    }

    // 指定拦截网络请求
    for (id<ZKNetworkLoggerProtocol> logger in [__KAILogger manager].mutableLoggers) {
        if (request && logger.filter && [logger.filter evaluateWithObject:request]) {
            // 拦截
            return YES;
        }
    }
    return NO;
}

/**
 设置我们自己的自定义请求
 可以在这里统一加上头之类的
 
 @param request 应用的此次请求
 @return 我们自定义的请求
 */
+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    NSMutableURLRequest *mutableReqeust = [request mutableCopy];
    // 设置已处理标志
    [NSURLProtocol setProperty:@(YES)
                        forKey:kProtocolHandledKey
                     inRequest:mutableReqeust];
    return [mutableReqeust copy];
}

+ (void)addLogger:(id<ZKNetworkLoggerProtocol>)logger {
    [[__KAILogger manager].mutableLoggers addObject:logger];
}

+ (void)removeLogger:(id<ZKNetworkLoggerProtocol>)logger {
    [[__KAILogger manager].mutableLoggers removeObject:logger];
}

// 重新父类的开始加载方法
- (void)startLoading {
#ifdef DEBUG
    NSMutableString *strings = [NSMutableString stringWithString:@"\n\n********************************************************\nRequest Start\n********************************************************\n\n"];
    [strings appendFormat:@"Method:\t\t\t%@\n", self.request.HTTPMethod];
    [strings appendURLRequest:self.request];
    [strings appendFormat:@"\n\n********************************************************\nRequest End\n********************************************************\n\n\n\n"];
    NSLog(@"%@", strings);
#endif

    NSURLSessionConfiguration *configuration =
        [NSURLSessionConfiguration defaultSessionConfiguration];

    self.sessionDelegateQueue                             = [[NSOperationQueue alloc] init];
    self.sessionDelegateQueue.maxConcurrentOperationCount = 1;
    self.sessionDelegateQueue.name                        = @"com.kai.session.queue";

    NSURLSession *session =
        [NSURLSession sessionWithConfiguration:configuration
                                      delegate:self
                                 delegateQueue:self.sessionDelegateQueue];

    self.dataTask = [session dataTaskWithRequest:self.request];
    [self.dataTask setAssociateValue:NSDate.date withKey:kNetworkRequestStartDate];
    [self.dataTask resume];
}

// 结束加载
- (void)stopLoading {
    [self.dataTask cancel];
}

#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (!error) {
        [self.client URLProtocolDidFinishLoading:self];
    } else if ([error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorCancelled) {
    } else {
        [self.client URLProtocol:self didFailWithError:error];
    }
    self.dataTask = nil;
}

#pragma mark - NSURLSessionDataDelegate

// 当服务端返回信息时，这个回调函数会被ULS调用，在这里实现http返回信息的截
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    // 返回给URL Loading System接收到的数据，这个很重要，不然光截取不返回，就瞎了。
    [self.client URLProtocol:self didLoadData:data];
    
#ifdef DEBUG
    NSTimeInterval elapsedTime = [[NSDate date] timeIntervalSinceDate:[self.dataTask associatedValueForKey:kNetworkRequestStartDate]];
    NSMutableString *strings = [NSMutableString stringWithString:@"\n\n=========================================\nAPI Response\n=========================================\n\n"];
    NSHTTPURLResponse *response;
    NSString *content = nil;
    NSDictionary *obj = nil;
    if ([self.response isKindOfClass:NSHTTPURLResponse.class]) response = (NSHTTPURLResponse *)self.response;
    if (data) content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (content) obj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:NULL];
    
    [strings appendFormat:@"Status:\t%ld\t(%@) [%.04f s]\n\n", (long)response.statusCode, [NSHTTPURLResponse localizedStringForStatusCode:response.statusCode], elapsedTime];
    [strings appendFormat:@"Request URL:\n\t%@\n\n", self.request.URL];
    if ([obj isKindOfClass:NSDictionary.class]) {
        [strings appendFormat:@"Raw Response String:\n\t%@\n\n", [obj jsonPrettyStringEncoded]];
    } else if (obj) {
        [strings appendFormat:@"Raw Response String:\n\t%@\n\n", obj];
    } else {
        [strings appendFormat:@"Raw Response String:\n\t%@\n\n", content];
    }

    [strings appendFormat:@"Raw Response Header:\n\t%@\n\n", response.allHeaderFields];
    
    if (dataTask.error) {
        NSError *error = dataTask.error;
        [strings appendFormat:@"Error Domain:\t\t\t\t\t\t\t%@\n", error.domain];
        [strings appendFormat:@"Error Domain Code:\t\t\t\t\t\t%ld\n", (long)error.code];
        [strings appendFormat:@"Error Localized Description:\t\t\t%@\n", error.localizedDescription];
        [strings appendFormat:@"Error Localized Failure Reason:\t\t\t%@\n", error.localizedFailureReason];
        [strings appendFormat:@"Error Localized Recovery Suggestion:\t%@\n\n", error.localizedRecoverySuggestion];
    }

    [strings appendString:@"\n---------------  Related Request Content  --------------\n"];
    [strings appendURLRequest:self.request];
    [strings appendFormat:@"\n\n=========================================\nResponse End\n=========================================\n\n"];
    NSLog(@"%@", strings);
#endif
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
    completionHandler(NSURLSessionResponseAllow);
    self.response = response;
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest *_Nullable))completionHandler {
    if (response != nil) {
        self.response = response;
        [[self client] URLProtocol:self wasRedirectedToRequest:request redirectResponse:response];
    }
}

@end

@implementation NSObject (__KAIURL)

- (id)KAI_defaultValue:(id)defaultData {
    BOOL shouldContinue = NO;
    if ([self isKindOfClass:[NSString class]] || [self isKindOfClass:NSClassFromString(@"NSTaggedPointerString")] || [self isKindOfClass:NSClassFromString(@"__NSCFConstantString")]) {
        if ([defaultData isKindOfClass:[NSString class]] || [defaultData isKindOfClass:NSClassFromString(@"NSTaggedPointerString")] || [defaultData isKindOfClass:NSClassFromString(@"__NSCFConstantString")]) {
            shouldContinue = YES;
        }
    } else if (![defaultData isMemberOfClass:[self class]]) {
        return defaultData;
    }

    if (shouldContinue == NO) {
        return [NSString stringWithFormat:@"%@", defaultData];
    }

    if ([self KAI_isEmptyObject]) {
        return defaultData;
    }

    return self;
}

- (BOOL)KAI_isEmptyObject {
    if ([self isEqual:[NSNull null]]) {
        return YES;
    }

    if ([self isKindOfClass:[NSString class]]) {
        if ([(NSString *)self length] == 0) {
            return YES;
        }
    }

    if ([self isKindOfClass:[NSArray class]]) {
        if ([(NSArray *)self count] == 0) {
            return YES;
        }
    }

    if ([self isKindOfClass:[NSDictionary class]]) {
        if ([(NSDictionary *)self count] == 0) {
            return YES;
        }
    }

    return NO;
}

@end

@implementation NSMutableString (__KAIURL)

- (void)appendURLRequest:(NSURLRequest *)request {
    [self appendFormat:@"\n\nHTTP URL:\n\t%@", request.URL];
    [self appendFormat:@"\n\nHTTP Header:\n%@", request.allHTTPHeaderFields ? request.allHTTPHeaderFields : @"\t\t\t\t\tN/A"];
    //    [self appendFormat:@"\n\nHTTP Origin Params:\n\t%@", request.originRequestParams.CT_jsonString];
    //    [self appendFormat:@"\n\nHTTP Actual Params:\n\t%@", request.actualRequestParams.CT_jsonString];
    [self appendFormat:@"\n\nHTTP Body:\n\t%@", [[[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding] KAI_defaultValue:@"\t\t\t\tN/A"]];

    NSMutableString *headerString = [[NSMutableString alloc] init];
    [request.allHTTPHeaderFields enumerateKeysAndObjectsUsingBlock:^(NSString *_Nonnull key, NSString *_Nonnull obj, BOOL *_Nonnull stop) {
        NSString *header = [NSString stringWithFormat:@" -H \"%@: %@\"", key, obj];
        [headerString appendString:header];
    }];

    [self appendString:@"\n\nCURL:\n\t curl"];
    [self appendFormat:@" -X %@", request.HTTPMethod];

    if (headerString.length > 0) {
        [self appendString:headerString];
    }
    if (request.HTTPBody.length > 0) {
        [self appendFormat:@" -d '%@'", [[[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding] KAI_defaultValue:@"\t\t\t\tN/A"]];
    }

    [self appendFormat:@" %@", request.URL];
}

@end
