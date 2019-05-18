//
//  ZKFolderMonitor.h
//  FBSnapshotTestCase
//
//  Created by Kaiser on 2019/3/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// The block to execute if a monitored folder changes
typedef void (^ZKFolderMonitorBlock)(void);

/**
 Class for monitoring changes on a folder. This can be used to monitor the application documents folder for changes in the files there if the user adds or removes files via iTunes file sharing.
 */
@interface ZKFolderMonitor : NSObject

/**
 @name Creating a Folder Monitor
 */

/**
 Creates a new ZKFolderMonitor to watch the folder at the given URL. Whenever there is a change on this folder the block is executed.
 
 The URL must be a file URL. Both the URL and the block parameter are mandatory. The block is being dispatched on a background queue.
 
 @param URL The monitored folder URL
 @param block The block to execute if the folder is being modified
 @returns The instantiated monitor in suspended mode. Call -startMonitoring to start monitoring.
 */
+ (ZKFolderMonitor *_Nonnull)folderMonitorForURL:(NSURL *_Nonnull)URL block:(ZKFolderMonitorBlock _Nonnull)block;

/**
 @name Starting/Stopping Monitoring
 */

/**
 Start monitoring the folder. A monitor can be started and stopped multiple times.
 */
- (void)startMonitoring;

/**
 Stop monitoring the folder. A monitor can be started and stopped multiple times.
 */
- (void)stopMonitoring;

@end

NS_ASSUME_NONNULL_END
