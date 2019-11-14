//
//  SJQueue.h
//  Pods
//
//  Created by BlueDancer on 2019/11/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface SJQueue<__covariant ObjectType> : NSObject
+ (instancetype)queue;

@property (nonatomic, readonly) NSInteger size;

- (void)enqueue:(ObjectType)obj;
- (nullable ObjectType)dequeue;
- (void)empty;
@end

@interface SJSafeQueue<__covariant ObjectType> : SJQueue

@end
NS_ASSUME_NONNULL_END
