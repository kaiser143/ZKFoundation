//
//  ZKURLResponse.m
//  Masonry
//
//  Created by Kaiser on 2019/5/13.
//

#import "ZKURLResponse.h"

@interface ZKURLResponse () <ZKURLResponse>

@end

@implementation ZKURLResponse

- (instancetype)initWithResponseObject:(id)object formateClass:(__unsafe_unretained Class)cls {
    self = [super init];
    if (self == nil) return nil;
    
    return self;
}

- (NSString *)debugDescription {
    NSMutableString *logString = [NSMutableString stringWithString:@"\n\n**************************************************************\n*                       MRCURLResponse Start                        *\n**************************************************************\n\n"];
    
    [logString appendFormat:@"Status:%@\n", [self formatedFromStatus:self.status]];
    [logString appendFormat:@"ErrMsg:%@\n", self.errMsg ?: @"N/A"];
    [logString appendFormat:@"DataValue:%@\n", self.dataValue ?: @"N/A"];
    
    [logString appendFormat:@"\n\n**************************************************************\n*                         SLURLResponse End                        *\n**************************************************************\n\n\n\n"];
    NSLog(@"%@", logString);
    
    return logString;
}

- (NSString *)formatedFromStatus:(ZKURLResponseStatus)status {
    NSString *strings = @"N/A";
    switch (self.status) {
        case ZKURLResponseStatusSuccess: { strings = @"ZKURLResponseStatusSuccess"; } break;
        case ZKURLResponseStatusFailure: { strings = @"ZKURLResponseStatusFailure"; } break;
        default:
            break;
    }
    
    return strings;
}

@end
