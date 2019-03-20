//
//  ZKApp.m
//  FBSnapshotTestCase
//
//  Created by Kaiser on 2019/3/11.
//

#import "ZKApp.h"

static NSString *ZKHasBeenLaunch = @"ZKHasBeenLaunch";

@implementation ZKApp

+ (void)applicationDidLaunch:(void(^ _Nullable)(BOOL didLaunched))block {
    if (!block) return;
    
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *key = [NSString stringWithFormat:@"%@_%@", ZKHasBeenLaunch, version];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL hasBeenLaunch = [defaults boolForKey:key];
    if (hasBeenLaunch != YES) {
        [defaults setBool:YES forKey:key];
        [defaults synchronize];
    }
    
    block(!hasBeenLaunch);
}

@end
