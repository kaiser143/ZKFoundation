//
//  ZKLocationRequest.m
//  FBSnapshotTestCase
//
//  Created by Kaiser on 2019/3/12.
//

#import "ZKLocationRequest.h"
#import "ZKRequestIDGenerator.h"

@interface ZKLocationRequest ()

// Redeclare this property as readwrite for internal use.
@property (nonatomic, assign, readwrite) BOOL hasTimedOut;

/** The NSDate representing the time when the request started. Set when the |timeout| property is set. */
@property (nonatomic, strong) NSDate *requestStartTime;
/** The timer that will fire to notify this request that it has timed out. Started when the |timeout| property is set. */
@property (nonatomic, strong) NSTimer *timeoutTimer;

@end

@implementation ZKLocationRequest

/**
 Throws an exeption when you try to create a location request using a non-designated initializer.
 */
- (instancetype)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Must use initWithType: instead." userInfo:nil];
    return [self initWithType:ZKLocationRequestTypeSingle];
}

/**
 Designated initializer. Initializes and returns a newly allocated location request object with the specified type.
 
 @param type The type of the location request.
 */
- (instancetype)initWithType:(ZKLocationRequestType)type
{
    self = [super init];
    if (self) {
        _requestID = [ZKRequestIDGenerator getUniqueRequestID];
        _type = type;
        _hasTimedOut = NO;
    }
    return self;
}

/**
 Returns the associated recency threshold (in seconds) for the location request's desired accuracy level.
 */
- (NSTimeInterval)updateTimeStaleThreshold
{
    switch (self.desiredAccuracy) {
        case ZKLocationAccuracyRoom:
            return kZKUpdateTimeStaleThresholdRoom;
            break;
        case ZKLocationAccuracyHouse:
            return kZKUpdateTimeStaleThresholdHouse;
            break;
        case ZKLocationAccuracyBlock:
            return kZKUpdateTimeStaleThresholdBlock;
            break;
        case ZKLocationAccuracyNeighborhood:
            return kZKUpdateTimeStaleThresholdNeighborhood;
            break;
        case ZKLocationAccuracyCity:
            return kZKUpdateTimeStaleThresholdCity;
            break;
        default:
            NSAssert(NO, @"Unknown desired accuracy.");
            return 0.0;
            break;
    }
}

/**
 Returns the associated horizontal accuracy threshold (in meters) for the location request's desired accuracy level.
 */
- (CLLocationAccuracy)horizontalAccuracyThreshold
{
    switch (self.desiredAccuracy) {
        case ZKLocationAccuracyRoom:
            return kZKHorizontalAccuracyThresholdRoom;
            break;
        case ZKLocationAccuracyHouse:
            return kZKHorizontalAccuracyThresholdHouse;
            break;
        case ZKLocationAccuracyBlock:
            return kZKHorizontalAccuracyThresholdBlock;
            break;
        case ZKLocationAccuracyNeighborhood:
            return kZKHorizontalAccuracyThresholdNeighborhood;
            break;
        case ZKLocationAccuracyCity:
            return kZKHorizontalAccuracyThresholdCity;
            break;
        default:
            NSAssert(NO, @"Unknown desired accuracy.");
            return 0.0;
            break;
    }
}

/**
 Completes the location request.
 */
- (void)complete
{
    [self.timeoutTimer invalidate];
    self.timeoutTimer = nil;
    self.requestStartTime = nil;
}

/**
 Forces the location request to consider itself timed out.
 */
- (void)forceTimeout
{
    if (self.isRecurring == NO) {
        self.hasTimedOut = YES;
    } else {
        NSAssert(self.isRecurring == NO, @"Only single location requests (not recurring requests) should ever be considered timed out.");
    }
}

/**
 Cancels the location request.
 */
- (void)cancel
{
    [self.timeoutTimer invalidate];
    self.timeoutTimer = nil;
    self.requestStartTime = nil;
}

/**
 Starts the location request's timeout timer if a nonzero timeout value is set, and the timer has not already been started.
 */
- (void)startTimeoutTimerIfNeeded
{
    if (self.timeout > 0 && !self.timeoutTimer) {
        self.requestStartTime = [NSDate date];
        self.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:self.timeout target:self selector:@selector(timeoutTimerFired:) userInfo:nil repeats:NO];
    }
}

/**
 Computed property that returns whether this is a subscription request.
 */
- (BOOL)isRecurring
{
    return (self.type == ZKLocationRequestTypeSubscription) || (self.type == ZKLocationRequestTypeSignificantChanges);
}

/**
 Computed property that returns how long the request has been alive (since the timeout value was set).
 */
- (NSTimeInterval)timeAlive
{
    if (self.requestStartTime == nil) {
        return 0.0;
    }
    return fabs([self.requestStartTime timeIntervalSinceNow]);
}

/**
 Returns whether the location request has timed out or not.
 Once this becomes YES, it will not automatically reset to NO even if a new timeout value is set.
 */
- (BOOL)hasTimedOut
{
    if (self.timeout > 0.0 && self.timeAlive > self.timeout) {
        _hasTimedOut = YES;
    }
    return _hasTimedOut;
}

/**
 Callback when the timeout timer fires. Notifies the delegate that this event has occurred.
 */
- (void)timeoutTimerFired:(NSTimer *)timer
{
    self.hasTimedOut = YES;
    [self.delegate locationRequestDidTimeout:self];
}

/**
 Two location requests are considered equal if their request IDs match.
 */
- (BOOL)isEqual:(id)object
{
    if (object == self) {
        return YES;
    }
    if (!object || ![object isKindOfClass:[self class]]) {
        return NO;
    }
    if (((ZKLocationRequest *)object).requestID == self.requestID) {
        return YES;
    }
    return NO;
}

/**
 Return a hash based on the string representation of the request ID.
 */
- (NSUInteger)hash
{
    return [[NSString stringWithFormat:@"%ld", (long)self.requestID] hash];
}

- (void)dealloc
{
    [_timeoutTimer invalidate];
}

@end
