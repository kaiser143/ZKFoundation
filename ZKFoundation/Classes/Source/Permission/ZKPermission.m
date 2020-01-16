//
//  ZKPermission.m
//  ZKFoundation
//
//  Created by Kaiser on 2019/7/8.
//
//

#import "ZKPermission.h"
#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>
#import <EventKit/EventKit.h>
#import <Contacts/Contacts.h>
#import <Speech/Speech.h>
#import <HealthKit/HealthKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <UserNotifications/UserNotifications.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>

static NSInteger const ZKPermissionTypeLocationDistanceFilter = 10; //`Positioning accuracy` -> 定位精度

@interface ZKPermission ()

@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation ZKPermission

+ (instancetype)manager {
    static dispatch_once_t onceToken;
    static ZKPermission *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)requestWithType:(ZKPermissionType)type
               callback:(void (^)(BOOL response, ZKPermissionAuthorizationStatus status))callback {
    switch (type) {
        case ZKPermissionTypePhoto: {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusDenied) {
                    callback(NO, ZKPermissionAuthorizationStatusDenied);
                } else if (status == PHAuthorizationStatusNotDetermined) {
                    callback(NO, ZKPermissionAuthorizationStatusNotDetermined);
                } else if (status == PHAuthorizationStatusRestricted) {
                    callback(NO, ZKPermissionAuthorizationStatusRestricted);
                } else if (status == PHAuthorizationStatusAuthorized) {
                    callback(YES, ZKPermissionAuthorizationStatusAuthorized);
                }
            }];
        } break;

        case ZKPermissionTypeCamera: {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
                                     completionHandler:^(BOOL granted) {
                                         AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
                                         if (granted) {
                                             callback(YES, ZKPermissionAuthorizationStatusAuthorized);
                                         } else {
                                             if (status == AVAuthorizationStatusDenied) {
                                                 callback(NO, ZKPermissionAuthorizationStatusDenied);
                                             } else if (status == AVAuthorizationStatusNotDetermined) {
                                                 callback(NO, ZKPermissionAuthorizationStatusNotDetermined);
                                             } else if (status == AVAuthorizationStatusRestricted) {
                                                 callback(NO, ZKPermissionAuthorizationStatusRestricted);
                                             }
                                         }
                                     }];
        } break;

        case ZKPermissionTypeMedia: {
            if (@available(iOS 9.3, *)) {
                [MPMediaLibrary requestAuthorization:^(MPMediaLibraryAuthorizationStatus status) {
                    if (status == MPMediaLibraryAuthorizationStatusDenied) {
                        callback(NO, ZKPermissionAuthorizationStatusDenied);
                    } else if (status == MPMediaLibraryAuthorizationStatusNotDetermined) {
                        callback(NO, ZKPermissionAuthorizationStatusNotDetermined);
                    } else if (status == MPMediaLibraryAuthorizationStatusRestricted) {
                        callback(NO, ZKPermissionAuthorizationStatusRestricted);
                    } else if (status == MPMediaLibraryAuthorizationStatusAuthorized) {
                        callback(YES, ZKPermissionAuthorizationStatusAuthorized);
                    }
                }];
            }
        } break;

        case ZKPermissionTypeMicrophone: {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio
                                     completionHandler:^(BOOL granted) {
                                         AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
                                         if (granted) {
                                             callback(YES, ZKPermissionAuthorizationStatusAuthorized);
                                         } else {
                                             if (status == AVAuthorizationStatusDenied) {
                                                 callback(NO, ZKPermissionAuthorizationStatusDenied);
                                             } else if (status == AVAuthorizationStatusNotDetermined) {
                                                 callback(NO, ZKPermissionAuthorizationStatusNotDetermined);
                                             } else if (status == AVAuthorizationStatusRestricted) {
                                                 callback(NO, ZKPermissionAuthorizationStatusRestricted);
                                             }
                                         }
                                     }];
        } break;

        case ZKPermissionTypeLocationWhenInUse:
        case ZKPermissionTypeLocationAlways: {
            if ([CLLocationManager locationServicesEnabled]) {
                CLLocationManager *locationManager = [[CLLocationManager alloc] init];
                if (type == ZKPermissionTypeLocationAlways)
                    [locationManager requestAlwaysAuthorization];
                else if (type == ZKPermissionTypeLocationWhenInUse)
                    [locationManager requestWhenInUseAuthorization];

                locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
                locationManager.distanceFilter  = ZKPermissionTypeLocationDistanceFilter;
                [locationManager startUpdatingLocation];
                self.locationManager = locationManager;
            }
            CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
            if (status == kCLAuthorizationStatusAuthorizedAlways) {
                callback(YES, ZKPermissionAuthorizationStatusLocationAlways);
            } else if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
                callback(YES, ZKPermissionAuthorizationStatusLocationWhenInUse);
            } else if (status == kCLAuthorizationStatusDenied) {
                callback(NO, ZKPermissionAuthorizationStatusDenied);
            } else if (status == kCLAuthorizationStatusNotDetermined) {
                callback(NO, ZKPermissionAuthorizationStatusNotDetermined);
            } else if (status == kCLAuthorizationStatusRestricted) {
                callback(NO, ZKPermissionAuthorizationStatusRestricted);
            }
        } break;

        case ZKPermissionTypeBluetooth: {
            if (@available(iOS 10.0, *)) {
                CBCentralManager *centralManager = [[CBCentralManager alloc] init];
                CBManagerState state             = [centralManager state];
                if (state == CBManagerStateUnsupported || state == CBManagerStateUnauthorized || state == CBManagerStateUnknown) {
                    callback(NO, ZKPermissionAuthorizationStatusDenied);
                } else {
                    callback(YES, ZKPermissionAuthorizationStatusAuthorized);
                }
            }
        } break;

        case ZKPermissionTypePushNotification: {
            if (@available(iOS 10.0, *)) {
                UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
                UNAuthorizationOptions types     = UNAuthorizationOptionBadge | UNAuthorizationOptionAlert | UNAuthorizationOptionSound;
                [center requestAuthorizationWithOptions:types
                                      completionHandler:^(BOOL granted, NSError *_Nullable error) {
                                          if (granted) {
                                              [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings *_Nonnull settings){
                                                  //
                                              }];
                                          } else {
                                              [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{ UIApplicationOpenURLOptionUniversalLinksOnly: @"" } completionHandler:^(BOOL success){}];
                                          }
                                      }];
            } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge categories:nil]];
            }
#pragma clang diagnostic pop
        } break;

        case ZKPermissionTypeSpeech: {
            if (@available(iOS 10, *)) {
                [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
                    if (status == SFSpeechRecognizerAuthorizationStatusDenied) {
                        callback(NO, ZKPermissionAuthorizationStatusDenied);
                    } else if (status == SFSpeechRecognizerAuthorizationStatusNotDetermined) {
                        callback(NO, ZKPermissionAuthorizationStatusNotDetermined);
                    } else if (status == SFSpeechRecognizerAuthorizationStatusRestricted) {
                        callback(NO, ZKPermissionAuthorizationStatusRestricted);
                    } else if (status == SFSpeechRecognizerAuthorizationStatusAuthorized) {
                        callback(YES, ZKPermissionAuthorizationStatusAuthorized);
                    }
                }];
            }
        } break;

        case ZKPermissionTypeEvent: {
            EKEventStore *store = [[EKEventStore alloc] init];
            [store requestAccessToEntityType:EKEntityTypeEvent
                                  completion:^(BOOL granted, NSError *_Nullable error) {
                                      EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
                                      if (granted) {
                                          callback(YES, ZKPermissionAuthorizationStatusAuthorized);
                                      } else {
                                          if (status == EKAuthorizationStatusDenied) {
                                              callback(NO, ZKPermissionAuthorizationStatusDenied);
                                          } else if (status == EKAuthorizationStatusNotDetermined) {
                                              callback(NO, ZKPermissionAuthorizationStatusNotDetermined);
                                          } else if (status == EKAuthorizationStatusRestricted) {
                                              callback(NO, ZKPermissionAuthorizationStatusRestricted);
                                          }
                                      }
                                  }];
        } break;

        case ZKPermissionTypeContact: {
            if (@available(iOS 9.0, *)) {
                CNContactStore *contactStore = [[CNContactStore alloc] init];
                [contactStore requestAccessForEntityType:CNEntityTypeContacts
                                       completionHandler:^(BOOL granted, NSError *_Nullable error) {
                                           CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
                                           if (granted) {
                                               callback(YES, ZKPermissionAuthorizationStatusAuthorized);
                                           } else {
                                               if (status == CNAuthorizationStatusDenied) {
                                                   callback(NO, ZKPermissionAuthorizationStatusDenied);
                                               } else if (status == CNAuthorizationStatusRestricted) {
                                                   callback(NO, ZKPermissionAuthorizationStatusNotDetermined);
                                               } else if (status == CNAuthorizationStatusNotDetermined) {
                                                   callback(NO, ZKPermissionAuthorizationStatusRestricted);
                                               }
                                           }
                                       }];
            }
        } break;

        case ZKPermissionTypeReminder: {
            EKEventStore *eventStore = [[EKEventStore alloc] init];
            [eventStore requestAccessToEntityType:EKEntityTypeReminder
                                       completion:^(BOOL granted, NSError *_Nullable error) {
                                           EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
                                           if (granted) {
                                               callback(YES, ZKPermissionAuthorizationStatusAuthorized);
                                           } else {
                                               if (status == EKAuthorizationStatusDenied) {
                                                   callback(NO, ZKPermissionAuthorizationStatusDenied);
                                               } else if (status == EKAuthorizationStatusNotDetermined) {
                                                   callback(NO, ZKPermissionAuthorizationStatusNotDetermined);
                                               } else if (status == EKAuthorizationStatusRestricted) {
                                                   callback(NO, ZKPermissionAuthorizationStatusRestricted);
                                               }
                                           }
                                       }];
        } break;

        default:
            break;
    }
}

@end
