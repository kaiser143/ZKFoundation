//
//  ZKHTTPURLResponse.m
//  ZKFoundation
//
//  Created by Kaiser on 2019/5/13.
//

#import "ZKHTTPURLResponse.h"

@interface ZKHTTPURLResponse () <ZKHTTPURLResponse>

@end

@implementation ZKHTTPURLResponse

- (instancetype)initWithResponseObject:(id)object formatClass:(__unsafe_unretained Class)cls {
#pragma unused(object, cls)
    self = [super init];
    if (self == nil) return nil;
    
    if (self.class == ZKHTTPURLResponse.class) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:[NSString stringWithFormat:@"You must override %@ in a subclass.", NSStringFromSelector(_cmd)]
                                     userInfo:nil];
    }
    
    return self;
}

- (NSString *)debugDescription {
    NSMutableString *logString = [NSMutableString stringWithString:@"\n\n**************************************************************\n*                       ZKHTTPURLResponse Start                        *\n**************************************************************\n\n"];
    
    [logString appendFormat:@"Status:%@\n", [self formattedFromStatus:self.status]];
    [logString appendFormat:@"ErrMsg:%@\n", self.errMsg ?: @"N/A"];
    [logString appendFormat:@"DataValue:%@\n", self.dataValue ?: @"N/A"];
    
    [logString appendFormat:@"\n\n**************************************************************\n*                         ZKHTTPURLResponse End                        *\n**************************************************************\n\n\n\n"];
    
    return logString;
}

- (NSString *)formattedFromStatus:(ZKHTTPURLResponseStatus)status {
    NSString *strings = @"N/A";
    switch (status) {
        case ZKHTTPURLResponseStatusSuccess: { strings = @"ZKHTTPURLResponseStatusSuccess"; } break;
        case ZKHTTPURLResponseStatusFailure: { strings = @"ZKHTTPURLResponseStatusFailure"; } break;
        default:
            break;
    }
    
    return strings;
}

#pragma mark - ZKHTTPURLResponse Protocol

- (ZKHTTPURLResponseStatus)status {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass.", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (BOOL)statusValidator {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass.", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (id)dataValue {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass.", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (NSError *)error {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass.", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (NSString *)errMsg {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass.", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

@end
