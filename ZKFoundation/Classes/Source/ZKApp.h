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
 *  在当前版本的应用首次启动时执行一个回调块。
 *  注意：与 UI 相关的操作请在主线程执行。
 *
 *  @param block 要执行的回调，参数 didLaunched 表示是否为当前版本的首次启动
 */
+ (void)applicationDidLaunched:(void(^ _Nullable)(BOOL didLaunched))block;

@end

NS_ASSUME_NONNULL_END
