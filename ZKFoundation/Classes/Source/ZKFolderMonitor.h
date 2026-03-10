//
//  ZKFolderMonitor.h
//  ZKFoundation
//
//  Created by Kaiser on 2019/3/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 当监视的文件夹发生变化时执行的块
typedef void (^ZKFolderMonitorBlock)(void);

/**
 用于监视文件夹变化的类。这可用于监视应用程序文档文件夹中的文件更改，例如用户通过 iTunes 文件共享添加或删除文件。
 */
@interface ZKFolderMonitor : NSObject

/**
 @name 创建文件夹监视器
 */

/**
 创建一个新的 ZKFolderMonitor 来监视给定 URL 的文件夹。每当该文件夹发生更改时，将执行该块。
 
 URL 必须是文件 URL。URL 和块参数都是必需的。该块在后台队列上分派。
 
 @param URL 被监视的文件夹 URL
 @param block 如果文件夹被修改则执行的块
 @returns 处于暂停模式的实例化监视器。调用 -startMonitoring 开始监视。
 */
+ (ZKFolderMonitor *_Nonnull)folderMonitorForURL:(NSURL *_Nonnull)URL block:(ZKFolderMonitorBlock _Nonnull)block;

/**
 @name 开始/停止监视
 */

/**
 开始监视文件夹。监视器可以多次启动和停止。
 */
- (void)startMonitoring;

/**
 停止监视文件夹。监视器可以多次启动和停止。
 */
- (void)stopMonitoring;

@end

NS_ASSUME_NONNULL_END
