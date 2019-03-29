//
//  ZKLocationManager.h
//  FBSnapshotTestCase
//
//  Created by Kaiser on 2019/3/12.
//

#import "ZKLocationRequestDefines.h"

NS_ASSUME_NONNULL_BEGIN

/**
 An abstraction around CLLocationManager that provides a block-based asynchronous API for obtaining the device's location.
 ZKLocationManager automatically starts and stops system location services as needed to minimize battery drain.
 */
@interface ZKLocationManager : NSObject

/** Returns the current state of location services for this app, based on the system settings and user authorization status. */
+ (ZKLocationServicesState)locationServicesState;

/** Returns the current state of heading services for this device. */
+ (ZKHeadingServicesState)headingServicesState;

/** Returns the singleton instance of this class. */
+ (instancetype)sharedInstance;

@property (nonatomic, assign) ZKAuthorizationType preferredAuthorizationType;

#pragma mark Location Requests

/**
 Asynchronously requests the current location of the device using location services.
 
 @param desiredAccuracy The accuracy level desired (refers to the accuracy and recency of the location).
 @param timeout         The maximum amount of time (in seconds) to wait for a location with the desired accuracy before completing. If
 this value is 0.0, no timeout will be set (will wait indefinitely for success, unless request is force completed or canceled).
 @param block           The block to execute upon success, failure, or timeout.
 
 @return The location request ID, which can be used to force early completion or cancel the request while it is in progress.
 */
- (ZKLocationRequestID)requestLocationWithDesiredAccuracy:(ZKLocationAccuracy)desiredAccuracy
                                                  timeout:(NSTimeInterval)timeout
                                                    block:(ZKLocationRequestBlock)block;

/**
 Asynchronously requests the current location of the device using location services, optionally delaying the timeout countdown until the user has
 responded to the dialog requesting permission for this app to access location services.
 
 @param desiredAccuracy      The accuracy level desired (refers to the accuracy and recency of the location).
 @param timeout              The maximum amount of time (in seconds) to wait for a location with the desired accuracy before completing. If
 this value is 0.0, no timeout will be set (will wait indefinitely for success, unless request is force completed or canceled).
 @param delayUntilAuthorized A flag specifying whether the timeout should only take effect after the user responds to the system prompt requesting
 permission for this app to access location services. If YES, the timeout countdown will not begin until after the
 app receives location services permissions. If NO, the timeout countdown begins immediately when calling this method.
 @param block                The block to execute upon success, failure, or timeout.
 
 @return The location request ID, which can be used to force early completion or cancel the request while it is in progress.
 */
- (ZKLocationRequestID)requestLocationWithDesiredAccuracy:(ZKLocationAccuracy)desiredAccuracy
                                                  timeout:(NSTimeInterval)timeout
                                     delayUntilAuthorized:(BOOL)delayUntilAuthorized
                                                    block:(ZKLocationRequestBlock)block;

/**
 Creates a subscription for location updates that will execute the block once per update indefinitely (until canceled), regardless of the accuracy of each location.
 This method instructs location services to use the highest accuracy available (which also requires the most power).
 If an error occurs, the block will execute with a status other than ZKLocationStatusSuccess, and the subscription will be canceled automatically.
 
 @param block The block to execute every time an updated location is available.
 The status will be ZKLocationStatusSuccess unless an error occurred; it will never be ZKLocationStatusTimedOut.
 
 @return The location request ID, which can be used to cancel the subscription of location updates to this block.
 */
- (ZKLocationRequestID)subscribeToLocationUpdatesWithBlock:(ZKLocationRequestBlock)block;

/**
 Creates a subscription for location updates that will execute the block once per update indefinitely (until canceled), regardless of the accuracy of each location.
 The specified desired accuracy is passed along to location services, and controls how much power is used, with higher accuracies using more power.
 If an error occurs, the block will execute with a status other than ZKLocationStatusSuccess, and the subscription will be canceled automatically.
 
 @param desiredAccuracy The accuracy level desired, which controls how much power is used by the device's location services.
 @param block           The block to execute every time an updated location is available. Note that this block runs for every update, regardless of
 whether the achievedAccuracy is at least the desiredAccuracy.
 The status will be ZKLocationStatusSuccess unless an error occurred; it will never be ZKLocationStatusTimedOut.
 
 @return The location request ID, which can be used to cancel the subscription of location updates to this block.
 */
- (ZKLocationRequestID)subscribeToLocationUpdatesWithDesiredAccuracy:(ZKLocationAccuracy)desiredAccuracy
                                                               block:(ZKLocationRequestBlock)block;

/**
 Creates a subscription for significant location changes that will execute the block once per change indefinitely (until canceled).
 If an error occurs, the block will execute with a status other than ZKLocationStatusSuccess, and the subscription will be canceled automatically.
 
 @param block The block to execute every time an updated location is available.
 The status will be ZKLocationStatusSuccess unless an error occurred; it will never be ZKLocationStatusTimedOut.
 
 @return The location request ID, which can be used to cancel the subscription of significant location changes to this block.
 */
- (ZKLocationRequestID)subscribeToSignificantLocationChangesWithBlock:(ZKLocationRequestBlock)block;

/** Immediately forces completion of the location request with the given requestID (if it exists), and executes the original request block with the results.
 For one-time location requests, this is effectively a manual timeout, and will result in the request completing with status ZKLocationStatusTimedOut.
 If the requestID corresponds to a subscription, then the subscription will simply be canceled. */
- (void)forceCompleteLocationRequest:(ZKLocationRequestID)requestID;

/** Immediately cancels the location request (or subscription) with the given requestID (if it exists), without executing the original request block. */
- (void)cancelLocationRequest:(ZKLocationRequestID)requestID;

#pragma mark Heading Requests

/**
 Creates a subscription for heading updates that will execute the block once per update indefinitely (until canceled), assuming the heading update exceeded the heading filter threshold.
 If an error occurs, the block will execute with a status other than ZKHeadingStatusSuccess, and the subscription will be canceled automatically.
 @param block           The block to execute every time an updated heading is available. The status will be ZKHeadingStatusSuccess unless an error occurred.
 @return The heading request ID, which can be used to cancel the subscription of heading updates to this block.
 */
- (ZKHeadingRequestID)subscribeToHeadingUpdatesWithBlock:(ZKHeadingRequestBlock)block;

/** Immediately cancels the heading subscription request with the given requestID (if it exists), without executing the original request block. */
- (void)cancelHeadingRequest:(ZKHeadingRequestID)requestID;

#pragma mark - Additions

/** It is possible to force enable background location fetch even if your set any kind of Authorizations */
- (void)setBackgroundLocationUpdate:(BOOL)enabled;

/**
 Sets a Boolean indicating whether the status bar changes its appearance when location services
 are used in the background.
 
 This property affects only apps that received always authorization. When such an app moves to the background,
 the system uses this property to determine whether to change the status bar appearance to indicate that
 location services are in use. Displaying a modified status bar gives the user a quick way to return to your app.
 The default value of this property is false.
 
 For apps with when-in-use authorization, the system always changes the status bar appearance when
 the app uses location services in the background.
 
 @param shows           Boolean indicating whether the status bar changes its appearance when location services are used in the background.
 */
- (void)setShowsBackgroundLocationIndicator:(BOOL)shows;

/**
 Sets a Boolean value indicating whether the location manager object may pause location updates.
 
 @param pauses           Boolean value indicating whether the location manager object may pause location updates.
 */
- (void)setPausesLocationUpdatesAutomatically:(BOOL)pauses;

@end

NS_ASSUME_NONNULL_END
