//
//  ZKFolderMonitor.h
//  ZKFoundation
//
//  Created by Kaiser on 2019/3/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** 监听的文件夹发生变化时执行的回调 */
typedef void (^ZKFolderMonitorBlock)(void);

/**
 * 用于监听文件夹变化的类。
 * 例如监听应用文档目录，在用户通过 iTunes 文件共享添加或删除文件时得到通知。
 */
@interface ZKFolderMonitor : NSObject

#pragma mark - 创建监听器

/**
 * 为指定 URL 创建文件夹监听器，该文件夹有变化时执行 block。
 *
 * URL 必须是 file:// 形式的文件 URL，URL 与 block 均为必传。block 在后台队列执行。
 *
 * @param URL   要监听的文件夹 URL
 * @param block 文件夹被修改时执行的回调
 * @return 已创建但处于暂停状态的监听器，需调用 -startMonitoring 开始监听
 */
+ (ZKFolderMonitor *_Nonnull)folderMonitorForURL:(NSURL *_Nonnull)URL block:(ZKFolderMonitorBlock _Nonnull)block;

#pragma mark - 开始/停止监听

/** 开始监听。可多次调用 start/stop。 */
- (void)startMonitoring;

/** 停止监听。可多次调用 start/stop。 */
- (void)stopMonitoring;

@end

NS_ASSUME_NONNULL_END
