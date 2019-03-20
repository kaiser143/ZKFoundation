//
//  ZKHeadingRequest.h
//  FBSnapshotTestCase
//
//  Created by Kaiser on 2019/3/12.
//

#import "ZKLocationRequestDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZKHeadingRequest : NSObject

/** The request ID for this heading request (set during initialization). */
@property (nonatomic, readonly) ZKHeadingRequestID requestID;
/** Whether this is a recurring heading request (all heading requests are assumed to be for now). */
@property (nonatomic, readonly) BOOL isRecurring;
/** The block to execute when the heading request completes. */
@property (nonatomic, copy, nullable) ZKHeadingRequestBlock block;

@end

NS_ASSUME_NONNULL_END
