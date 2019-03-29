//
//  ZKRequestIDGenerator.h
//  FBSnapshotTestCase
//
//  Created by Kaiser on 2019/3/12.
//

#import "ZKLocationRequestDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZKRequestIDGenerator : NSObject

/**
 Returns a unique request ID (within the lifetime of the application).
 */
+ (ZKLocationRequestID)getUniqueRequestID;

@end

NS_ASSUME_NONNULL_END
