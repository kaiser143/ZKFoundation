//
//  ZKURLProtocol.h
//  ZKFoundation
//
//  Created by Kaiser on 2018/8/24.
//

#import <Foundation/Foundation.h>

@interface ZKURLProtocol : NSURLProtocol

/// 开始监听
+ (void)startMonitor;

/// 停止监听
+ (void)stopMonitor;

@end