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
    self = [super init];
    if (self == nil) return nil;
    
    return self;
}

- (NSString *)debugDescription {
    NSMutableString *logString = [NSMutableString stringWithString:@"\n\n**************************************************************\n*                       ZKHTTPURLResponse Start                        *\n**************************************************************\n\n"];
    
    [logString appendFormat:@"Status:%@\n", [self formatedFromStatus:self.status]];
    [logString appendFormat:@"ErrMsg:%@\n", self.errMsg ?: @"N/A"];
    [logString appendFormat:@"DataValue:%@\n", self.dataValue ?: @"N/A"];
    
    [logString appendFormat:@"\n\n**************************************************************\n*                         ZKHTTPURLResponse End                        *\n**************************************************************\n\n\n\n"];
    NSLog(@"%@", logString);
    
    return logString;
}

- (NSString *)formatedFromStatus:(ZKHTTPURLResponseStatus)status {
    NSString *strings = @"N/A";
    switch (self.status) {
        case ZKHTTPURLResponseStatusSuccess: { strings = @"ZKHTTPURLResponseStatusSuccess"; } break;
        case ZKHTTPURLResponseStatusFailure: { strings = @"ZKHTTPURLResponseStatusFailure"; } break;
        default:
            break;
    }
    
    return strings;
}

@end
