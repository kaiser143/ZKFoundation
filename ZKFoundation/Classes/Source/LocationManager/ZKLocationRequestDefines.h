//
//  ZKLocationRequestDefines.h
//  Pods
//
//  Created by Kaiser on 2019/3/12.
//

#ifndef ZKLocationRequestDefines_h
#define ZKLocationRequestDefines_h

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#if __has_feature(objc_generics)
#define __ZK_GENERICS(type, ...) type<__VA_ARGS__>
#else
#define __ZK_GENERICS(type, ...) type
#endif

#ifdef NS_DESIGNATED_INITIALIZER
#define __ZK_DESIGNATED_INITIALIZER NS_DESIGNATED_INITIALIZER
#else
#define __ZK_DESIGNATED_INITIALIZER
#endif

static const CLLocationAccuracy kZKHorizontalAccuracyThresholdCity         = 5000.0; // in meters
static const CLLocationAccuracy kZKHorizontalAccuracyThresholdNeighborhood = 1000.0; // in meters
static const CLLocationAccuracy kZKHorizontalAccuracyThresholdBlock        = 100.0;  // in meters
static const CLLocationAccuracy kZKHorizontalAccuracyThresholdHouse        = 15.0;   // in meters
static const CLLocationAccuracy kZKHorizontalAccuracyThresholdRoom         = 5.0;    // in meters

static const NSTimeInterval kZKUpdateTimeStaleThresholdCity         = 600.0; // in seconds
static const NSTimeInterval kZKUpdateTimeStaleThresholdNeighborhood = 300.0; // in seconds
static const NSTimeInterval kZKUpdateTimeStaleThresholdBlock        = 60.0;  // in seconds
static const NSTimeInterval kZKUpdateTimeStaleThresholdHouse        = 15.0;  // in seconds
static const NSTimeInterval kZKUpdateTimeStaleThresholdRoom         = 5.0;   // in seconds

/** The possible states that location services can be in. */
typedef NS_ENUM(NSInteger, ZKLocationServicesState) {
    /** User has already granted this app permissions to access location services, and they are enabled and ready for use by this app.
     Note: this state will be returned for both the "When In Use" and "Always" permission levels. */
    ZKLocationServicesStateAvailable,
    /** User has not yet responded to the dialog that grants this app permission to access location services. */
    ZKLocationServicesStateNotDetermined,
    /** User has explicitly denied this app permission to access location services. (The user can enable permissions again for this app from the system Settings app.) */
    ZKLocationServicesStateDenied,
    /** User does not have ability to enable location services (e.g. parental controls, corporate policy, etc). */
    ZKLocationServicesStateRestricted,
    /** User has turned off location services device-wide (for all apps) from the system Settings app. */
    ZKLocationServicesStateDisabled
};

/** The possible states that heading services can be in. */
typedef NS_ENUM(NSInteger, ZKHeadingServicesState) {
    /** Heading services are available on the device */
    ZKHeadingServicesStateAvailable,
    /** Heading services are available on the device */
    ZKHeadingServicesStateUnavailable,
};

/** A unique ID that corresponds to one location request. */
typedef NSInteger ZKLocationRequestID;

/** A unique ID that corresponds to one heading request. */
typedef NSInteger ZKHeadingRequestID;

/** An abstraction of both the horizontal accuracy and recency of location data.
 Room is the highest level of accuracy/recency; City is the lowest level. */
typedef NS_ENUM(NSInteger, ZKLocationAccuracy) {
    // 'None' is not valid as a desired accuracy.
    /** Inaccurate (>5000 meters, and/or received >10 minutes ago). */
    ZKLocationAccuracyNone = 0,

    // The below options are valid desired accuracies.
    /** 5000 meters or better, and received within the last 10 minutes. Lowest accuracy. */
    ZKLocationAccuracyCity,
    /** 1000 meters or better, and received within the last 5 minutes. */
    ZKLocationAccuracyNeighborhood,
    /** 100 meters or better, and received within the last 1 minute. */
    ZKLocationAccuracyBlock,
    /** 15 meters or better, and received within the last 15 seconds. */
    ZKLocationAccuracyHouse,
    /** 5 meters or better, and received within the last 5 seconds. Highest accuracy. */
    ZKLocationAccuracyRoom,
};

/** An alias of the heading filter accuracy in degrees.
 Specifies the minimum amount of change in degrees needed for a heading service update. Observers will not be notified of updates less than the stated filter value. */
typedef CLLocationDegrees ZKHeadingFilterAccuracy;

/** A status that will be passed in to the completion block of a location request. */
typedef NS_ENUM(NSInteger, ZKLocationStatus) {
    // These statuses will accompany a valid location.
    /** Got a location and desired accuracy level was achieved successfully. */
    ZKLocationStatusSuccess = 0,
    /** Got a location, but the desired accuracy level was not reached before timeout. (Not applicable to subscriptions.) */
    ZKLocationStatusTimedOut,

    // These statuses indicate some sort of error, and will accompany a nil location.
    /** User has not yet responded to the dialog that grants this app permission to access location services. */
    ZKLocationStatusServicesNotDetermined,
    /** User has explicitly denied this app permission to access location services. */
    ZKLocationStatusServicesDenied,
    /** User does not have ability to enable location services (e.g. parental controls, corporate policy, etc). */
    ZKLocationStatusServicesRestricted,
    /** User has turned off location services device-wide (for all apps) from the system Settings app. */
    ZKLocationStatusServicesDisabled,
    /** An error occurred while using the system location services. */
    ZKLocationStatusError
};

/** A status that will be passed in to the completion block of a heading request. */
typedef NS_ENUM(NSInteger, ZKHeadingStatus) {
    // These statuses will accompany a valid heading.
    /** Got a heading successfully. */
    ZKHeadingStatusSuccess = 0,

    // These statuses indicate some sort of error, and will accompany a nil heading.
    /** Heading was invalid. */
    ZKHeadingStatusInvalid,

    /** Heading services are not available on the device */
    ZKHeadingStatusUnavailable
};

/**
 A block type for a location request, which is executed when the request succeeds, fails, or times out.
 
 @param currentLocation The most recent & accurate current location available when the block executes, or nil if no valid location is available.
 @param achievedAccuracy The accuracy level that was actually achieved (may be better than, equal to, or worse than the desired accuracy).
 @param status The status of the location request - whether it succeeded, timed out, or failed due to some sort of error. This can be used to
 understand what the outcome of the request was, decide if/how to use the associated currentLocation, and determine whether other
 actions are required (such as displaying an error message to the user, retrying with another request, quietly proceeding, etc).
 */
typedef void (^ZKLocationRequestBlock)(CLLocation *currentLocation, ZKLocationAccuracy achievedAccuracy, ZKLocationStatus status);

/**
 A block type for a heading request, which is executed when the request succeeds.
 @param currentHeading  The most recent current heading available when the block executes.
 @param status          The status of the request - whether it succeeded or failed due to some sort of error. This can be used to understand if any further action is needed.
 */
typedef void (^ZKHeadingRequestBlock)(CLHeading *currentHeading, ZKHeadingStatus status);

typedef NS_ENUM(NSUInteger, ZKAuthorizationType) {
    ZKAuthorizationTypeAuto,
    ZKAuthorizationTypeAlways,
    ZKAuthorizationTypeWhenInUse,
};

#endif /* ZKLocationRequestDefines_h */
