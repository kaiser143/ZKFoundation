//
//  NSRunLoop+ZKAdd.h
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2017/3/6.
//  Copyright © 2017年 Kaiser. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * @code
 - (void)testPerformBlockAndWait {
    // 1
    __block BOOL flag = NO;
 
    [[NSRunLoop currentRunLoop] performBlockAndWait:^(BOOL *finish) {
        double delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_after(popTime, queue, ^(void){
            // 2
            flag = YES;
            *finish = YES;
        });
    }];
 
    // 3
    XCTAssertTrue(flag);
 }
 * @endcode
 */

extern NSString *const NSRunloopTimeoutException;

@interface NSRunLoop (ZKAdd)

/**
 *	@brief	extension of NSRunLoop for waiting.
 */
- (void)performBlockAndWait:(void (^)(BOOL *finish))block timeoutInterval:(NSTimeInterval)timeoutInterval;

@end
