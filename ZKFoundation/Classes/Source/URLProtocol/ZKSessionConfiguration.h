//
//  ZKSessionConfiguration.h
//  ZKURLProtocol
//
//  Created by Kaiser on 2018/8/24.
//  Copyright © 2018年 Kaiser. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZKSessionConfiguration : NSObject

@property (nonatomic,assign) BOOL isSwizzle;

+ (ZKSessionConfiguration *)defaultConfiguration;

/**
 *  swizzle NSURLSessionConfiguration's protocolClasses method
 */
- (void)load;

/**
 *  make NSURLSessionConfiguration's protocolClasses method is normal
 */
- (void)unload;

@end
