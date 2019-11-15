//
//  ZKApp.h
//  ZKFoundation
//
//  Created by Kaiser on 2019/3/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZKApp : NSObject

/**
 *  Executes a block on first start of the App for current version.
 *  Remember to execute UI instuctions on main thread
 *
 *  @param block The block to execute, returns isFirstLaunchForCurrentVersion
 */
+ (void)applicationDidLaunched:(void(^ _Nullable)(BOOL didLaunched))block;

@end

NS_ASSUME_NONNULL_END
