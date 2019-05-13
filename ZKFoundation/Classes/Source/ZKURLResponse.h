//
//  ZKURLResponse.h
//  Masonry
//
//  Created by Kaiser on 2019/5/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ZKURLResponseStatus) {
    ZKURLResponseStatusSuccess,
    ZKURLResponseStatusFailure,
};

/*!
 *  @brief    ZKURLResponse 的子类需要根据业务需求实现该协议
 */
@protocol ZKURLResponse <NSObject>

@required
- (ZKURLResponseStatus)status;
- (BOOL)statusValidator;
- (id)dataValue;            // NSDictionary or NSArray
- (NSError *)error;
- (NSString *)errMsg;

@end

@interface ZKURLResponse : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithResponseObject:(id)object formateClass:(__unsafe_unretained Class)cls NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
