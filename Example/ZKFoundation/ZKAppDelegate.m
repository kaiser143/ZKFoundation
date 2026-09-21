//
//  ZKAppDelegate.m
//  ZKFoundation
//
//  Created by zhangkai on 03/08/2019.
//  Copyright (c) 2019 zhangkai. All rights reserved.
//

#import "ZKAppDelegate.h"
#import <ZKFoundation/ZKFoundation.h>

@interface ZKNetworkConsoleLogger : NSObject <ZKNetworkLoggerProtocol> @end

@implementation ZKNetworkConsoleLogger

@synthesize filter = _filter;

@end

@implementation ZKAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 应用启动后进行自定义的入口。
    // iOS 13+ 使用 SceneDelegate 创建 window，这里仅做全局外观等配置，兼容 iOS 12 及以下才使用 self.window。
    if (@available(iOS 13.0, *)) {
    } else {
        self.window.backgroundColor = UIColor.whiteColor;
    }

    [[UINavigationBar appearance] setShadowImage:[UIImage new]];
//    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"topbarbg_ios7"]
//                                       forBarMetrics:UIBarMetricsDefault];

    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(0, 0, 4, 0);
    UIImage *backImage      = [[UIImage imageNamed:@"barbuttonicon_back"] imageWithAlignmentRectInsets:edgeInsets];
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *appearance = UINavigationBarAppearance.new;
        [appearance setBackIndicatorImage:backImage transitionMaskImage:backImage];
    } else {
        [[UINavigationBar appearance] setBackIndicatorImage:backImage];
        [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:backImage];
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    }
    
#if DEBUG
    ZKNetworkConsoleLogger<ZKNetworkLoggerProtocol> *testLogger = [ZKNetworkConsoleLogger new];
    NSPredicate *filter = [NSPredicate predicateWithBlock:^BOOL(NSURLRequest *request, NSDictionary<NSString *,id> * _Nullable bindings) {
        return !([request.URL.baseURL.absoluteString isEqualToString:@"httpbin.org"]);
    }];
    testLogger.filter = filter;
    
    [ZKURLProtocolLogger addLogger:testLogger];
    [ZKURLProtocolLogger startLogging];
#endif

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // 当应用即将从活动状态转为非活动状态时，会调用此方法。这可能是由某些临时中断（例如收到电话或短信）引起的，
    // 也可能是用户退出应用、应用开始转入后台所致。可在此暂停正在执行的任务、停用计时器，并降低 OpenGL ES 的帧率；
    // 游戏应使用此方法暂停游戏。
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // 可使用此方法释放共享资源、保存用户数据、使计时器失效，并保存足够的应用状态信息，
    // 以便应用之后被终止时能够恢复到当前状态。
    // 如果应用支持后台执行，那么用户退出应用时会调用此方法，而不是 applicationWillTerminate:。
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // 在应用从后台状态转为非活动状态的过程中会调用此方法；可在此撤销应用进入后台时所做的许多改动。
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // 重新启动应用处于非活动状态时暂停（或尚未启动）的所有任务。如果应用此前位于后台，还可以选择刷新用户界面。
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // 应用即将终止时会调用此方法。请酌情保存数据。另请参阅 applicationDidEnterBackground:。
}

#pragma mark - UISceneSession Lifecycle

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    UISceneConfiguration *configuration = [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
    configuration.delegateClass = NSClassFromString(@"ZKSceneDelegate");
    return configuration;
}

- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
}

@end
