//
//  SJObjectContainer.h
//  SJUIKit_Example
//
//  Created by BlueDancer on 2018/12/14.
//  Copyright © 2018 changsanjiang@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SJFlagObject;

NS_ASSUME_NONNULL_BEGIN
@interface SJObjectContainer : NSObject
@property (nonatomic, strong, readonly) NSArray<SJFlagObject *> *flags;
@property (nonatomic, readonly) NSInteger count;
- (void)addFlag:(SJFlagObject *)flagObject;
- (void)removeFlag:(NSInteger)flag;
- (nullable SJFlagObject *)objectForFlag:(NSInteger)flag;
- (nullable SJFlagObject *)objectAtIndex:(NSInteger)idx;
- (NSInteger)flagOfObjectAtIndex:(NSInteger)idx;
- (NSUInteger)indexForFlag:(NSInteger)flag;
- (NSUInteger)indexOfObject:(SJFlagObject *)object;
- (void)removeAllObjects;
@end

@interface SJFlagObject : NSObject
@property (nonatomic, readonly) NSInteger flag;
- (instancetype)initWithFlag:(NSInteger)flag;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end

@interface SJFlagObject (Extra)
@property (nonatomic, strong, nullable) id title;
@property (nonatomic, strong, nullable) UIImage *image;
@property (nonatomic, strong, nullable) id extra;
@end
NS_ASSUME_NONNULL_END
