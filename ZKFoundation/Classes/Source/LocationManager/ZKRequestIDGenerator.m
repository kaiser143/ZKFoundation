//
//  ZKRequestIDGenerator.m
//  FBSnapshotTestCase
//
//  Created by Kaiser on 2019/3/12.
//

#import "ZKRequestIDGenerator.h"

@implementation ZKRequestIDGenerator

static ZKLocationRequestID _nextRequestID = 0;

+ (ZKLocationRequestID)getUniqueRequestID {
    _nextRequestID++;
    return _nextRequestID;
}

@end
