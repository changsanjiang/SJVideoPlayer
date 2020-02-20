//
//  SJQueue.h
//  Pods
//
//  Created by 畅三江 on 2019/11/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface SJQueue<__covariant ObjectType> : NSObject
+ (instancetype)queue;

@property (nonatomic, readonly) NSInteger size;

@property (nonatomic, strong, readonly, nullable) ObjectType firstObject;
@property (nonatomic, strong, readonly, nullable) ObjectType lastObject;

- (void)enqueue:(ObjectType)obj;
- (nullable ObjectType)dequeue;
- (void)empty;
@end

@interface SJSafeQueue<__covariant ObjectType> : SJQueue

@end
NS_ASSUME_NONNULL_END
